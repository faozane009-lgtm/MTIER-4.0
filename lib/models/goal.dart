/// Canonical goal shared by Profile, Match, Progress, Academy and IA.
enum GoalType { career, learning, skill, project }
enum GoalStatus { inProgress, paused, completed, archived }

class Goal {
  final String id;
  final String title;
  final GoalType type;
  final GoalStatus status;
  final String? occupationId;
  final DateTime? targetDate;
  final DateTime createdAt;

  const Goal({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    this.occupationId,
    this.targetDate,
    required this.createdAt,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    GoalType parseType(Object? value) => GoalType.values.firstWhere(
      (item) => item.name == value,
      orElse: () => GoalType.learning,
    );
    GoalStatus parseStatus(Object? value) {
      switch (value) {
        case 'in_progress':
        case 'inProgress':
          return GoalStatus.inProgress;
        case 'paused':
          return GoalStatus.paused;
        case 'completed':
          return GoalStatus.completed;
        case 'archived':
          return GoalStatus.archived;
        default:
          return GoalStatus.inProgress;
      }
    }

    return Goal(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      type: parseType(json['type']),
      status: parseStatus(json['status']),
      occupationId: json['occupation_id']?.toString(),
      targetDate: DateTime.tryParse((json['target_date'] ?? '').toString()),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'type': type.name,
    'status': switch (status) {
      GoalStatus.inProgress => 'in_progress',
      GoalStatus.paused => 'paused',
      GoalStatus.completed => 'completed',
      GoalStatus.archived => 'archived',
    },
    'occupation_id': occupationId,
    'target_date': targetDate?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
  };
}
