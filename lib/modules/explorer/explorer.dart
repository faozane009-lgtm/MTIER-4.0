part of '../../main.dart';

class ExplorerData {
  static Future<ExplorerData>? _shared;
  static Future<ExplorerData> get shared => _shared ??= load();

  /// Clears a previously cached load and starts a fresh asset read.
  static Future<ExplorerData> retry() {
    _shared = null;
    return shared;
  }

  final List<Map<String, dynamic>> occupations;
  final Map<String, Map<String, dynamic>> profiles, pathways, outlook, salary, classifications;
  final Map<String, Map<String, String>> domainNames;
  final Map<String, Map<String, String>> familyNames;
  final List<String> loadErrors;

  ExplorerData(
    this.occupations,
    this.profiles,
    this.pathways,
    this.outlook,
    this.salary,
    this.classifications,
    this.domainNames, {
    this.familyNames = const {},
    this.loadErrors = const [],
  });

  static Future<Map<String, dynamic>?> _readObject(
    String path,
    List<String> errors,
  ) async {
    try {
      final decoded = jsonDecode(await rootBundle.loadString(path));
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      throw const FormatException('Le fichier JSON ne contient pas un objet.');
    } catch (error) {
      final message = '$path : $error';
      errors.add(message);
      if (kDebugMode) debugPrint('[M-TIER][Explorer] $message');
      return null;
    }
  }

  static Map<String, dynamic> _normalizeProfile(Map raw) {
    final profile = Map<String, dynamic>.from(raw);
    final hadCanonicalOccupationId = profile.containsKey('occupation_id');
    final occupationId = (profile['occupation_id'] ?? profile['id'] ?? '').toString();
    if (occupationId.isNotEmpty) profile['occupation_id'] = occupationId;
    // Only the cybersecurity source uses `id` as its occupation key.
    if (!hadCanonicalOccupationId) profile.remove('id');

    final rawSkills = profile['skills'];
    if (rawSkills is List) {
      profile['skills'] = rawSkills.map((entry) {
        if (entry is List && entry.isNotEmpty) {
          return <String, dynamic>{
            'id': entry.first.toString(),
            if (entry.length > 1) 'type': entry[1].toString(),
          };
        }
        if (entry is Map) return Map<String, dynamic>.from(entry);
        return <String, dynamic>{'id': entry.toString()};
      }).toList();
    }

    final rawEvidence = profile['evidence'];
    if (rawEvidence is List) {
      profile['evidence'] = rawEvidence.map((entry) {
        if (entry is List && entry.isNotEmpty) {
          return <String, dynamic>{
            'source_id': entry.first.toString(),
            if (entry.length > 1) 'use': entry[1].toString(),
          };
        }
        if (entry is Map) return Map<String, dynamic>.from(entry);
        return <String, dynamic>{'source_id': entry.toString()};
      }).toList();
    }
    return profile;
  }

