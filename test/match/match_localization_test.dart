import 'package:flutter_test/flutter_test.dart';
import 'package:mtier/app/app_state.dart';
import 'package:mtier/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Match uses the active locale for Explorer domain names and reason data', () async {
    final explorer = await ExplorerData.shared;

    AppState.instance.language = 'en';
    final english = OrientationEngine.rank(explorer, {
      'interest_domains': ['Cybersecurity and digital trust'],
      'skills': <String>[],
      'followed_occupation_ids': <String>[],
    });
    expect(english, isNotEmpty);
    expect(english.first.reasons.any((reason) => reason.code == 'interest' && reason.value == 'Cybersecurity and digital trust'), isTrue);

    AppState.instance.language = 'es';
    final spanish = OrientationEngine.rank(explorer, {
      'interest_domains': ['Ciberseguridad y confianza digital'],
      'skills': <String>[],
      'followed_occupation_ids': <String>[],
    });
    expect(spanish, isNotEmpty);
    expect(spanish.first.reasons.any((reason) => reason.code == 'interest' && reason.value == 'Ciberseguridad y confianza digital'), isTrue);

    AppState.instance.language = 'fr';
    AppState.instance.commit();
  });
}
