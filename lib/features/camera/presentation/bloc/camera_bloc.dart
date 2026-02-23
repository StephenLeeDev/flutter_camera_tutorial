import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../../utils/face_liveness_util.dart';
import '../../utils/image_converter.dart';
import 'camera_event.dart';
import 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  late CameraController? _cameraController;

  final _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      enableLandmarks: true,
      enableContours: true,
      enableTracking: true,
      minFaceSize: 0.3,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  /// 눈깜박임 횟수
  int blinkCount = 0;

  void setBlinkCount(int value) {
    blinkCount = value;
  }

  void increaseBlinkCount() {
    setBlinkCount(blinkCount + 1);
  }

  void initBlinkCount() {
    setBlinkCount(0);
  }

  final double _blinkThreshold = 0.25;

  /// 얼굴 너비가 사진에서 일정 비중 이상 차지해야함
  /// 얼굴이 너무 작게 잡히면 안됨
  final double _minFaceSizeRatio = 0.40;

  /// 얼굴 너비가 사진에서 일정 비중 이하의 영역만 차지해야함
  /// 얼굴이 너무 크게 잡히면 안됨
  final double _maxFaceSizeRatio = 0.70;

  /// 얼굴의 좌우/상하 움직임을 판단할 각도 임계값 (예: 10도)
  final double _headTurnThreshold = 10.0;

  // /// 웃음 감지 여부
  // final RxBool _hasSmiled = false.obs;
  // bool get hasSmiled => _hasSmiled.value;
  // void setHasSmiled(bool value) {
  //   _hasSmiled.value = value;
  //   if (value == true) {
  //     removeSmile();
  //     // checkRemaining();
  //   }
  // }

  /// 웃음의 정도를 판단할 임계값
  final double _smileThreshold = 0.2;

  /// 추적 중인 얼굴의 ID
  ///
  /// 화면에서 얼굴이 벗어나면 변경됨
  /// 이걸 감지해서 [trackingId]가 변하면, 검증을 처음부터 다시 시작하도록 제한할 수 있음
  /// 불량 고객이 편법으로 검증을 뚫으려는 시도를 방지하는 용도
  ///
  /// 화면에 얼굴이 2개 이상 잡히면, 얼굴이 화면을 벗어나지 않아도
  /// [trackingId]가 계속 변하는 이슈 있음
  /// 이건 해결 불가능
  /// 그냥 UI단에서 '다른 사람의 얼굴이 화면에 잡히지 않게 해주세요' 등의 안내 메시지를 보여줘서 대응
  int? trackingId;

  void setTrackingId(int? value) {
    debugPrint("trackingId : $trackingId");
    trackingId = value;
    // setHasBlinking(false);
    // setHasSmiled(false);
    // initVerificationList();
  }

  Face? previousFace;

  CameraBloc() : super(CameraInitial()) {
    on<InitializeCamera>(_onInitializeCamera);
  }

  Future<void> _onInitializeCamera(
    InitializeCamera event,
    Emitter<CameraState> emit,
  ) async {
    try {
      emit(CameraLoading());
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController?.initialize();
      await _cameraController?.startImageStream(_processCameraImage);

      emit(
        CameraReady(
          cameraController: _cameraController!,
          statusMessage: '카메라가 준비되었습니다.',
        ),
      );
    } on CameraException catch (e) {
      emit(CameraFailure(message: '카메라 초기화에 실패했습니다: ${e.description}'));
    } catch (e) {
      emit(CameraFailure(message: '알 수 없는 오류가 발생했습니다: $e'));
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_cameraController == null) return;

    final inputImage = ImageConverter.fromCameraImage(
      image,
      _cameraController!,
    );
    if (inputImage == null) return;

    final faces = await _faceDetector.processImage(inputImage);

    /// 1. 얼굴 감지 여부
    if (faces.isEmpty) {
      debugPrint("faces.isEmpty");
    } else {
      /// 2. 얼굴이 감지된 경우, 얼굴 크기부터 확인
      final face = faces.first;

      if (face.trackingId != null && trackingId != face.trackingId) {
        setTrackingId(face.trackingId);
      }

      final isFaceCentered = FaceLivenessUtil().isFaceCentered(image, face);
      debugPrint("isFaceCentered : $isFaceCentered");

      /// 얼굴 크기
      /// 얼굴의 크기가 적절한지 && 얼굴이 화면 중앙에 위치 했는지를 확인하는 데에 활용 하기 위함
      final faceWidth = face.boundingBox.width;
      int imageWidth = image.width;
      int imageHeight = image.height;

      /// README : Android는 사진(image)이 90도 눕혀져서 들어오는 이슈 존재
      /// README : Android일 때는 가로/세로 길이를 뒤집어서 얼굴이 사진 중앙에 위치하는지 확인
      if (Platform.isAndroid) {
        imageWidth = image.height;
        imageHeight = image.width;
      }
      debugPrint("imageWidth : $imageWidth");
      debugPrint("imageHeight : $imageHeight");

      /// 얼굴이 화면을 정면으로 바라보고 있는지 판단
      /// 허용 범위 내에 있으면 정면으로 간주
      final bool isFront = FaceLivenessUtil().isFront(
        image,
        face,
        _headTurnThreshold,
      );

      final landmarks = face.landmarks;
      final contours = face.contours;

      /// 촬영되고 있는 얼굴이 유효한지 여부를 확인
      /// 수집 가능한 모든 데이터를 조회해서, 얼굴 전체가 화면에 잘 잡혔는지 판단
      // TODO : Google ML Kit의 한계로 인해 아직 완벽하진 않음
      // TODO : 2차 개발에서 MediaPipe 추가 적용하여 보완 필요

      if (previousFace != null) {
        final isValidFace = FaceLivenessUtil().isValidFace(
          previousFace!,
          face,
          landmarks,
          contours,
        );
        debugPrint("isValidFace : $isValidFace");

        /// 2-1. 얼굴이 너무 작은 경우 -> 감지 실패로 처리
        if (faceWidth / imageWidth < _minFaceSizeRatio) {
          // setStatus(FaceLivenessStatus.faceTooSmall);
          debugPrint("_processCameraImage : 얼굴이 너무 작음");
        }
        /// 2-2. 얼굴이 너무 큰 경우 -> 감지 실패로 처리
        else if (faceWidth / imageWidth > _maxFaceSizeRatio) {
          // setStatus(FaceLivenessStatus.faceTooLarge);
          debugPrint("_processCameraImage : 얼굴이 너무 큼");
        }
        /// 얼굴이 화면 중앙에 위치 하지 않은 경우
        else if (!isFaceCentered) {
          // setStatus(FaceLivenessStatus.faceNotCentered);
          debugPrint("_processCameraImage : 얼굴이 화면 중앙에 위치 하지 않음");
        }
        /// 얼굴이 화면을 정면으로 바라보고 있지 않음
        else if (!isFront) {
          // setStatus(FaceLivenessStatus.faceNotFront);
          debugPrint("_processCameraImage : 얼굴이 화면 정면을 보고 있지 않음");
        } else {
          /// 촬영 중인 얼굴이 유효하면, 검증 시작
          if (isValidFace) {
            debugPrint("_processCameraImage : the face is valid");
            /// 눈 깜빡임 감지 로직
            final double leftEyeOpenProb = face.leftEyeOpenProbability ?? 1.0;
            final double rightEyeOpenProb = face.rightEyeOpenProbability ?? 1.0;
            final bool hasBlinkedLeft = leftEyeOpenProb < _blinkThreshold;
            final bool hasBlinkedRight = rightEyeOpenProb < _blinkThreshold;

            // /// 눈 깜박임
            // if (!hasBlinking && containsBlink) {
            //   setStatus(FaceLivenessStatus.blinkRequired);
            //   if (hasBlinkedLeft && hasBlinkedRight) {
            //     increaseBlinkCount();
            //     await Future.delayed(const Duration(milliseconds: 300));
            //     debugPrint("blinkCount : $blinkCount");
            //     if (blinkCount > 1) setHasBlinking(true);
            //   }
            // }
            // /// 웃음 감지
            // else if (!hasSmiled && containsSmile) {
            //   setStatus(FaceLivenessStatus.smileRequired);
            //   final double? smileProb = face.smilingProbability;
            //
            //   if (smileProb != null) {
            //     debugPrint("smileProb : $smileProb");
            //     if (smileProb > _smileThreshold) {
            //       if (_verificationList.isEmpty) {
            //         setStatus(FaceLivenessStatus.verificationComplete);
            //       } else if (containsBlink) {
            //         setStatus(FaceLivenessStatus.blinkRequired);
            //       }
            //       setHasSmiled(true);
            //       // TODO : 이미지 저장 로직 구현
            //       if (!isSmilingFaceSaved) {
            //         isSmilingFaceSaved = true;
            //         await saveFace(image);
            //
            //         // TODO : 추후 리팩토링 할 것
            //         for (var path in imagePathList) {
            //           debugPrint("path : $path");
            //         }
            //
            //         // TODO : 이미지 업로드 로직 추가
            //         // Get.back(result: true);
            //         checkRemaining();
            //       }
            //     }
            //   }
            // }
          }
        }
      }
      previousFace = face;
    }
  }

  @override
  Future<void> close() {
    if (state is CameraReady) {
      (state as CameraReady).cameraController.dispose();
    }
    _faceDetector.close();
    return super.close();
  }
}
