class Convertion{
  static const Map _letterConversion = {
    // German characters
    "ä": "a",
    "ö": "o",
    "ü": "u",

    // Turkish characters
    "ç": "c",
    "Ç": "C",
    "ğ": "g",
    "ı̇": "i",
    "ö̇": "o",
    "ş": "s",
  };

  static String convert(String str) {
    if (str == null || str.isEmpty) return str;

    final converted = [];
    var sourceSymbols = [];

    sourceSymbols = str.toLowerCase().split('');

    for (final element in sourceSymbols) {
      converted.add(_letterConversion.containsKey(element) ? _letterConversion[element] : element);
    }

    return converted.join();
  }
}