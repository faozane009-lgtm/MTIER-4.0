part of '../../main.dart';

class MatchReason {
  final String code;
  final String value;
  const MatchReason(this.code, [this.value = '']);
}

class OrientationMatch {
  final Map<String, dynamic> occupation;
  final int score;
  final List<MatchReason> reasons;
  final List<String> gaps;
  final Map<String, dynamic> pathway;
  final Map<String, dynamic> outlook;
  const OrientationMatch({required this.occupation, required this.score, required this.reasons, required this.gaps, required this.pathway, required this.outlook});
}

class OrientationEngine {
  static String norm(String value) => TextNormalizer.normalize(value);

  static List<String> _tokens(String value) => TextNormalizer.tokens(value);

  static List<OrientationMatch> rank(ExplorerData data, Map<String, dynamic> profile) {
    final interests = (profile['interest_domains'] as List? ?? const []).map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
    final skills = (profile['skills'] as List? ?? const []).map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
    final goals = AppState.instance.goals.where((goal) => const ['in_progress', 'paused'].contains(goal['status'])).map((goal) => (goal['title'] ?? '').toString()).where((title) => title.trim().isNotEmpty).toList();
    final followed = (profile['followed_occupation_ids'] as List? ?? const []).map((e) => e.toString()).toSet();
    final active = (interests.isNotEmpty ? 30 : 0) + (skills.isNotEmpty ? 45 : 0) + (goals.isNotEmpty ? 10 : 0) + (followed.isNotEmpty ? 15 : 0);
    if (active == 0) return const [];

    final results = <OrientationMatch>[];
    for (final occupation in data.occupations) {
      final id = (occupation['id'] ?? '').toString();
      final detail = data.profiles[id] ?? <String, dynamic>{};
      final title = (occupation['canonical_title']?[AppState.instance.language] ?? occupation['canonical_title']?['fr'] ?? '').toString();
      final domainLabels = data.domainNames[(occupation['domain_id'] ?? '').toString()] ?? const <String, String>{};
      final domain = domainLabels[AppState.instance.language] ?? domainLabels['fr'] ?? '';
      final familyLabels = data.familyNames[(occupation['family_id'] ?? '').toString()] ?? const <String, String>{};
      final family = familyLabels[AppState.instance.language] ?? familyLabels['fr'] ?? (occupation['family_id'] ?? '').toString().replaceAll(RegExp(r'[_\-.]'), ' ');
      final aliases = (occupation['aliases'] as List? ?? const []).join(' ');
      final description = (occupation['definition']?[AppState.instance.language] ?? occupation['definition']?['fr'] ?? '').toString();
      final searchText = norm('$title $domain $family $aliases $description ${occupation['domain_id']}');
      final rawProfileSkills = detail['skills_${AppState.instance.language}'] as List? ?? detail['skills'] as List? ?? occupation['skills'] as List? ?? const [];
      final List<String> profileSkills = rawProfileSkills.map<String>((e) {
        if (e is Map) return (e['id'] ?? e['name'] ?? '').toString();
        if (e is List && e.isNotEmpty) return e.first.toString();
        return e.toString();
      }).where((e) => e.isNotEmpty).toList();
      final normalizedSkills = profileSkills.map(norm).toList();
      final matchedSkills = skills.where((skill) => normalizedSkills.any((candidate) => TextNormalizer.containsPhrase(candidate, norm(skill)) || TextNormalizer.containsPhrase(norm(skill), candidate))).toList();
      final skillScore = skills.isEmpty ? 0.0 : matchedSkills.length / skills.length;
      final interestHits = interests.where((interest) {
        final n = norm(interest);
        final words = _tokens(interest);
        return TextNormalizer.containsPhrase(searchText, n) || (words.isNotEmpty && words.any((word) => TextNormalizer.containsPhrase(searchText, word)));
      }).toList();
      final interestScore = interests.isEmpty ? 0.0 : interestHits.length / interests.length;
      final goalHits = goals.where((goal) {
        final words = _tokens(goal);
        return words.isNotEmpty && words.any((word) => TextNormalizer.containsPhrase(searchText, word));
      }).toList();
      final goalScore = goals.isEmpty ? 0.0 : goalHits.length / goals.length;
      final isFollowed = followed.contains(id);
      final raw = (skillScore * (skills.isEmpty ? 0 : 45)) + (interestScore * (interests.isEmpty ? 0 : 30)) + (goalScore * (goals.isEmpty ? 0 : 10)) + (isFollowed ? 15 : 0);
      final score = raw.round().clamp(0, 100).toInt();
      final reasons = <MatchReason>[];
      if (matchedSkills.isNotEmpty) reasons.add(MatchReason('skills', matchedSkills.join(', ')));
      if (interestHits.isNotEmpty) reasons.add(MatchReason('interest', interestHits.join(', ')));
      if (goalHits.isNotEmpty) reasons.add(MatchReason('goal', goalHits.join(', ')));
      if (isFollowed) reasons.add(const MatchReason('followed'));
      final gaps = profileSkills.where((skill) => !skills.any((value) => TextNormalizer.containsPhrase(norm(value), norm(skill)) || TextNormalizer.containsPhrase(norm(skill), norm(value)))).take(5).map(ExplorerData.displaySlug).toList();
      if (reasons.isEmpty) reasons.add(const MatchReason('weak'));
      final education = (profile['education_level'] ?? '').toString();
      if (education.isNotEmpty) reasons.add(MatchReason('education', education));
      results.add(OrientationMatch(occupation: occupation, score: score, reasons: reasons, gaps: gaps, pathway: data.pathways[id] ?? const {}, outlook: data.outlook[id] ?? const {}));
    }
    results.sort((a, b) => b.score.compareTo(a.score));
    return results;
  }
}

