import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mtier/l10n/generated/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('French, English and Spanish ARB resources expose matching navigation keys', () async {
    final french = await AppLocalizations.delegate.load(const Locale('fr'));
    final english = await AppLocalizations.delegate.load(const Locale('en'));
    final spanish = await AppLocalizations.delegate.load(const Locale('es'));

    expect(french.navProfile, 'Profil');
    expect(english.navProfile, 'Profile');
    expect(spanish.navProfile, 'Perfil');
    expect(french.navProgress, 'Progress');
    expect(english.navProgress, 'Progress');
    expect(spanish.navProgress, 'Progreso');
    expect(english.matchReasonSkills('Python'), 'Profile skills that match: Python');
    expect(spanish.matchReasonSkills('Python'), 'Competencias del perfil relacionadas: Python');
  });
}
