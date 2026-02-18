import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'camera_event.dart';
import 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
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

      final cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await cameraController.initialize();

      emit(CameraReady(cameraController: cameraController, statusMessage: '카메라가 준비되었습니다.'));
    } on CameraException catch (e) {
      emit(CameraFailure(message: '카메라 초기화에 실패했습니다: ${e.description}'));
    } catch (e) {
      emit(CameraFailure(message: '알 수 없는 오류가 발생했습니다: $e'));
    }
  }

  @override
  Future<void> close() {
    // BLoC이 닫힐 때 컨트롤러를 dispose 해야 메모리 누수를 막을 수 있습니다.
    if (state is CameraReady) {
      (state as CameraReady).cameraController.dispose();
    }
    return super.close();
  }
}
