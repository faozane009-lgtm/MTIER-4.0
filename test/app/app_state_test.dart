import 'package:flutter_test/flutter_test.dart';
import 'package:mtier/app/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('migrates legacy local state, persists it and supports explicit deletion', () async {
    SharedPreferences.setMockInitialValues({
      'mtier.local_state.v1': '{"schema_version":0,"profile":{"country_code":"BJ","goals":["Apprendre Python"]},"goals":[],"evidence":[],"journal":[],"viewed_lesson_ids":["lesson-1"],"language":"fr","theme_mode":"dark","onboarding_completed":true}',
    });
    final state = AppState.instance;
    await state.initialize();
    expect(state.profile['country_code'], 'BJ');
    expect(state.viewedLessonIds, contains('lesson-1'));
    expect(state.viewedLessonTimestamps['lesson-1'], isEmpty);
    state.markLessonViewed('lesson-2');
    expect(DateTime.tryParse(state.viewedLessonTimestamps['lesson-2']!), isNotNull);
    expect(state.themeMode, 'dark');
    expect(state.onboardingCompleted, isTrue);
    expect(state.goals.single['title'], 'Apprendre Python');
    expect(state.goals.single['type'], 'learning');
    expect(state.profile.containsKey('goals'), isFalse);
    await state.persist();
    final persisted = await SharedPreferences.getInstance();
    expect(persisted.getString('mtier.local_state.v1'), isNotNull);
    await state.clearLocalData();
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('mtier.local_state.v1'), isNull);
  });
  test('setProfile notifies shared consumers and schedules persistence', () async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState.instance;
    await state.clearLocalData();
    var notifications = 0;
    void listener() => notifications++;
    state.addListener(listener);

    state.setProfile({'display_name': 'Shared profile'});

    expect(state.profile['display_name'], 'Shared profile');
    expect(notifications, 1);
    state.removeListener(listener);
    await state.clearLocalData();
  });

}

