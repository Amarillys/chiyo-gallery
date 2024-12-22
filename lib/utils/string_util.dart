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

  static List<String> splitLang(String language) {
    List<String> languageValue = language.split('-').toList();
    if (languageValue.length == 1) { languageValue.add(''); }
    return [languageValue.elementAt(0), languageValue.elementAt(1)];
  }
}

class ConstStr {
  static String directory = 'directory';
}