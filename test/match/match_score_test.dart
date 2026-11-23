import 'package:flutter_test/flutter_test.dart';
import 'package:mtier/app/app_state.dart';
import 'package:mtier/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppState.instance.clearLocalData();
    AppState.instance.language = 'fr';
  });

  test('a single matching interest cannot produce a 100 percent score', () {
    final data = ExplorerData(
      [
        {
          'id': 'occupation.test',
          'domain_id': 'domain.test',
          'family_id': 'family.test',
          'canonical_title': {'fr': 'Métier de test'},
          'definition': {'fr': 'Description de test'},
          'aliases': <String>[],
          'skills': <String>[],
        },
      ],
      const {},
      const {},
      const {},
      const {},
      const {},
      const {
        'domain.test': {'fr': 'Technologie'},
      },
    );

    final results = OrientationEngine.rank(data, {
      'interest_domains': ['Technologie'],
      'skills': <String>[],
      'followed_occupation_ids': <String>[],
    });

    expect(results, hasLength(1));
    expect(results.single.score, 30);
    expect(results.single.score, lessThan(100));
  });
  test('Match uses the active language for occupation skills', () {
    AppState.instance.language = 'en';
    final data = ExplorerData(
      [
        {
          'id': 'occupation.test',
          'domain_id': 'domain.test',
          'family_id': 'family.test',
          'canonical_title': {'fr': 'Métier de test', 'en': 'Test occupation'},
          'definition': {'fr': 'Description de test', 'en': 'Test description'},
          'aliases': <String>[],
          'skills': <String>[],
        },
      ],
      {
        'occupation.test': {
          'skills': [
            {'id': 'Analyse de données', 'type': 'technical'},
          ],
          'skills_en': [
            {'id': 'Data analysis', 'type': 'technical'},
          ],
          'skills_es': [
            {'id': 'Análisis de datos', 'type': 'technical'},
          ],
        },
      },
      const {},
      const {},
      const {},
      const {},
      const {
        'domain.test': {'fr': 'Technologie', 'en': 'Technology'},
      },
    );

    final results = OrientationEngine.rank(data, {
      'interest_domains': <String>[],
      'skills': ['Data analysis'],
      'followed_occupation_ids': <String>[],
    });

    expect(results, hasLength(1));
    expect(results.single.score, 45);
    expect(results.single.reasons.map((reason) => reason.code), contains('skills'));
  });

  test('localized skill tuples are displayed without exposing list syntax', () {
    expect(
      ExplorerData.displaySkill(['Análisis de datos', 'technical'], locale: 'es'),
      'Análisis de datos · técnica',
    );
  });

}
