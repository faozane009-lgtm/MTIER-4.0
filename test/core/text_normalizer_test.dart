import 'package:flutter_test/flutter_test.dart';
import 'package:mtier/core/text_normalizer.dart';

void main() {
  group('TextNormalizer', () {
    test('folds French and Spanish accents consistently', () {
      expect(TextNormalizer.normalize('Éducation, informática et sécurité'),
          'education informatica et securite');
    });

    test('uses word boundaries so Java does not match JavaScript', () {
      expect(TextNormalizer.containsPhrase('JavaScript developer', 'Java'), isFalse);
      expect(TextNormalizer.containsPhrase('Développeur Java senior', 'Java'), isTrue);
    });

    test('removes French, English and Spanish stopwords from tokens', () {
      expect(TextNormalizer.tokens('les bases of the seguridad y redes'),
          ['bases', 'seguridad', 'redes']);
    });

    test('detects harmful intent phrases without flagging defensive questions', () {
      const harmful = ['pirater un compte', 'attaquer un site', 'bypass authentication'];
      expect(TextNormalizer.containsAny('Comment protéger mon réseau contre les attaques ?', harmful), isFalse);
      expect(TextNormalizer.containsAny('Je veux pirater un compte', harmful), isTrue);
      expect(TextNormalizer.containsAny('How can I bypass authentication?', harmful), isTrue);
    });
  });
}