class OrientationPage extends StatelessWidget {
  const OrientationPage({super.key});
  @override Widget build(BuildContext context) => FutureBuilder<ExplorerData>(
    future: ExplorerData.shared,
    builder: (context, snapshot) {
      if (snapshot.hasError) return Center(child: Padding(padding: const EdgeInsets.all(20), child: Text('${AppLocalizations.of(context)!.matchLoadError}\n${snapshot.error}', textAlign: TextAlign.center)));
      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
      final data = snapshot.data!;
      final profile = ProfileBridge.current;
      final results = OrientationEngine.rank(data, profile);
      final hasActiveGoals = AppState.instance.goals.any((goal) => const ['in_progress', 'paused'].contains(goal['status']));
      final hasInputs = (profile['interest_domains'] as List? ?? const []).isNotEmpty || (profile['skills'] as List? ?? const []).isNotEmpty || hasActiveGoals || (profile['followed_occupation_ids'] as List? ?? const []).isNotEmpty;
      final relevantResults = results.where((r) => r.score > 0).toList();
      return ListView(padding: const EdgeInsets.all(16), children: [
        Text(AppLocalizations.of(context)!.matchTitle, style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(AppLocalizations.of(context)!.matchIntro),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
          const Icon(Icons.hub_outlined, size: 30), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(AppLocalizations.of(context)!.matchSources, style: TextStyle(fontWeight: FontWeight.bold)),
            Text(AppLocalizations.of(context)!.matchSourceSummary(data.occupations.length, (profile['skills'] as List? ?? const []).length, (profile['interest_domains'] as List? ?? const []).length, AppState.instance.goals.length)),
          ])),
        ]))),
        if (!hasInputs) Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          const Icon(Icons.person_search_outlined, size: 42), const SizedBox(height: 8),
          Text(AppLocalizations.of(context)!.matchProfileIncomplete, style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6), Text(AppLocalizations.of(context)!.matchProfileHint),
        ]))) else ...[
          Text(AppLocalizations.of(context)!.matchResultsSummary(results.length, relevantResults.length), style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          if (relevantResults.isEmpty) Card(child: Padding(padding: const EdgeInsets.all(14), child: Text(AppLocalizations.of(context)!.matchNoResults))),
          for (var i = 0; i < relevantResults.take(12).length; i++) _OrientationCard(match: relevantResults[i], rank: i + 1, locale: AppState.instance.language),
          const SizedBox(height: 8),
          Text(AppLocalizations.of(context)!.matchMethod, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(AppLocalizations.of(context)!.matchScoreDisclaimer, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ]);
    },
  );
}

class _OrientationCard extends StatelessWidget {
  final OrientationMatch match; final int rank; final String locale;
  const _OrientationCard({required this.match, required this.rank, required this.locale});

  String _reasonLabel(BuildContext context, MatchReason reason) {
    final l10n = AppLocalizations.of(context)!;
    return switch (reason.code) {
      'skills' => l10n.matchReasonSkills(reason.value),
      'interest' => l10n.matchReasonInterest(reason.value),
      'goal' => l10n.matchReasonGoal(reason.value),
      'followed' => l10n.matchReasonFollowed,
      'education' => l10n.matchReasonEducation(reason.value),
      _ => l10n.matchReasonWeak,
    };
  }

  @override Widget build(BuildContext context) {
    final o = match.occupation;
    final title = (o['canonical_title']?[locale] ?? o['canonical_title']?['fr'] ?? o['canonical_title']?['en'] ?? 'Métier').toString();
    final pathway = (match.pathway['pathway_$locale'] ?? match.pathway['pathway_fr'] ?? '').toString();
    final outlook = (match.outlook['qualitative_outlook_$locale'] ?? match.outlook['qualitative_outlook_fr'] ?? '').toString();
    return Card(margin: const EdgeInsets.only(bottom: 10), child: ExpansionTile(
      leading: CircleAvatar(child: Text('$rank')),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 5), LinearProgressIndicator(value: match.score / 100),
        const SizedBox(height: 4), Text(AppLocalizations.of(context)!.matchScore(match.score)),
      ]),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        Align(alignment: Alignment.centerLeft, child: Text(AppLocalizations.of(context)!.matchWhy, style: Theme.of(context).textTheme.titleSmall)),
        for (final reason in match.reasons) ListTile(dense: true, contentPadding: EdgeInsets.zero, leading: const Icon(Icons.check_circle_outline, size: 18), title: Text(_reasonLabel(context, reason))),
        if (match.gaps.isNotEmpty) ...[
          Align(alignment: Alignment.centerLeft, child: Text(AppLocalizations.of(context)!.matchSkillGaps, style: Theme.of(context).textTheme.titleSmall)),
          Text(match.gaps.join(' · ')),
        ],
        if (pathway.isNotEmpty) ...[const SizedBox(height: 8), Align(alignment: Alignment.centerLeft, child: Text(AppLocalizations.of(context)!.matchPathway, style: Theme.of(context).textTheme.titleSmall)), Text(pathway)],
        if (outlook.isNotEmpty) ...[const SizedBox(height: 8), Align(alignment: Alignment.centerLeft, child: Text(AppLocalizations.of(context)!.matchOutlook, style: Theme.of(context).textTheme.titleSmall)), Text(outlook)],
        const SizedBox(height: 8), Align(alignment: Alignment.centerLeft, child: Text(AppLocalizations.of(context)!.matchSharedId((o['id'] ?? '').toString()), style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant))),
      ],
    ));
  }
}

