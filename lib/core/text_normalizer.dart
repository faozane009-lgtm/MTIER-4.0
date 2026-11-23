/// Shared French/English/Spanish normalization for Match and assistant intents.
class TextNormalizer {
  TextNormalizer._();

  static const Map<String, String> _fold = {
    'à': 'a', 'á': 'a', 'â': 'a', 'ä': 'a', 'ã': 'a', 'å': 'a',
    'ç': 'c',
    'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e',
    'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i',
    'ñ': 'n',
    'ò': 'o', 'ó': 'o', 'ô': 'o', 'ö': 'o', 'õ': 'o',
    'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u',
    'ý': 'y', 'ÿ': 'y', 'œ': 'oe', 'æ': 'ae',
  };

  static const Set<String> _stopWords = {
    // French
    'a', 'au', 'aux', 'avec', 'ce', 'ces', 'dans', 'de', 'des', 'du', 'elle',
    'en', 'et', 'eux', 'il', 'je', 'la', 'le', 'les', 'leur', 'lui', 'ma',
    'mais', 'me', 'mes', 'moi', 'mon', 'ne', 'nos', 'notre', 'nous', 'on',
    'ou', 'par', 'pas', 'pour', 'qu', 'que', 'qui', 'sa', 'se', 'ses', 'son',
    'sur', 'ta', 'te', 'tes', 'toi', 'ton', 'tu', 'un', 'une', 'vos', 'votre',
    'vous', 'y',
    // English
    'a', 'an', 'and', 'are', 'as', 'at', 'be', 'by', 'for', 'from', 'has',
    'have', 'he', 'her', 'his', 'i', 'in', 'is', 'it', 'its', 'me', 'my',
    'of', 'on', 'or', 'our', 'she', 'that', 'the', 'their', 'them', 'they',
    'this', 'to', 'was', 'we', 'were', 'with', 'you', 'your',
    // Spanish
    'al', 'como', 'con', 'de', 'del', 'el', 'ella', 'ellas', 'ellos', 'en',
    'es', 'esta', 'este', 'la', 'las', 'lo', 'los', 'mi', 'mis', 'o', 'para',
    'por', 'que', 'se', 'su', 'sus', 'un', 'una', 'unos', 'unas', 'y',
  };

  static String normalize(String value) {
    final lower = value.toLowerCase().replaceAll(RegExp(r"[’'`´]"), ' ');
    final folded = lower.replaceAllMapped(
      RegExp('[${_fold.keys.join()}]'),
      (match) => _fold[match.group(0)] ?? '',
    );
    return folded.replaceAll(RegExp(r'[\u0300-\u036f]'), '')
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static List<String> tokens(String value) => normalize(value)
      .split(' ')
      .where((token) => token.length > 1 && !_stopWords.contains(token))
      .toList();

  /// Matches complete words/phrases, never arbitrary substrings.
  static bool containsPhrase(String text, String phrase) {
    final normalizedText = normalize(text);
    final normalizedPhrase = normalize(phrase);
    if (normalizedText.isEmpty || normalizedPhrase.isEmpty) return false;
    return RegExp('(^| )${RegExp.escape(normalizedPhrase)}( |$)')
        .hasMatch(normalizedText);
  }

  static bool containsAny(String text, Iterable<String> phrases) =>
      phrases.any((phrase) => containsPhrase(text, phrase));
}
