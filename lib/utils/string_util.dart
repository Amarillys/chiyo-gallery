class StringUtil {
  static String formatDate(DateTime time) {
    final dateStr = time.toLocal().toString();
    return dateStr.substring(0, dateStr.length - 4);
  }

  static String cutString(String str, int maxLength) {
    if (str.length <= maxLength) {
      return str;
    }
    return '${str.substring(0, maxLength)}...';
  }
}