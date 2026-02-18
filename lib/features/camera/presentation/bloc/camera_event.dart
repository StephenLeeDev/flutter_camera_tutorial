import 'package:equatable/equatable.dart';

abstract class CameraEvent extends Equatable {
  const CameraEvent();

  @override
  List<Object> get props => [];
}

// 카메라 초기화를 요청하는 이벤트
class InitializeCamera extends CameraEvent {}