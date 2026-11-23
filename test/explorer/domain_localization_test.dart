import 'package:flutter_test/flutter_test.dart';
import 'package:mtier/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Explorer loads 115 canonical occupations and 28 localized domains', () async {
    final explorer = await ExplorerData.shared;
    expect(explorer.occupations, hasLength(115));
    expect(explorer.domainNames, hasLength(28));
    for (final names in explorer.domainNames.values) {
      expect(names['fr'], isNotEmpty);
      expect(names['en'], isNotEmpty);
      expect(names['es'], isNotEmpty);
    }
  });
}
