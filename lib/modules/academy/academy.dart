part of '../../main.dart';

/// Academy's learning content is a reviewed, versioned curriculum fixture.
/// Occupations and career pathways always come from the shared Explorer data.
class AcademyData {
  static Future<AcademyData>? _shared;
  static Future<AcademyData> get shared => _shared ??= load();

  static Future<AcademyData> retry() {
    _shared = null;
    return shared;
  }

  final List<Map<String, dynamic>> courses;
  final List<String> loadErrors;

  AcademyData(this.courses, {this.loadErrors = const []});

  static Map<String, dynamic> localizedCourse(Map<String, dynamic> course, String locale) {
    if (locale == 'fr') return course;
    final translations = course['translations'];
    final localized = translations is Map ? translations[locale] : null;
    if (localized is! Map) return course;
    final result = Map<String, dynamic>.from(course)..remove('translations');
    result['title'] = localized['title'] ?? course['title'];
    result['learning_outcomes'] = localized['learning_outcomes'] ?? course['learning_outcomes'];
    final localizedModules = (localized['modules'] as List? ?? const [])
        .whereType<Map>().map((module) => Map<String, dynamic>.from(module))
        .fold<Map<String, Map<String, dynamic>>>({}, (map, module) {
          map[(module['id'] ?? '').toString()] = module;
          return map;
        });
    result['modules'] = (course['modules'] as List? ?? const []).whereType<Map>().map((rawModule) {
      final module = Map<String, dynamic>.from(rawModule);
      final translatedModule = localizedModules[(module['id'] ?? '').toString()];
      if (translatedModule == null) return module;
      module['title'] = translatedModule['title'] ?? module['title'];
      final translatedLessons = (translatedModule['lessons'] as List? ?? const [])
          .whereType<Map>().map((lesson) => Map<String, dynamic>.from(lesson))
          .fold<Map<String, Map<String, dynamic>>>({}, (map, lesson) {
            map[(lesson['id'] ?? '').toString()] = lesson;
            return map;
          });
      module['lessons'] = (module['lessons'] as List? ?? const []).whereType<Map>().map((rawLesson) {
        final lesson = Map<String, dynamic>.from(rawLesson);
        final translatedLesson = translatedLessons[(lesson['id'] ?? '').toString()];
        if (translatedLesson != null) {
          for (final field in const ['title', 'objective', 'activity', 'assessment']) {
            lesson[field] = translatedLesson[field] ?? lesson[field];
          }
        }
        return lesson;
      }).toList();
      return module;
    }).toList();
    return result;
  }

  static Future<AcademyData> load() async {
    try {
      final decoded = jsonDecode(await rootBundle.loadString(
        'assets/academy/learning-paths-fr.json'));
      if (decoded is! List) {
        throw const FormatException('Le fichier Academy ne contient pas une liste.');
      }
      final courses = decoded
          .whereType<Map>()
          .map((entry) => Map<String, dynamic>.from(entry))
          .toList();
      return AcademyData(courses);
    } catch (error) {
      final message = 'assets/academy/learning-paths-fr.json : $error';
      if (kDebugMode) debugPrint('[M-TIER][Academy] $message');
      return AcademyData(const [], loadErrors: [message]);
    }
  }
}

class AcademyBridge {
  /// Canonical lesson IDs shared with Progress and persisted locally.
  static Set<String> get viewedLessons => AppState.instance.viewedLessonIds;
  static void markViewed(String lessonId) => AppState.instance.markLessonViewed(lessonId);
}

/// Compatibility facade: every module reads the same central collections.
class AcademyPage extends StatefulWidget {
  const AcademyPage({super.key});
  @override State<AcademyPage> createState() => _AcademyPageState();
}

class _AcademyPageState extends State<AcademyPage> {
  Future<ExplorerData> explorerFuture = ExplorerData.shared;
  Future<AcademyData> academyFuture = AcademyData.shared;
  String? selectedOccupationId;

  void _retryExplorer() => setState(() => explorerFuture = ExplorerData.retry());
  void _retryAcademy() => setState(() => academyFuture = AcademyData.retry());

