class DurationUtility {
  static String formattedDurationFromSeconds(int seconds) {
    final minutes = seconds / 60;
    final secondsRemaining = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${secondsRemaining.toString()
        .padLeft(0, '0')}";
  }
}