  static String displaySlug(String value) {
    final words = value
        .replaceAll(RegExp(r'[_\-.]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (words.isEmpty) return value;
    return words[0].toUpperCase() + words.substring(1);
  }

  static String displaySkill(dynamic value, {String locale = 'fr'}) {
    String id = '';
    String type = '';
    if (value is Map) {
      id = (value['id'] ?? value['name'] ?? '').toString();
      type = (value['type'] ?? '').toString();
    } else if (value is List && value.isNotEmpty) {
      id = value.first.toString();
      if (value.length > 1) type = value[1].toString();
    } else {
      id = value.toString();
    }
    final label = displaySlug(id);
    if (type.isEmpty) return label;
    final typeLabel = switch (type) {
      'technical' => switch (locale) { 'en' => 'technical', 'es' => 'técnica', _ => 'technique' },
      'transferable' => switch (locale) { 'en' => 'transferable', 'es' => 'transferible', _ => 'transférable' },
      _ => type,
    };
    return '$label · $typeLabel';
  }

  static Future<ExplorerData> load() async {
    final errors = <String>[];

    final seed = await _readObject(
      'assets/explorer/occupations/occupation_seed_fr_en.json', errors);
    final taxonomy = await _readObject(
      'assets/explorer/explorer_taxonomy.json', errors);

    final domainNames = <String, Map<String, String>>{};
    final familyNames = <String, Map<String, String>>{};
    final rawDomains = taxonomy?['domains'];
    if (rawDomains is List) {
      for (final rawDomain in rawDomains) {
        if (rawDomain is! Map) continue;
        final id = (rawDomain['id'] ?? '').toString();
        final names = <String, String>{
          'fr': (rawDomain['name_fr'] ?? '').toString(),
          'en': (rawDomain['name_en'] ?? '').toString(),
          'es': (rawDomain['name_es'] ?? '').toString(),
        }..removeWhere((_, value) => value.isEmpty);
        if (id.isNotEmpty && names.isNotEmpty) domainNames[id] = names;
        final rawFamilies = rawDomain['families'];
        if (rawFamilies is List) {
          for (final rawFamily in rawFamilies) {
            if (rawFamily is! Map) continue;
            final familyId = (rawFamily['id'] ?? '').toString();
            final familyLabels = <String, String>{
              'fr': (rawFamily['name_fr'] ?? '').toString(),
              'en': (rawFamily['name_en'] ?? '').toString(),
              'es': (rawFamily['name_es'] ?? '').toString(),
            }..removeWhere((_, value) => value.isEmpty);
            if (familyId.isNotEmpty && familyLabels.isNotEmpty) {
              familyNames[familyId] = familyLabels;
            }
          }
        }
      }
    }

    final occupations = <Map<String, dynamic>>[];
    final rawOccupations = seed?['records'];
    if (rawOccupations is List) {
      for (final raw in rawOccupations) {
        if (raw is Map) occupations.add(Map<String, dynamic>.from(raw));
      }
    } else {
      errors.add('Le catalogue seed ne contient pas de liste records valide.');
    }

    final profiles = <String, Map<String, dynamic>>{};
    for (final path in profileAssets) {
      final data = await _readObject(path, errors);
      final rawProfiles = data?['profiles'];
      if (rawProfiles is! List) {
        errors.add('$path : liste profiles absente ou invalide.');
        continue;
      }
      for (final raw in rawProfiles) {
        if (raw is! Map) continue;
        final profile = _normalizeProfile(raw);
        final id = (profile['occupation_id'] ?? '').toString();
        if (id.isNotEmpty) profiles[id] = profile;
      }
    }

    Future<Map<String, Map<String, dynamic>>> index(
      String path,
      String key,
    ) async {
      final data = await _readObject(path, errors);
      final rawRecords = data?[key];
      if (rawRecords is! List) {
        errors.add('$path : liste $key absente ou invalide.');
        return <String, Map<String, dynamic>>{};
      }
      final indexed = <String, Map<String, dynamic>>{};
      for (final raw in rawRecords) {
        if (raw is! Map) continue;
        final id = (raw['occupation_id'] ?? '').toString();
        if (id.isNotEmpty) indexed[id] = Map<String, dynamic>.from(raw);
      }
      return indexed;
    }

    final missingProfiles = occupations
        .map((occupation) => (occupation['id'] ?? '').toString())
        .where((id) => id.isNotEmpty && !profiles.containsKey(id))
        .toList();
    if (kDebugMode) {
      debugPrint('[M-TIER][Explorer] ${occupations.length} métiers, '
          '${profiles.length} profils chargés, ${missingProfiles.length} profil(s) manquant(s).');
      if (missingProfiles.isNotEmpty) {
        debugPrint('[M-TIER][Explorer] Métiers sans profil chargé :\n'
            '${missingProfiles.join('\n')}');
      }
    }

    return ExplorerData(
      occupations,
      profiles,
      await index('assets/explorer/training_pathways_v3.2.json', 'pathways'),
      await index('assets/explorer/employment_outlook_v4.json', 'records'),
      await index('assets/explorer/salary_coverage_by_occupation_v4.json', 'coverage'),
      await index('assets/explorer/classification_review_v4.json', 'records'),
      domainNames,
      familyNames: familyNames,
      loadErrors: errors,
    );
  }
}

class ExplorerPage extends StatefulWidget {
  const ExplorerPage({super.key});
  @override State<ExplorerPage> createState() => _ExplorerPageState();
}
class _ExplorerPageState extends State<ExplorerPage> {
  Future<ExplorerData> future = ExplorerData.shared;
  void _retryExplorer() => setState(() => future = ExplorerData.retry());
  final search = TextEditingController();
  String query = '', domain = 'all';
  String get locale => AppState.instance.language;
  @override void dispose() { search.dispose(); super.dispose(); }

  String get labelSearch => AppLocalizations.of(context)!.explorerSearchLabel;
  @override Widget build(BuildContext context) => FutureBuilder<ExplorerData>(
    future: future,
    builder: (context, snapshot) {
      if (snapshot.hasError) return _LoadState(message: AppLocalizations.of(context)!.explorerLoadError, error: snapshot.error.toString(), retry: _retryExplorer);
      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
      final data = snapshot.data!;
      final domains = data.occupations.map((e) => (e['domain_id'] ?? '').toString()).where((e) => e.isNotEmpty).toSet().toList()..sort();
      final filtered = data.occupations.where((e) {
        final title = (e['canonical_title']?[locale] ?? e['canonical_title']?['fr'] ?? '').toString().toLowerCase();
        final english = (e['canonical_title']?['en'] ?? '').toString().toLowerCase();
        final fr = (e['canonical_title']?['fr'] ?? '').toString().toLowerCase();
        final id = (e['id'] ?? '').toString().toLowerCase();
        final q = query.toLowerCase();
        return (domain == 'all' || e['domain_id'] == domain) && (q.isEmpty || title.contains(q) || fr.contains(q) || english.contains(q) || id.contains(q));
      }).toList()..sort((a,b) => ((a['canonical_title']?[locale] ?? a['canonical_title']?['fr'] ?? '') as String).compareTo((b['canonical_title']?[locale] ?? b['canonical_title']?['fr'] ?? '') as String));
      return Column(children: [
        if (data.loadErrors.isNotEmpty) _PartialDataNotice(count: data.loadErrors.length, onRetry: _retryExplorer),
        Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 8), child: Row(children: [
          Expanded(child: TextField(controller: search, decoration: InputDecoration(prefixIcon: const Icon(Icons.search), labelText: labelSearch), onChanged: (v) => setState(() => query = v))),
          const SizedBox(width: 8),
          DropdownButton<String>(value: locale, underline: const SizedBox(), items: const [DropdownMenuItem(value:'fr',child:Text('FR')),DropdownMenuItem(value:'en',child:Text('EN')),DropdownMenuItem(value:'es',child:Text('ES'))], onChanged: (v) { if (v == null) return; AppState.instance.language = v; AppState.instance.commit(); }),
        ])),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: DropdownButtonFormField<String>(value: domain,
          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.explorerDomain, isDense: true),
          items: [DropdownMenuItem(value: 'all', child: Text(AppLocalizations.of(context)!.explorerAllDomains)), ...domains.map((d) => DropdownMenuItem(value:d, child: Text(data.domainNames[d]?[locale] ?? data.domainNames[d]?['fr'] ?? d)))],
          onChanged: (v) => setState(() => domain = v ?? 'all'))),
        Padding(padding: const EdgeInsets.fromLTRB(16, 10, 16, 4), child: Row(children: [
          Expanded(child: Text(AppLocalizations.of(context)!.explorerCount(filtered.length, data.occupations.length), style: Theme.of(context).textTheme.labelLarge)),
          if (locale != 'fr') Text(AppLocalizations.of(context)!.explorerTranslationDraftStatus, style: const TextStyle(fontSize: 11, color: Colors.deepOrange)),
        ])),
        Expanded(child: filtered.isEmpty ? Center(child: Text(AppLocalizations.of(context)!.explorerNoResults)) : ListView.separated(
          padding: const EdgeInsets.all(16), itemCount: filtered.length, separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final item = filtered[i]; final title = (item['canonical_title']?[locale] ?? item['canonical_title']?['fr'] ?? AppLocalizations.of(context)!.explorerMissingContent).toString();
            final desc = (item['definition']?[locale] ?? item['definition']?['fr'] ?? AppLocalizations.of(context)!.explorerDescriptionMissing).toString();
            final hasProfile = data.profiles.containsKey(item['id']);
            return Card(child: ListTile(isThreeLine: true, title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('$desc\n${hasProfile ? AppLocalizations.of(context)!.explorerProfileAvailable : AppLocalizations.of(context)!.explorerProfilePending}', maxLines: 3, overflow: TextOverflow.ellipsis),
              trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OccupationDetail(item: item, data: data, locale: locale)))));
          })),
      ]);
    },
  );
}

