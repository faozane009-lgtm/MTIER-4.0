import 'package:flutter_test/flutter_test.dart';
import 'package:mtier/models/goal.dart';

void main() {
  group('Goal', () {
    test('serializes the complete canonical schema', () {
      final created = DateTime.utc(2026, 11, 23);
      final goal = Goal(
        id: 'goal-1',
        title: 'Découvrir la cybersécurité',
        type: GoalType.learning,
        status: GoalStatus.inProgress,
        occupationId: 'cybersecurity-analyst',
        targetDate: DateTime.utc(2027, 1, 1),
        createdAt: created,
      );
      final json = goal.toJson();
      expect(json.keys, containsAll([
        'id', 'title', 'type', 'status', 'occupation_id', 'target_date', 'created_at',
      ]));
      expect(json['type'], 'learning');
      expect(json['status'], 'in_progress');
      expect(Goal.fromJson(json).occupationId, 'cybersecurity-analyst');
    });

    test('migrates legacy goals without a type to learning goals', () {
      final migrated = Goal.fromJson({
        'id': 'legacy-1',
        'title': 'Apprendre Python',
        'status': 'paused',
        'created_at': '2026-11-22T10:00:00.000Z',
      });
      expect(migrated.type, GoalType.learning);
      expect(migrated.status, GoalStatus.paused);
      expect(migrated.toJson()['occupation_id'], isNull);
    });
  });
}