  @override Widget build(BuildContext context) => FutureBuilder<ExplorerData>(
    future: explorerFuture,
    builder: (context, explorerSnapshot) {
      if (explorerSnapshot.hasError) return _LoadState(message: AppLocalizations.of(context)!.academyExplorerUnavailable, error: explorerSnapshot.error.toString(), retry: _retryExplorer);
      if (!explorerSnapshot.hasData) return const Center(child: CircularProgressIndicator());
      final explorer = explorerSnapshot.data!;
      final profile = ProfileBridge.current;
      final matches = OrientationEngine.rank(explorer, profile).where((m) => m.score > 0).take(8).toList();
      OrientationMatch? selected;
      for (final candidate in matches) { if (candidate.occupation['id'] == selectedOccupationId) { selected = candidate; break; } }
      selected ??= matches.isNotEmpty ? matches.first : null;
      return FutureBuilder<AcademyData>(
        future: academyFuture,
        builder: (context, academySnapshot) {
          if (academySnapshot.hasError) return _LoadState(message: AppLocalizations.of(context)!.academyContentUnavailable, error: academySnapshot.error.toString(), retry: _retryAcademy);
          if (!academySnapshot.hasData) return const Center(child: CircularProgressIndicator());
          final academy = academySnapshot.data!;
          final locale = AppState.instance.language;
          final localizedCourses = academy.courses.map((course) => AcademyData.localizedCourse(course, locale)).toList();
          return ListView(padding: const EdgeInsets.all(16), children: [
            if (explorer.loadErrors.isNotEmpty) _PartialDataNotice(count: explorer.loadErrors.length, onRetry: _retryExplorer),
            if (academy.loadErrors.isNotEmpty) _PartialDataNotice(count: academy.loadErrors.length, onRetry: _retryAcademy),
            if (locale != 'fr') Card(child: Padding(padding: const EdgeInsets.all(12), child: Text(locale == 'en' ? AppLocalizations.of(context)!.localizationCoverageWarningEn : AppLocalizations.of(context)!.localizationCoverageWarningEs))),
            Text(AppLocalizations.of(context)!.academyTitle, style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(AppLocalizations.of(context)!.academyIntro),
            const SizedBox(height: 12),
            Card(child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
              const Icon(Icons.hub_outlined, size: 30), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(AppLocalizations.of(context)!.academyConnections, style: TextStyle(fontWeight: FontWeight.bold)),
                Text(AppLocalizations.of(context)!.academyConnectionSummary(explorer.occupations.length, matches.length, (profile['learning_format'] ?? AppLocalizations.of(context)!.academyFormatUnspecified).toString())),
              ])),
            ]))),
            if (matches.isEmpty) Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(AppLocalizations.of(context)!.academyPersonalizationPending, style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(AppLocalizations.of(context)!.academyProfileHint),
              const SizedBox(height: 8),
              Text(AppLocalizations.of(context)!.academyIntroAvailable, style: Theme.of(context).textTheme.bodySmall),
            ]))),
            if (matches.isNotEmpty) ...[
              const SizedBox(height: 8), Text(AppLocalizations.of(context)!.academyRecommendedPaths, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: selected?.occupation['id'] as String?, isExpanded: true,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.academyOccupationLabel, prefixIcon: const Icon(Icons.work_outline)),
                items: matches.map((m) => DropdownMenuItem<String>(value: m.occupation['id'].toString(), child: Text('${m.occupation['canonical_title']?[locale] ?? m.occupation['canonical_title']?['fr'] ?? m.occupation['id']} · ${m.score}%', overflow: TextOverflow.ellipsis))).toList(),
                onChanged: (v) => setState(() => selectedOccupationId = v),
              ),
              if (selected != null) _AcademyOccupationCard(match: selected, locale: locale),
            ],
            const SizedBox(height: 14),
            Text(AppLocalizations.of(context)!.academyIntroPaths, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(AppLocalizations.of(context)!.academyDraftNotice),
            for (final course in localizedCourses) _AcademyCourseCard(course: course, onChanged: () => setState(() {})),
            const SizedBox(height: 12),
            Card(child: Padding(padding: const EdgeInsets.all(12), child: Text(AppLocalizations.of(context)!.academyProgressNote))),
          ]);
        },
      );
    },
  );
}

class _AcademyOccupationCard extends StatelessWidget {
  final OrientationMatch match;
  final String locale;
  const _AcademyOccupationCard({required this.match, required this.locale});
  @override Widget build(BuildContext context) {
    final o = match.occupation;
    final id = (o['id'] ?? '').toString();
    final title = (o['canonical_title']?[locale] ?? o['canonical_title']?['fr'] ?? id).toString();
    final pathway = match.pathway;
    final text = (pathway['pathway_$locale'] ?? pathway['pathway_fr'] ?? '').toString();
    final notes = (pathway['notes_$locale'] ?? pathway['notes_fr'] ?? '').toString();
    return Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Icon(Icons.flag_outlined), const SizedBox(width: 8), Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))), Chip(label: Text('Match ${match.score}%'))]),
      Text(AppLocalizations.of(context)!.academyIndicativeNote, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
      const SizedBox(height: 8),
      Text(text.isEmpty ? AppLocalizations.of(context)!.academyNoPathway : text),
      if (notes.isNotEmpty) ...[const SizedBox(height: 6), Text(notes, style: const TextStyle(fontSize: 12))],
      const SizedBox(height: 8),
      Text(AppLocalizations.of(context)!.academySharedId(id), style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
      if (pathway['country_validation_required'] == true || (pathway['country_scope'] ?? '').toString().contains('global'))
        Padding(padding: const EdgeInsets.only(top: 6), child: Text(AppLocalizations.of(context)!.academyCountryValidation, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
    ])));
  }
}

