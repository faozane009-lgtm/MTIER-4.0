import 'package:flutter_test/flutter_test.dart';
import 'package:mtier/main.dart';

void main() {
  test('localized Academy course preserves canonical module and lesson IDs', () {
    final source = <String, dynamic>{
      'id': 'course-1',
      'title': 'Titre français',
      'learning_outcomes': ['Objectif français'],
      'modules': [
        {
          'id': 'module-1',
          'title': 'Module français',
          'lessons': [
            {
              'id': 'lesson-1',
              'title': 'Leçon française',
              'objective': 'Objectif français',
              'activity': 'Activité française',
              'assessment': 'Évaluation française',
            },
          ],
        },
      ],
      'translations': {
        'es': {
          'title': 'Título español',
          'learning_outcomes': ['Objetivo español'],
          'modules': [
            {
              'id': 'module-1',
              'title': 'Módulo español',
              'lessons': [
                {
                  'id': 'lesson-1',
                  'title': 'Lección española',
                  'objective': 'Objetivo español',
                  'activity': 'Actividad española',
                  'assessment': 'Evaluación española',
                },
              ],
            },
          ],
        },
      },
    };

    final localized = AcademyData.localizedCourse(source, 'es');
    final module = (localized['modules'] as List).single as Map;
    final lesson = (module['lessons'] as List).single as Map;
    expect(localized['title'], 'Título español');
    expect(module['title'], 'Módulo español');
    expect(lesson['title'], 'Lección española');
    expect(lesson['id'], 'lesson-1');
    expect(module['id'], 'module-1');
  });
}
