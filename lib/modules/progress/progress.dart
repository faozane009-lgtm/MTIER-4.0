part of '../../main.dart';

class ProgressBridge {
  static List<Map<String, dynamic>> get objectives => AppState.instance.goals;
  static List<Map<String, dynamic>> get evidence => AppState.instance.evidence;
  static List<Map<String, dynamic>> get journal => AppState.instance.journal;
}

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});
  @override State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  final objectiveController = TextEditingController();
  final evidenceController = TextEditingController();
  final journalController = TextEditingController();
  String objectiveStatus = 'in_progress';
  String objectiveType = 'learning';
  String? objectiveOccupationId;

  @override void dispose() {
    objectiveController.dispose(); evidenceController.dispose(); journalController.dispose(); super.dispose();
  }

  String _title(Map<String, dynamic> occupation) =>
    (occupation['canonical_title']?[AppState.instance.language] ?? occupation['canonical_title']?['fr'] ?? occupation['id'] ?? AppLocalizations.of(context)!.progressTitleFallback).toString();

  String _shortTimestamp(Map<String, dynamic> entry) {
    final value = (entry['created_at'] ?? '').toString();
    return value.length > 16 ? value.substring(0, 16) : value;
  }

  Future<bool> _confirmDelete(String title) async => await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(AppLocalizations.of(context)!.progressDeleteConfirmation),
      content: Text('${AppLocalizations.of(context)!.progressDeletePrompt} ($title)'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(AppLocalizations.of(context)!.commonCancel)),
        FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(AppLocalizations.of(context)!.commonDelete)),
      ],
    ),
  ) ?? false;

  Future<void> _deleteEntry(List<Map<String, dynamic>> source, Map<String, dynamic> entry, String title) async {
    if (!await _confirmDelete(title) || !mounted) return;
    setState(() => source.remove(entry));
    AppState.instance.commit();
  }

  Future<void> _editEntry(Map<String, dynamic> entry, String field) async {
    final controller = TextEditingController(text: (entry[field] ?? '').toString());
    final l10n = AppLocalizations.of(context)!;
    final updated = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.commonEdit),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: field == 'title' ? 120 : 500,
          maxLines: 3,
          decoration: InputDecoration(labelText: l10n.progressEditContent),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, controller.text.trim()), child: Text(l10n.commonSave)),
        ],
      ),
    );
    controller.dispose();
    if (updated == null || updated.isEmpty || !mounted) return;
    setState(() => entry[field] = updated);
    AppState.instance.commit();
  }

  @override Widget build(BuildContext context) => FutureBuilder<ExplorerData>(
    future: ExplorerData.shared,
    builder: (context, snapshot) {
      if (snapshot.hasError) return _LoadState(message: AppLocalizations.of(context)!.progressLoadError, error: snapshot.error.toString(), retry: () { ExplorerData.retry(); setState(() {}); });
      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
      final explorer = snapshot.data!;
      final profile = ProfileBridge.current;
      final matches = OrientationEngine.rank(explorer, profile).where((m) => m.score > 0).take(5).toList();
      final viewedCount = AcademyBridge.viewedLessons.length;
      final completedObjectives = ProgressBridge.objectives.where((o) => o['status'] == 'completed').length;
      final activeObjectives = ProgressBridge.objectives.where((o) => o['status'] == 'in_progress').length;
      return ListView(padding: const EdgeInsets.all(16), children: [
        Text(AppLocalizations.of(context)!.progressTitle, style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text(AppLocalizations.of(context)!.progressIntro),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(AppLocalizations.of(context)!.progressOverview, style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _ProgressMetric(label: AppLocalizations.of(context)!.progressMetricLessons, value: '$viewedCount'),
            _ProgressMetric(label: AppLocalizations.of(context)!.progressMetricActiveGoals, value: '$activeObjectives'),
            _ProgressMetric(label: AppLocalizations.of(context)!.progressMetricCompletedGoals, value: '$completedObjectives'),
            _ProgressMetric(label: AppLocalizations.of(context)!.progressMetricEvidence, value: '${ProgressBridge.evidence.length}'),
          ]),
          const SizedBox(height: 8),
          Text(AppLocalizations.of(context)!.progressLocalStorageNote, style: Theme.of(context).textTheme.bodySmall),
        ]))),
        _ProfileCard(title: AppLocalizations.of(context)!.progressGoalsSection, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(controller: objectiveController, maxLength: 120, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.progressAddGoal, hintText: AppLocalizations.of(context)!.progressGoalTitle)),
          const SizedBox(height: 6),
          if (matches.isNotEmpty) DropdownButtonFormField<String>(value: objectiveOccupationId, isExpanded: true, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.progressAssociatedOccupation), items: [DropdownMenuItem<String>(value: null, child: Text(AppLocalizations.of(context)!.progressNoOccupation)), ...matches.map((m) => DropdownMenuItem<String>(value: m.occupation['id'].toString(), child: Text(_title(m.occupation), overflow: TextOverflow.ellipsis)))], onChanged: (v) => setState(() => objectiveOccupationId = v)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(value: objectiveType, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.progressGoalType), items: [DropdownMenuItem(value: 'career', child: Text(AppLocalizations.of(context)!.progressTypeCareer)), DropdownMenuItem(value: 'learning', child: Text(AppLocalizations.of(context)!.progressTypeLearning)), DropdownMenuItem(value: 'skill', child: Text(AppLocalizations.of(context)!.progressTypeSkill)), DropdownMenuItem(value: 'project', child: Text(AppLocalizations.of(context)!.progressTypeProject))], onChanged: (v) => setState(() => objectiveType = v ?? 'learning')),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(value: objectiveStatus, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.progressGoalStatus), items: [DropdownMenuItem(value: 'in_progress', child: Text(AppLocalizations.of(context)!.progressStatusInProgress)), DropdownMenuItem(value: 'paused', child: Text(AppLocalizations.of(context)!.progressStatusPaused))], onChanged: (v) => setState(() => objectiveStatus = v ?? 'in_progress')),
          const SizedBox(height: 8),
          FilledButton.icon(onPressed: () { final value = objectiveController.text.trim(); if (value.isEmpty) return; setState(() { ProgressBridge.objectives.add(Goal(id:'local-${DateTime.now().microsecondsSinceEpoch}', title:value, type:GoalType.values.firstWhere((type) => type.name == objectiveType), status:objectiveStatus == 'paused' ? GoalStatus.paused : GoalStatus.inProgress, occupationId:objectiveOccupationId, createdAt:DateTime.now().toUtc()).toJson()); objectiveController.clear(); AppState.instance.commit(); }); }, icon: const Icon(Icons.add), label: Text(AppLocalizations.of(context)!.progressAddGoalButton)),
          if (ProgressBridge.objectives.isEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text(AppLocalizations.of(context)!.progressNoGoals)),
          for (final objective in ProgressBridge.objectives) Card(margin: const EdgeInsets.only(top: 8), child: ListTile(
            leading: Icon(objective['status'] == 'completed' ? Icons.check_circle : objective['status'] == 'paused' ? Icons.pause_circle_outline : Icons.flag_outlined),
            title: Text(objective['title'].toString()),
            subtitle: Text('${objective['status'] == 'completed' ? AppLocalizations.of(context)!.progressStatusCompleted : objective['status'] == 'paused' ? AppLocalizations.of(context)!.progressStatusPaused : AppLocalizations.of(context)!.progressStatusInProgress}${objective['occupation_id'] == null ? '' : ' · ${objective['occupation_id']}'}'),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              PopupMenuButton<String>(onSelected: (v) { setState(() => objective['status'] = v); AppState.instance.commit(); }, itemBuilder: (_) => [PopupMenuItem(value:'in_progress', child:Text(AppLocalizations.of(context)!.progressStatusInProgress)), PopupMenuItem(value:'paused', child:Text(AppLocalizations.of(context)!.progressStatusPause)), PopupMenuItem(value:'completed', child:Text(AppLocalizations.of(context)!.progressStatusComplete)), PopupMenuItem(value:'archived', child:Text(AppLocalizations.of(context)!.progressStatusArchive))]),
              IconButton(tooltip: AppLocalizations.of(context)!.commonEdit, onPressed: () => _editEntry(objective, 'title'), icon: const Icon(Icons.edit_outlined)),
              IconButton(tooltip: AppLocalizations.of(context)!.progressDeleteGoal, onPressed: () => _deleteEntry(ProgressBridge.objectives, objective, (objective['title'] ?? 'objectif').toString()), icon: const Icon(Icons.delete_outline)),
            ]),
          )),
        ])),
        _ProfileCard(title: AppLocalizations.of(context)!.progressAcademySection, child: FutureBuilder<AcademyData>(
          future: AcademyData.shared,
          builder: (context, academySnapshot) {
            final lessonTitles = <String, String>{};
            if (academySnapshot.hasData) {
              for (final course in academySnapshot.data!.courses) {
                final localizedCourse = AcademyData.localizedCourse(course, AppState.instance.language);
                for (final module in (localizedCourse['modules'] as List? ?? const [])) {
                  for (final lesson in (module['lessons'] as List? ?? const [])) {
                    if (lesson is Map) lessonTitles[(lesson['id'] ?? '').toString()] = (lesson['title'] ?? lesson['id'] ?? '').toString();
                  }
                }
              }
            }
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('$viewedCount ${AppLocalizations.of(context)!.progressLessonsViewed}'),
              if (AcademyBridge.viewedLessons.isEmpty) Text(AppLocalizations.of(context)!.progressStartAcademy),
              for (final id in AcademyBridge.viewedLessons) ListTile(dense: true, contentPadding: EdgeInsets.zero, leading: const Icon(Icons.menu_book_outlined), title: Text(lessonTitles[id] ?? id), subtitle: Text(AppState.instance.viewedLessonTimestamps[id]?.isNotEmpty == true ? '${AppLocalizations.of(context)!.progressViewedOn} ${AppState.instance.viewedLessonTimestamps[id]}' : AppLocalizations.of(context)!.progressViewedInAcademy)),
            ]);
          },
        )),
        _ProfileCard(title: AppLocalizations.of(context)!.progressMatchSection, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${(profile['skills'] as List? ?? const []).length} ${AppLocalizations.of(context)!.progressMatchSummary} ${matches.length}'),
          if (matches.isEmpty) Text(AppLocalizations.of(context)!.progressNoMatch),
          for (final match in matches.take(3)) ExpansionTile(title: Text(_title(match.occupation)), subtitle: Text('${AppLocalizations.of(context)!.progressMatchScore} ${match.score}%'), children: [
            if (match.gaps.isEmpty) ListTile(title: Text(AppLocalizations.of(context)!.progressNoGaps))
            else ...match.gaps.map((gap) => ListTile(dense: true, leading: const Icon(Icons.lightbulb_outline), title: Text(gap), subtitle: Text(AppLocalizations.of(context)!.progressGapDisclaimer))),
          ]),
        ])),
        _ProfileCard(title: AppLocalizations.of(context)!.progressEvidenceSection, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(AppLocalizations.of(context)!.progressEvidenceHint),
          const SizedBox(height: 8), TextField(controller: evidenceController, maxLength: 500, maxLines: 3, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.progressAddEvidence)),
          const SizedBox(height: 8), FilledButton.icon(onPressed: () { final value = evidenceController.text.trim(); if (value.isEmpty) return; setState(() { ProgressBridge.evidence.add({'description':value, 'created_at':DateTime.now().toIso8601String(), 'visibility':'private'}); evidenceController.clear(); AppState.instance.commit(); }); }, icon: const Icon(Icons.add), label: Text(AppLocalizations.of(context)!.progressEvidencePrivate)),
          for (final item in ProgressBridge.evidence) ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.folder_outlined), title: Text(item['description'].toString()), subtitle: Text(AppLocalizations.of(context)!.progressPrivateEvidence), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(tooltip: AppLocalizations.of(context)!.commonEdit, onPressed: () => _editEntry(item, 'description'), icon: const Icon(Icons.edit_outlined)), IconButton(tooltip: AppLocalizations.of(context)!.progressDeleteEvidence, onPressed: () => _deleteEntry(ProgressBridge.evidence, item, AppLocalizations.of(context)!.progressDeleteEvidence), icon: const Icon(Icons.delete_outline))])),
        ])),
        _ProfileCard(title: AppLocalizations.of(context)!.progressJournalSection, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(controller: journalController, maxLength: 500, maxLines: 3, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.progressJournalHint)),
          const SizedBox(height: 8), OutlinedButton.icon(onPressed: () { final value = journalController.text.trim(); if (value.isEmpty) return; setState(() { ProgressBridge.journal.insert(0, {'note':value, 'created_at':DateTime.now().toIso8601String()}); journalController.clear(); AppState.instance.commit(); }); }, icon: const Icon(Icons.edit_note), label: Text(AppLocalizations.of(context)!.progressAddJournal)),
          for (final note in ProgressBridge.journal) ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.notes), title: Text(note['note'].toString()), subtitle: Text(_shortTimestamp(note)), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(tooltip: AppLocalizations.of(context)!.commonEdit, onPressed: () => _editEntry(note, 'note'), icon: const Icon(Icons.edit_outlined)), IconButton(tooltip: AppLocalizations.of(context)!.progressDeleteNote, onPressed: () => _deleteEntry(ProgressBridge.journal, note, AppLocalizations.of(context)!.progressDeleteNote), icon: const Icon(Icons.delete_outline))])),
        ])),
        _ProfileCard(title: AppLocalizations.of(context)!.profilePrivacy, child: Text(AppLocalizations.of(context)!.progressPrivateNote)),
        const SizedBox(height: 8),
        Text(AppLocalizations.of(context)!.progressDataContract, style: Theme.of(context).textTheme.bodySmall),
      ]);
    },
  );
}

class _ProgressMetric extends StatelessWidget {
  final String label, value;
  const _ProgressMetric({required this.label, required this.value});
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)), Text(label, style: Theme.of(context).textTheme.bodySmall)]));
}