class OccupationDetail extends StatelessWidget {
  final Map<String, dynamic> item; final ExplorerData data; final String locale;
  const OccupationDetail({super.key, required this.item, required this.data, required this.locale});
  @override Widget build(BuildContext context) {
    final id = (item['id'] ?? '').toString(); final p = data.profiles[id] ?? {};
    final title = (item['canonical_title']?[locale] ?? item['canonical_title']?['fr'] ?? AppLocalizations.of(context)!.explorerMissingContent).toString();
    final purpose = (p['purpose_$locale'] ??
        (locale == 'fr' ? p['purpose_fr'] : item['definition']?[locale]) ??
        p['purpose_fr'] ?? item['definition']?['fr'] ??
        AppLocalizations.of(context)!.explorerDescriptionMissing).toString();
    final missions = (p['missions_$locale'] as List? ?? p['missions_fr'] as List? ??
        (item['tasks'] as List? ?? []).where((t) => (t['locale'] ?? 'fr') == 'fr').map((t) => t['text']).toList()).cast<dynamic>();
    final skills = (p['skills_$locale'] as List? ?? p['skills'] as List? ?? item['skills'] as List? ?? []).cast<dynamic>();
    final knowledge = (p['knowledge_$locale'] as List? ?? p['knowledge'] as List? ?? []).cast<dynamic>();
    final pathway = data.pathways[id] ?? {}; final outlook = data.outlook[id] ?? {}; final salary = data.salary[id] ?? {}; final classification = data.classifications[id] ?? {};
    final workContext = (p['work_context_$locale'] ?? p['work_context_fr'] ?? AppLocalizations.of(context)!.explorerWorkContextMissing).toString();
    final pathwayText = (pathway['pathway_$locale'] ?? pathway['pathway_fr'] ?? AppLocalizations.of(context)!.explorerPathwayMissing).toString();
    final outlookText = (outlook['qualitative_outlook_$locale'] ?? outlook['qualitative_outlook_fr'] ?? AppLocalizations.of(context)!.explorerOutlookMissing).toString();
    final sources = (p['evidence'] as List? ?? item['sources'] as List? ?? []).cast<dynamic>();
    final verifiedCountries = (salary['verified_country_estimates'] ?? 0).toString();
    final salaryCountries = (salary['country_count_with_estimate'] ?? 0).toString();
    final salaryText = salary.isEmpty || verifiedCountries == '0' ? AppLocalizations.of(context)!.explorerSalaryUnavailable : '${AppLocalizations.of(context)!.explorerSalaryAvailable(verifiedCountries, salaryCountries)} ${AppLocalizations.of(context)!.explorerSalaryOtherCountries}';
    final l10n = AppLocalizations.of(context)!;
    String classificationStatus(dynamic raw, String fallback) => switch ((raw ?? '').toString()) {
      'candidate_lookup_required' => l10n.explorerNeedsReview,
      'candidate_search_reference' => l10n.explorerReferenceReview,
      '' => fallback,
      _ => raw.toString(),
    };
    String editorialStatus(dynamic raw) => switch ((raw ?? '').toString()) {
      'draft' => l10n.explorerDraftStatus,
      'draft_needs_expert_review' => l10n.explorerExpertReviewRequired,
      '' => l10n.explorerDraftStatus,
      _ => raw.toString(),
    };
    return Scaffold(appBar: AppBar(title: Text(title)), body: ListView(padding: const EdgeInsets.all(16), children: [
      if (locale != 'fr') Card(child: Padding(padding: const EdgeInsets.all(12), child: Text(AppLocalizations.of(context)!.explorerDetailTranslationNotice))),
      _Section(title: AppLocalizations.of(context)!.explorerPresentation, child: Text(purpose)),
      _Section(title: AppLocalizations.of(context)!.explorerMainTasks, child: _bulletList(missions)),
      _Section(title: AppLocalizations.of(context)!.explorerSkills, child: skills.isEmpty ? Text(AppLocalizations.of(context)!.explorerSkillsMissing) : _bulletList(skills.map((skill) => ExplorerData.displaySkill(skill, locale: locale)).toList())),
      _Section(title: AppLocalizations.of(context)!.explorerKnowledge, child: knowledge.isEmpty ? Text(AppLocalizations.of(context)!.explorerKnowledgeMissing) : _bulletList(knowledge)),
      _Section(title: AppLocalizations.of(context)!.explorerWorkEnvironment, child: Text(workContext)),
      _Section(title: AppLocalizations.of(context)!.explorerTrainingPath, child: Text(pathwayText)),
      if ((pathway['notes_$locale'] ?? pathway['notes_fr'] ?? '').toString().isNotEmpty) _Section(title: AppLocalizations.of(context)!.explorerQualifications, child: Text((pathway['notes_$locale'] ?? pathway['notes_fr']).toString())),
      _Section(title: AppLocalizations.of(context)!.explorerOutlook, child: Text(outlookText)),
      _Section(title: AppLocalizations.of(context)!.explorerSalary, child: Text(salaryText)),
      _Section(title: l10n.explorerClassifications, child: Text('${l10n.explorerEsco}: ${classificationStatus(classification['esco_status'], l10n.explorerNeedsReview)}\n${l10n.explorerIsco08}: ${classificationStatus(classification['isco08_status'], l10n.explorerNeedsReview)}\n${l10n.explorerOnet}: ${classificationStatus(classification['onet_status'], l10n.explorerReferenceReview)}\n${l10n.explorerClassificationDisclaimer}')),
      _Section(title: l10n.explorerSources, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(sources.isEmpty ? l10n.explorerSourcesMissing : sources.map((s) => s is Map ? (s['source_id'] ?? s['id'] ?? '').toString() : s.toString()).join('\n')),
        const SizedBox(height: 8), Text(l10n.explorerEditorialStatus(editorialStatus(p['status'] ?? item['status']))),
        Text(AppLocalizations.of(context)!.explorerCandidateNote, style: TextStyle(fontStyle: FontStyle.italic)),
      ])),
    ]));
  }
  Widget _bulletList(List<dynamic> values) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: values.isEmpty
        ? [Text(AppLocalizations.of(context)!.explorerMissingContent)]
        : values.map((value) => Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('•  '),
                Expanded(child: Text(value.toString())),
              ],
            ),
          )).toList(),
  );
}

class _Section extends StatelessWidget {
  final String title; final Widget child;
  const _Section({required this.title, required this.child});
  @override Widget build(BuildContext context) => Card(margin: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)), const SizedBox(height: 10), child])));
}

class _PartialDataNotice extends StatelessWidget {
  final int count;
  final VoidCallback onRetry;
  const _PartialDataNotice({required this.count, required this.onRetry});

  @override
  Widget build(BuildContext context) => Card(
    color: Theme.of(context).colorScheme.errorContainer,
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          AppLocalizations.of(context)!.explorerPartialData(count),
          style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
        ),
        Align(alignment: Alignment.centerRight, child: TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: Text(AppLocalizations.of(context)!.retry),
        )),
      ]),
    ),
  );
}

class _LoadState extends StatelessWidget {
  final String message, error; final VoidCallback retry;
  const _LoadState({required this.message, required this.error, required this.retry});
  @override Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.cloud_off_outlined, size: 40), const SizedBox(height: 12), Text(message, textAlign: TextAlign.center), const SizedBox(height: 8), Text(error, maxLines: 3, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall), const SizedBox(height: 12), OutlinedButton(onPressed: retry, child: Text(AppLocalizations.of(context)!.retry)),
  ])));
}

