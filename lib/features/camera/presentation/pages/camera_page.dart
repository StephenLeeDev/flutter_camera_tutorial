import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/camera_bloc.dart';
import '../bloc/camera_event.dart';
import '../bloc/camera_state.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  @override
  void initState() {
    super.initState();
    // 위젯이 생성될 때 카메라 초기화 이벤트를 BLoC에 전달합니다.
    context.read<CameraBloc>().add(InitializeCamera());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Camera")),
      // BlocBuilder를 사용하여 BLoC의 상태에 따라 UI를 렌더링합니다.
      body: BlocBuilder<CameraBloc, CameraState>(
        builder: (context, state) {
          // 로딩 중이거나 초기 상태일 때
          if (state is CameraInitial || state is CameraLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          // 카메라가 준비되었을 때
          if (state is CameraReady) {
            return _buildCameraPreview(state);
          }
          // 에러가 발생했을 때
          if (state is CameraFailure) {
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.white)));
          }
          // 그 외의 경우
          return const Center(child: Text('알 수 없는 상태입니다.', style: TextStyle(color: Colors.white)));
        },
      ),
    );
  }

  // 카메라 미리보기 및 상태 메시지를 보여주는 위젯
  Widget _buildCameraPreview(CameraReady state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 32),
              width: 300,
              height: 300,
              child: ClipOval(
                child: OverflowBox(
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: 300,
                      height: 300,
                      child: CameraPreview(state.cameraController),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        // 상태 메시지
        Text(state.statusMessage, textAlign: TextAlign.center),
      ],
    );
  }
}
