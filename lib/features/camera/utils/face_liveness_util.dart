import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceLivenessUtil {

  /// 촬영된 얼굴이 화면 중앙에 위치 했는지 검증
  bool isFaceCentered(CameraImage image, Face face) {
    /// 얼굴 사이즈
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

    /// 얼굴 중앙점의 좌표
    /// 얼굴이 화면 중앙에 위치 했는지 확인하는 데에 활용 하기 위함
    final faceCenterX = face.boundingBox.left + face.boundingBox.width / 2;
    final faceCenterY = face.boundingBox.top + face.boundingBox.height / 2;
    debugPrint("faceCenterX : $faceCenterX");
    debugPrint("faceCenterY : $faceCenterY");

    final imageCenterX = imageWidth / 2;
    final imageCenterY = imageHeight / 2;

    /// 얼굴이 화면 중앙 XY 좌표 20% 이내에 위치하면, 화면 중앙에 위치한 것으로 판단
    const double centerToleranceX = 0.1;
    const double centerToleranceY = 0.1;

    /// 얼굴이 화면 중앙 XY 좌표 20% 이내에 위치하면, 화면 중앙에 위치한 것으로 판단
    final deltaX = (faceCenterX - imageCenterX).abs() / imageWidth;
    final deltaY = (faceCenterY - imageCenterY).abs() / imageHeight;
    debugPrint("deltaX : $deltaX");
    debugPrint("deltaY : $deltaY");

    /// 얼굴이 화면 중앙에 위치 했는지 최종 판단
    final isCentered = deltaX < centerToleranceX && deltaY < centerToleranceY;

    return isCentered;
  }

  /// 얼굴이 화면을 정면으로 바라보고 있는지 검증
  /// 허용 범위 내에 있으면 정면으로 간주
  ///
  /// 그 기준 값은 [headTurnThreshold]로
  /// 얼굴이 이 각도 이내로 정면을 보고 있으면 통과
  bool isFront(CameraImage image, Face face, double headTurnThreshold) {
    /// headEulerAngleY: 얼굴 좌우 회전 (Yaw)
    /// headEulerAngleX: 얼굴 상하 회전 (Pitch)
    final double yaw = face.headEulerAngleY ?? 0.0;
    final double pitch = face.headEulerAngleX ?? 0.0;

    /// 얼굴이 화면을 정면으로 바라보고 있는지 판단
    /// 허용 범위 내에 있으면 정면으로 간주
    final bool isFront = yaw.abs() <= headTurnThreshold && pitch.abs() <= headTurnThreshold;

    return isFront;
  }

  // TODO : 눈을 가렸는데도 불구하고 [_isValidFace] 결과가 true로 나오는 케이스 발생
  // TODO : 눈 사이즈를 같이 측정하는 로직 추가해봐야 할 듯?
  bool isValidFace(
      Face previous,
      Face current,
      Map<FaceLandmarkType, FaceLandmark?> landmarks,
      Map<FaceContourType, FaceContour?> contours,
      ) {
    return
      isValidLandmarks(landmarks) &&
          isValidContour(contours) &&
          isStableFace(previous, current);
  }

  /// 눈코입이 카메라에 잡혔는지 검증
  ///
  /// [README]
  /// 코와 입 같은 경우엔 마우스를 착용해도 [FaceLandmarkType]에서 코와 입이 감지가 돼버리는 이슈 존재
  /// 코와 입이 직접적으로 감지 돼지 않아도,
  /// ML Kit에서 얼굴의 형태를 분석하여 코와 입에 해당하는 얼굴 부분이 카메라에 감지 됐다고 인지하는 문제로 판단됨
  ///
  /// 차선책으로 [FaceLandmarkType] 외에 [FaceContourType]도 교차 검증해서
  /// 얼굴 전체가 감지 됐는지 판단하는 것으로 개선
  bool isValidLandmarks(Map<FaceLandmarkType, FaceLandmark?> landmarks) {

    final bottomMouth = landmarks[FaceLandmarkType.bottomMouth];
    final rightMouth = landmarks[FaceLandmarkType.rightMouth];
    final leftMouth = landmarks[FaceLandmarkType.leftMouth];
    final rightEye = landmarks[FaceLandmarkType.rightEye];
    final leftEye = landmarks[FaceLandmarkType.leftEye];
    final rightEar = landmarks[FaceLandmarkType.rightEar];
    final leftEar = landmarks[FaceLandmarkType.leftEar];
    final rightCheek = landmarks[FaceLandmarkType.rightCheek];
    final leftCheek = landmarks[FaceLandmarkType.leftCheek];
    final noseBase = landmarks[FaceLandmarkType.noseBase];

    debugPrint("bottomMouth : $bottomMouth");
    debugPrint("rightMouth : $rightMouth");
    debugPrint("leftMouth : $leftMouth");
    debugPrint("rightEye : $rightEye");
    debugPrint("leftEye : $leftEye");
    debugPrint("rightEar : $rightEar");
    debugPrint("leftEar : $leftEar");
    debugPrint("rightCheek : $rightCheek");
    debugPrint("leftCheek : $leftCheek");
    debugPrint("noseBase : $noseBase");

    return
      bottomMouth != null &&
          rightMouth != null &&
          leftMouth != null &&
          rightEye != null &&
          leftEye != null &&
          rightEar != null &&
          leftEar != null &&
          rightCheek != null &&
          leftCheek != null &&
          noseBase != null;
  }

  /// 얼굴 전체 윤곽이 화면에 잡혔는지 검증
  ///
  /// [README]
  /// 코와 입 같은 경우엔 마우스를 착용해도 [FaceLandmarkType]에서 코와 입이 감지가 돼버리는 이슈 존재
  /// 코와 입이 직접적으로 감지 돼지 않아도,
  /// ML Kit에서 얼굴의 형태를 분석하여 코와 입에 해당하는 얼굴 부분이 카메라에 감지 됐다고 인지하는 문제로 판단됨
  ///
  /// 차선책으로 [FaceLandmarkType] 외에 [FaceContourType]도 교차 검증해서
  /// 얼굴 전체가 감지 됐는지 판단하는 것으로 개선
  bool isValidContour(Map<FaceContourType, FaceContour?> contours) {

    final face = contours[FaceContourType.face];
    final leftEyebrowTop = contours[FaceContourType.leftEyebrowTop];
    final leftEyebrowBottom = contours[FaceContourType.leftEyebrowBottom];
    final rightEyebrowTop = contours[FaceContourType.rightEyebrowTop];
    final rightEyebrowBottom = contours[FaceContourType.rightEyebrowBottom];
    final leftEye = contours[FaceContourType.leftEye];
    final rightEye = contours[FaceContourType.rightEye];
    final upperLipTop = contours[FaceContourType.upperLipTop];
    final upperLipBottom = contours[FaceContourType.upperLipBottom];
    final lowerLipTop = contours[FaceContourType.lowerLipTop];
    final lowerLipBottom = contours[FaceContourType.lowerLipBottom];
    final noseBridge = contours[FaceContourType.noseBridge];
    final noseBottom = contours[FaceContourType.noseBottom];
    final leftCheek = contours[FaceContourType.leftCheek];
    final rightCheek = contours[FaceContourType.rightCheek];

    debugPrint("face : $face");
    debugPrint("leftEyebrowTop : $leftEyebrowTop");
    debugPrint("leftEyebrowBottom : $leftEyebrowBottom");
    debugPrint("rightEyebrowTop : $rightEyebrowTop");
    debugPrint("rightEyebrowBottom : $rightEyebrowBottom");
    debugPrint("leftEye : $leftEye");
    debugPrint("rightEye : $rightEye");
    debugPrint("upperLipTop : $upperLipTop");
    debugPrint("upperLipBottom : $upperLipBottom");
    debugPrint("lowerLipTop : $lowerLipTop");
    debugPrint("lowerLipBottom : $lowerLipBottom");
    debugPrint("noseBridge : $noseBridge");
    debugPrint("noseBottom : $noseBottom");
    debugPrint("leftCheek : $leftCheek");
    debugPrint("rightCheek : $rightCheek");

    return
      face != null &&
          leftEyebrowTop != null &&
          leftEyebrowBottom != null &&
          rightEyebrowTop != null &&
          rightEyebrowBottom != null &&
          leftEye != null &&
          rightEye != null &&
          upperLipTop != null &&
          upperLipBottom != null &&
          lowerLipTop != null &&
          lowerLipBottom != null &&
          noseBridge != null &&
          noseBottom != null &&
          leftCheek != null &&
          rightCheek != null;
  }

  /// 카메라가 흔들리는 시점에 얼굴 사진을 캡쳐해서
  /// 얼굴이 흐릿하게 잡히는 것을 방지하기 위함
  bool isStableFace(Face current, Face previous) {
    try {
      /// 왼쪽/오른쪽 눈 Landmark 이동 거리
      final leftEyeMove  = distance(previous, current, FaceLandmarkType.leftEye);
      final rightEyeMove = distance(previous, current, FaceLandmarkType.rightEye);

      /// Yaw(좌우 회전) 각도 변화량
      final angleDiff = (previous.headEulerAngleY! - current.headEulerAngleY!).abs();

      /// threshold 값은 기기/환경 따라 튜닝 가능
      return
        leftEyeMove < 2 &&
            rightEyeMove < 2 &&
            angleDiff < 1;
    } catch (_) {
      return false;
    }
  }

  double distance(
      Face previous,
      Face current,
      FaceLandmarkType type,
      ) {
    final prevLandmark = previous.landmarks[type];
    final currLandmark = current.landmarks[type];

    if (prevLandmark == null || currLandmark == null) {
      return double.infinity;
    }

    final dx = prevLandmark.position.x - currLandmark.position.x;
    final dy = prevLandmark.position.y - currLandmark.position.y;

    return math.sqrt(dx * dx + dy * dy);
  }

}
