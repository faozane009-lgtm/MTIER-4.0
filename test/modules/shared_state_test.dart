import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mtier/app/app_state.dart';
import 'package:mtier/main.dart';
import 'package:mtier/models/goal.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('a Goal added to shared state refreshes Profile and Progress', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await AppState.instance.initialize();
    await AppState.instance.clearLocalData();

    await tester.pumpWidget(const MTierApp());
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('Profil'));
    await tester.pump();
    expect(find.text('Objectif interconnecté de test'), findsNothing);

    AppState.instance.goals.add(Goal(
      id: 'widget-goal-1',
      title: 'Objectif interconnecté de test',
      type: GoalType.learning,
      status: GoalStatus.inProgress,
      createdAt: DateTime.utc(2026, 11, 23),
    ).toJson());
    AppState.instance.commit();
    await tester.pump();
    expect(find.text('Objectif interconnecté de test'), findsOneWidget);

    await tester.tap(find.text('Parcours'));
    await tester.pump();
    await tester.tap(find.text('Progress'));
    for (var attempt = 0; attempt < 10; attempt++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(find.text('Objectif interconnecté de test'), findsOneWidget);

    await AppState.instance.clearLocalData();
  });

  testWidgets('Profile edits update the shared snapshot without relying on build side effects', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await AppState.instance.initialize();
    await AppState.instance.clearLocalData();
    await tester.pumpWidget(const MTierApp());
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(find.text('Profil'));
    await tester.pump();

    final displayNameField = find.byType(TextField).first;
    await tester.enterText(displayNameField, 'Profil partagé');
    await tester.pump();

    expect(AppState.instance.profile['display_name'], 'Profil partagé');
    expect(AppState.instance.profile['age_band'], isNull);
    expect(AppState.instance.profile['country_code'], isNull);
    expect(AppState.instance.profile['education_level'], isNull);
    expect(AppState.instance.profile['learning_format'], isNull);
    await AppState.instance.clearLocalData();
  });

  testWidgets('global language choice updates navigation and persists locally', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await AppState.instance.initialize();
    await AppState.instance.clearLocalData();
    await tester.pumpWidget(const MTierApp());
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byTooltip('Langue de l’application'));
    await tester.pump();
    await tester.tap(find.text('Español').last);
    await tester.pump();

    expect(AppState.instance.language, 'es');
    expect(find.text('Perfil'), findsOneWidget);
    expect(find.text('Recorrido'), findsOneWidget);
    expect(find.text('Academia'), findsOneWidget);
    expect(find.byTooltip('IA'), findsOneWidget);
    expect(find.textContaining('La navegación y algunos contenidos'), findsOneWidget);
    await tester.tap(find.text('Recorrido'));
    await tester.pump();
    expect(find.text('Progreso'), findsOneWidget);
    await AppState.instance.persist();
    final preferences = await SharedPreferences.getInstance();
    final stored = jsonDecode(preferences.getString('mtier.local_state.v1')!) as Map<String, dynamic>;
    expect(stored['language'], 'es');
    await AppState.instance.clearLocalData();
  });


  testWidgets('theme selector changes the active theme mode and stores the choice', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await AppState.instance.initialize();
    await AppState.instance.clearLocalData();
    await tester.pumpWidget(const MTierApp());
    await tester.pump();

    expect(AppState.instance.themeMode, 'dark');
    await tester.tap(find.byTooltip('Apparence'));
    await tester.pump();
    await tester.tap(find.text('Clair').last);
    await tester.pump();
    expect(AppState.instance.themeMode, 'light');

    await AppState.instance.persist();
    final preferences = await SharedPreferences.getInstance();
    final stored = jsonDecode(preferences.getString('mtier.local_state.v1')!) as Map<String, dynamic>;
    expect(stored['theme_mode'], 'light');
    await AppState.instance.clearLocalData();
  });

}
