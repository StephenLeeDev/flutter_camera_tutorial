import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import '../../domain/enums/face_liveness_status.dart';

abstract class CameraState extends Equatable {
  const CameraState();

  @override
  List<Object?> get props => [];
}

class CameraInitial extends CameraState {}

class CameraLoading extends CameraState {}

class CameraReady extends CameraState {
  final CameraController cameraController;
  final String statusMessage;
  final FaceLivenessStatus livenessStatus;

  const CameraReady({
    required this.cameraController, 
    required this.statusMessage,
    this.livenessStatus = FaceLivenessStatus.faceNotDetected,
  });

  @override
  List<Object?> get props => [cameraController, statusMessage, livenessStatus];

  CameraReady copyWith({
    CameraController? cameraController,
    String? statusMessage,
    FaceLivenessStatus? livenessStatus,
  }) {
    return CameraReady(
      cameraController: cameraController ?? this.cameraController,
      statusMessage: statusMessage ?? this.statusMessage,
      livenessStatus: livenessStatus ?? this.livenessStatus,
    );
  }
}

class CameraFailure extends CameraState {
  final String message;

  const CameraFailure({required this.message});

  @override
  List<Object> get props => [message];
}
