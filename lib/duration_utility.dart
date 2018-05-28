class DurationUtility {
  static String formattedDurationFromSeconds(int seconds) {
    final duration = Duration(seconds: seconds);
    var inHours = duration.inHours;
    var inMinutes = duration.inMinutes % 60;
    var inSeconds = duration.inSeconds % 60;
    return (inHours > 0 ? "${inHours.toString().padLeft(2, '0')}:" : "") +
        "${inMinutes.toString().padLeft(2, '0')}:${inSeconds.toString()
            .padLeft(2, '0')}";
  }
}
