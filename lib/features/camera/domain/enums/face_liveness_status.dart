enum FaceLivenessStatus {
  faceNotDetected, /// 얼굴 안 잡힘
  faceTooSmall, /// 얼굴 작음
  faceTooLarge, /// 얼굴 큼
  faceNotCentered, /// 얼굴 화면 중앙에 안 위치함
  faceNotFront, /// 얼굴이 정면을 보지 않음
  eyesOccluded, /// 눈 가려짐 (TODO: 눈 크기로 판단 가능)
  mouthOccluded, /// 입 가려짐 (TODO: 2차 개발에서 MediaPipe로 구현)
  blinkRequired, /// 눈 깜박임 감지 필요
  smileRequired, /// 웃음 감지 필요
  verificationComplete, /// 검증 완료
  ;

  String get statusMessage {
    switch (this) {
      case FaceLivenessStatus.faceNotDetected:
        return "please_look_straight_at_the_camera";
      case FaceLivenessStatus.faceTooSmall:
        return "please_move_closer_to_the_camera";
      case FaceLivenessStatus.faceTooLarge:
        return "your_face_is_too_close";
      case FaceLivenessStatus.faceNotCentered:
        return "please_center_your_face_in_the_frame";
      case FaceLivenessStatus.faceNotFront:
        return "please_look_straight_at_the_camera";
      case FaceLivenessStatus.eyesOccluded:
        return "please_look_straight_at_the_camera";
    // case FaceLivenessStatus.mouthOccluded:
    //   return "";
      case FaceLivenessStatus.blinkRequired:
        return "please_blink_your_eyes";
      case FaceLivenessStatus.smileRequired:
        return "please_smile_for_the_camera";
      case FaceLivenessStatus.verificationComplete:
        return "content_list_menu_sub_title_verification_finish";
      default:
        return "";
    }
  }
}