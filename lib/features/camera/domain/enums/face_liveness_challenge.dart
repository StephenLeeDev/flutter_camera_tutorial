enum FaceLivenessChallenge {
  blink, /// 눈깜박임
  smile, /// 웃음
  ;

  /// "blink,smile" -> [LivenessChallenge.blink, LivenessChallenge.smile]
  static List<FaceLivenessChallenge> parseLivenessChallenges(String value) {
    if (value.trim().isEmpty) return [FaceLivenessChallenge.blink];

    final set = <FaceLivenessChallenge>{}; /// 중복 제거 + 입력 순서 유지

    for (final raw in value.split(',')) {
      final challenge = raw.trim();
      if (challenge.isEmpty) continue;

      final lowerCase = challenge.toLowerCase();
      try {
        /// enum 이름과 동일해야 함. 여기선 blink/smile가 소문자이므로 lower로 정규화
        final item = FaceLivenessChallenge.values.byName(lowerCase);
        set.add(item);
      } catch (_) {
        /// 알 수 없는 텍스트는 무시
      }
    }
    return set.toList().isNotEmpty ? set.toList() : [FaceLivenessChallenge.blink];
  }
}