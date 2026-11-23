import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/goal.dart';

/// Single local source of truth. Supabase can later implement the same contract.
class AppState extends ChangeNotifier {
  AppState._();
  static final AppState instance = AppState._();
  static const int schemaVersion = 1;
  static const String _storageKey = 'mtier.local_state.v1';

  Map<String, dynamic> profile = <String, dynamic>{};
  final List<Map<String, dynamic>> goals = <Map<String, dynamic>>[];
  final List<Map<String, dynamic>> evidence = <Map<String, dynamic>>[];
  final List<Map<String, dynamic>> journal = <Map<String, dynamic>>[];
  final Map<String, String> viewedLessonTimestamps = <String, String>{};
  Set<String> get viewedLessonIds => viewedLessonTimestamps.keys.toSet();
  String language = 'fr';
  String themeMode = 'dark';
  bool onboardingCompleted = false;
  bool _ready = false;
  bool _storageReadOnly = false;
  String? storageWarning;
  Timer? _saveDebounce;
  Future<void> _writeQueue = Future<void>.value();
  bool get isReady => _ready;

  Future<void> initialize() async {
    if (_ready) return;
    try {
      final preferences = await SharedPreferences.getInstance();
      final raw = preferences.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          final storedVersion = (decoded['schema_version'] as num?)?.toInt() ?? 0;
          if (storedVersion > schemaVersion) {
            _storageReadOnly = true;
            storageWarning = 'newer_version';
            debugPrint('[M-TIER][LocalStore] $storageWarning');
          } else {
          // Version 0 represents the pre-versioned local draft; version 1 is canonical.
          final storedProfile = decoded['profile'];
          if (storedProfile is Map) profile = Map<String, dynamic>.from(storedProfile);
          _restoreMapList(decoded['goals'], goals);
          // Normalize older goal records into the canonical shared Goal schema.
          for (var index = 0; index < goals.length; index++) {
            goals[index] = Goal.fromJson(goals[index]).toJson();
          }
          // One-time migration of legacy Profile string goals into canonical Goal records.
          final legacyProfileGoals = profile['goals'];
          if (legacyProfileGoals is List) {
            for (var index = 0; index < legacyProfileGoals.length; index++) {
              final title = legacyProfileGoals[index].toString().trim();
              if (title.isEmpty || goals.any((goal) =>
                  (goal['title'] ?? '').toString().toLowerCase() == title.toLowerCase())) continue;
              goals.add(Goal(
                id: 'migrated-profile-goal-$index',
                title: title,
                type: GoalType.learning,
                status: GoalStatus.inProgress,
                createdAt: DateTime.now().toUtc(),
              ).toJson());
            }
          }
          profile.remove('goals');
          _restoreMapList(decoded['evidence'], evidence);
          _restoreMapList(decoded['journal'], journal);
          final lessonTimestamps = decoded['viewed_lesson_timestamps'];
          if (lessonTimestamps is Map) {
            for (final entry in lessonTimestamps.entries) {
              viewedLessonTimestamps[entry.key.toString()] = entry.value.toString();
            }
          }
          // Migrate the earlier ID-only lesson history without inventing a timestamp.
          final legacyLessons = decoded['viewed_lesson_ids'];
          if (legacyLessons is List) {
            for (final id in legacyLessons) {
              viewedLessonTimestamps.putIfAbsent(id.toString(), () => '');
            }
          }
          if (decoded['language'] is String && const ['fr', 'en', 'es'].contains(decoded['language'])) {
            language = decoded['language'] as String;
          }
          if (decoded['theme_mode'] is String && const ['system', 'light', 'dark'].contains(decoded['theme_mode'])) {
            themeMode = decoded['theme_mode'] as String;
          }
          onboardingCompleted = decoded['onboarding_completed'] == true;
          }
        }
      }
    } catch (error, stackTrace) {
      // Discard any partially decoded state so malformed storage cannot leave
      // Profile, Progress and Academy with inconsistent collections.
      profile = <String, dynamic>{};
      goals.clear();
      evidence.clear();
      journal.clear();
      viewedLessonTimestamps.clear();
      language = 'fr';
      themeMode = 'dark';
      onboardingCompleted = false;
      storageWarning = 'restore_failed';
      debugPrint('[M-TIER][LocalStore] Restore failed; safe empty state used: $error\n$stackTrace');
    }
    _ready = true;
  }

  void _restoreMapList(Object? source, List<Map<String, dynamic>> target) {
    if (source is! List) return;
    for (final item in source) {
      if (item is Map) target.add(Map<String, dynamic>.from(item));
    }
  }

  Future<void> persist() async {
    if (_storageReadOnly) return;
    final payload = <String, dynamic>{
      'schema_version': schemaVersion,
      'profile': profile,
      'goals': goals,
      'evidence': evidence,
      'journal': journal,
      'viewed_lesson_timestamps': viewedLessonTimestamps,
      'language': language,
      'theme_mode': themeMode,
      'onboarding_completed': onboardingCompleted,
    };
    final serialized = jsonEncode(payload);
    _writeQueue = _writeQueue.then((_) async {
      try {
        final preferences = await SharedPreferences.getInstance();
        final saved = await preferences.setString(_storageKey, serialized);
        if (!saved) throw StateError('Le stockage local a refusé la sauvegarde.');
        if (storageWarning != null && !_storageReadOnly) {
          storageWarning = null;
          notifyListeners();
        }
      } catch (error, stackTrace) {
        storageWarning = 'save_failed';
        notifyListeners();
        debugPrint('[M-TIER][LocalStore] Persist failed: $error\n$stackTrace');
      }
    });
    await _writeQueue;
  }

  void setProfile(Map<String, dynamic> value) {
    if (jsonEncode(profile) == jsonEncode(value)) return;
    profile = Map<String, dynamic>.from(value);
    commit();
  }

  void markLessonViewed(String lessonId) {
    if (lessonId.trim().isEmpty) return;
    viewedLessonTimestamps[lessonId] = DateTime.now().toUtc().toIso8601String();
    commit();
  }

  void commit() {
    notifyListeners();
    _schedulePersist();
  }

  void _schedulePersist() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 350), persist);
  }

  Future<void> clearLocalData() async {
    _saveDebounce?.cancel();
    _storageReadOnly = false;
    storageWarning = null;
    profile = <String, dynamic>{};
    goals.clear();
    evidence.clear();
    journal.clear();
    viewedLessonTimestamps.clear();
    language = 'fr';
    themeMode = 'dark';
    onboardingCompleted = false;
    await _writeQueue;
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_storageKey);
  }
}
