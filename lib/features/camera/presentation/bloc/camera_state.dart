import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';

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

  const CameraReady({required this.cameraController, required this.statusMessage});

  @override
  List<Object?> get props => [cameraController, statusMessage];
}

class CameraFailure extends CameraState {
  final String message;

  const CameraFailure({required this.message});

  @override
  List<Object> get props => [message];
}