class _AcademyCourseCard extends StatelessWidget {
  final Map<String, dynamic> course; final VoidCallback onChanged;
  const _AcademyCourseCard({required this.course, required this.onChanged});
  @override Widget build(BuildContext context) {
    final modules = (course['modules'] as List? ?? const []).cast<Map>();
    final lessons = modules.expand((m) => (m['lessons'] as List? ?? const [])).toList();
    final viewed = lessons.where((l) => AcademyBridge.viewedLessons.contains((l['id'] ?? '').toString())).length;
    final total = lessons.length;
    final rawLevel = (course['level'] ?? '').toString();
    final l10n = AppLocalizations.of(context)!;
    final level = rawLevel == 'beginner' ? l10n.academyLevelBeginner : rawLevel == 'intermediate' ? l10n.academyLevelIntermediate : rawLevel == 'advanced' ? l10n.academyLevelAdvanced : rawLevel;
    return Card(margin: const EdgeInsets.only(top: 8), child: ExpansionTile(
      leading: const Icon(Icons.menu_book_outlined),
      title: Text((course['title'] ?? l10n.academyCourseFallback).toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('$level · ${course['estimated_hours'] ?? '?'} ${l10n.academyEstimatedHours} · ${l10n.academyViewedCount(viewed, total)}'),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      children: [
        Align(alignment: Alignment.centerLeft, child: Chip(label: Text((course['status'] ?? 'draft') == 'draft' ? AppLocalizations.of(context)!.academyPrototypeDraft : course['status'].toString()))),
        for (final outcome in (course['learning_outcomes'] as List? ?? const [])) ListTile(dense: true, contentPadding: EdgeInsets.zero, leading: const Icon(Icons.check_circle_outline, size: 18), title: Text(outcome.toString())),
        for (final module in modules) ...[
          Align(alignment: Alignment.centerLeft, child: Padding(padding: const EdgeInsets.only(top: 8, bottom: 4), child: Text((module['title'] ?? AppLocalizations.of(context)!.academyModuleFallback).toString(), style: const TextStyle(fontWeight: FontWeight.bold)))),
          for (final lesson in (module['lessons'] as List? ?? const [])) _AcademyLessonTile(lesson: Map<String, dynamic>.from(lesson as Map), onChanged: onChanged),
        ],
      ],
    ));
  }
}

class _AcademyLessonTile extends StatelessWidget {
  final Map<String, dynamic> lesson; final VoidCallback onChanged;
  const _AcademyLessonTile({required this.lesson, required this.onChanged});
  @override Widget build(BuildContext context) {
    final id = (lesson['id'] ?? '').toString();
    final viewed = AcademyBridge.viewedLessons.contains(id);
    return ListTile(
      contentPadding: EdgeInsets.zero, leading: Icon(viewed ? Icons.visibility : Icons.play_circle_outline),
      title: Text((lesson['title'] ?? AppLocalizations.of(context)!.academyLessonFallback).toString()), subtitle: Text((lesson['objective'] ?? AppLocalizations.of(context)!.academyObjectivePending).toString()),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => showDialog<void>(context: context, builder: (dialogContext) => AlertDialog(
        title: Text((lesson['title'] ?? AppLocalizations.of(context)!.academyLessonFallback).toString()),
        content: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(AppLocalizations.of(context)!.academyLessonObjective, style: TextStyle(fontWeight: FontWeight.bold)), Text((lesson['objective'] ?? AppLocalizations.of(context)!.academyObjectivePending).toString()),
          const SizedBox(height: 12), Text(AppLocalizations.of(context)!.academyLessonActivity, style: TextStyle(fontWeight: FontWeight.bold)), Text((lesson['activity'] ?? AppLocalizations.of(context)!.academyActivityPending).toString()),
          const SizedBox(height: 12), Text(AppLocalizations.of(context)!.academyLessonAssessment, style: TextStyle(fontWeight: FontWeight.bold)), Text((lesson['assessment'] ?? AppLocalizations.of(context)!.academyAssessmentPending).toString()),
        ])),
        actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(AppLocalizations.of(context)!.academyClose)), FilledButton(onPressed: () { AcademyBridge.markViewed(id); Navigator.pop(dialogContext); onChanged(); }, child: Text(viewed ? AppLocalizations.of(context)!.academyReviewLesson : AppLocalizations.of(context)!.academyMarkViewed))],
      )),
    );
  }
}

