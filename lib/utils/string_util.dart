class StringUtil {
  static String formatDate(DateTime time) {
    final dateStr = time.toLocal().toString();
    return dateStr.substring(0, dateStr.length - 4);
  }
}