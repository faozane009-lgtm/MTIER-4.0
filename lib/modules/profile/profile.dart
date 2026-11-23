part of '../../main.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final name = TextEditingController();
  final country = TextEditingController();
  final region = TextEditingController();
  final educationOther = TextEditingController();
  final skillInput = TextEditingController();
  final interestInput = TextEditingController();
  final goalInput = TextEditingController();
  String ageBand = 'not_specified', education = 'not_specified', learningFormat = 'not_specified';
  String preferredLanguage = 'fr';
  final List<String> interests = [];
  final List<String> skills = [];
  bool personalization = false, portfolioShare = false, analytics = false;
  bool profileSavedLocally = false;
  String? selectedOccupationId;
  final List<String> followedOccupationIds = [];

  @override
  void initState() {
    super.initState();
    final saved = AppState.instance.profile;
    name.text = (saved['display_name'] ?? '').toString();
    country.text = (saved['country_code'] ?? '').toString();
    region.text = (saved['region'] ?? '').toString();
    educationOther.text = (saved['education_detail'] ?? '').toString();
    ageBand = (saved['age_band'] ?? ageBand).toString();
    education = (saved['education_level'] ?? education).toString();
    learningFormat = (saved['learning_format'] ?? learningFormat).toString();
    preferredLanguage = (saved['preferred_language'] ?? AppState.instance.language).toString();
    interests.addAll((saved['interest_domains'] as List? ?? const []).map((e) => e.toString()));
    skills.addAll((saved['skills'] as List? ?? const []).map((e) => e.toString()));
    followedOccupationIds.addAll((saved['followed_occupation_ids'] as List? ?? const []).map((e) => e.toString()));
    final consents = saved['consents'];
    if (consents is Map) {
      personalization = consents['personalization'] == true;
      portfolioShare = consents['portfolio_public_sharing'] == true;
      analytics = consents['analytics_optional'] == true;
    }
  }

  void _commitProfileSnapshot() {
    AppState.instance.setProfile(_profileSnapshot());
  }

  void _markDirty() {
    if (!mounted) return;
    setState(() => profileSavedLocally = false);
    _commitProfileSnapshot();
  }

  Map<String, dynamic> _profileSnapshot() => {
    'display_name': name.text.trim(),
    'age_band': ageBand == 'not_specified' ? null : ageBand,
    'country_code': country.text.trim().isEmpty ? null : country.text.trim().toUpperCase(),
    'region': region.text.trim(),
    'education_level': education == 'not_specified' ? null : education,
    'education_detail': educationOther.text.trim(),
    'interest_domains': List<String>.from(interests),
    'skills': List<String>.from(skills),
    'learning_format': learningFormat == 'not_specified' ? null : learningFormat,
    'preferred_language': preferredLanguage,
    'followed_occupation_ids': List<String>.from(followedOccupationIds),
    'profile_visibility': 'private',
    'consents': {
      'personalization': personalization,
      'portfolio_public_sharing': portfolioShare,
      'analytics_optional': analytics,
    },
  };

  void _validateAndPreview() {
    final code = country.text.trim();
    if (code.isNotEmpty && !RegExp(r'^[A-Za-z]{2}$').hasMatch(code)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.profileCountryError)));
      return;
    }
    _commitProfileSnapshot();
    setState(() => profileSavedLocally = true);
    showDialog<void>(context: context, builder: (context) => AlertDialog(
      title: Text(AppLocalizations.of(context)!.profilePreviewDialogTitle),
      content: SingleChildScrollView(child: SelectableText(JsonEncoder.withIndent('  ').convert(_profileSnapshot()))),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.commonCancel))],
    ));
  }

  @override void dispose() {
    name.dispose(); country.dispose(); region.dispose(); educationOther.dispose();
    skillInput.dispose(); interestInput.dispose(); goalInput.dispose();
    super.dispose();
  }

  void _addTag(TextEditingController controller, List<String> target) {
    final value = controller.text.trim();
    if (value.isNotEmpty && !target.any((e) => e.toLowerCase() == value.toLowerCase())) {
      setState(() { target.add(value); controller.clear(); profileSavedLocally = false; });
      _commitProfileSnapshot();
    }
  }

  Widget _tagEditor(String title, TextEditingController controller, List<String> values, String hint) =>
    _ProfileCard(title: title, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Expanded(child: TextField(controller: controller, decoration: InputDecoration(hintText: hint), onChanged: (_) => _markDirty(), onSubmitted: (_) => _addTag(controller, values))), IconButton(tooltip: AppLocalizations.of(context)!.profileAdd, onPressed: () => _addTag(controller, values), icon: const Icon(Icons.add_circle_outline))]),
      if (values.isNotEmpty) Wrap(spacing: 7, runSpacing: 4, children: values.map((v) => InputChip(label: Text(v), onDeleted: () {
        setState(() { values.remove(v); profileSavedLocally = false; });
        _commitProfileSnapshot();
      })).toList()),
    ]));

  Widget _goalEditor() => _ProfileCard(
    title: AppLocalizations.of(context)!.profileGoals,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: TextField(
          controller: goalInput,
          decoration: InputDecoration(hintText: AppLocalizations.of(context)!.profileGoalHint),
          onChanged: (_) => _markDirty(),
          onSubmitted: (_) => _addProfileGoal(),
        )),
        IconButton(tooltip: AppLocalizations.of(context)!.profileAdd, onPressed: _addProfileGoal, icon: const Icon(Icons.add_circle_outline)),
      ]),
      if (AppState.instance.goals.isNotEmpty)
        Wrap(spacing: 7, runSpacing: 4, children: AppState.instance.goals.map((goal) => InputChip(
          label: Text((goal['title'] ?? '').toString()),
          onDeleted: () => _confirmAndDeleteGoal(goal),
        )).toList()),
      Text(AppLocalizations.of(context)!.profileGoals, style: TextStyle(fontSize: 12)),
    ]),
  );

  Future<void> _confirmAndDeleteGoal(Map<String, dynamic> goal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.progressDeleteGoal),
        content: Text('${AppLocalizations.of(context)!.progressDeletePrompt} (${goal['title']})'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(AppLocalizations.of(context)!.commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(AppLocalizations.of(context)!.commonDelete)),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => AppState.instance.goals.remove(goal));
    AppState.instance.commit();
  }

  Future<void> _clearLocalData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.profileClearLocalData),
        content: Text(AppLocalizations.of(context)!.profileClearDataWarning),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(AppLocalizations.of(context)!.commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(AppLocalizations.of(context)!.profileClearLocalData)),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await AppState.instance.clearLocalData();
    if (!mounted) return;
    setState(() {
      name.clear(); country.clear(); region.clear(); educationOther.clear();
      skillInput.clear(); interestInput.clear(); goalInput.clear();
      interests.clear(); skills.clear(); followedOccupationIds.clear();
      ageBand = 'not_specified'; education = 'not_specified';
      learningFormat = 'not_specified'; preferredLanguage = 'fr';
      personalization = false; portfolioShare = false; analytics = false;
      selectedOccupationId = null; profileSavedLocally = false;
    });
    AppState.instance.commit();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.commonLocalDataCleared)));
  }

  void _addProfileGoal() {
    final title = goalInput.text.trim();
    if (title.isEmpty || AppState.instance.goals.any((goal) =>
        (goal['title'] ?? '').toString().toLowerCase() == title.toLowerCase())) return;
    setState(() {
      AppState.instance.goals.add(Goal(
        id: 'goal-${DateTime.now().microsecondsSinceEpoch}',
        title: title,
        type: GoalType.learning,
        status: GoalStatus.inProgress,
        createdAt: DateTime.now().toUtc(),
      ).toJson());
      goalInput.clear();
      profileSavedLocally = false;
    });
    AppState.instance.commit();
  }

  @override Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text(AppLocalizations.of(context)!.profileTitle, style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
      const SizedBox(height: 5), Text(AppLocalizations.of(context)!.profileIntro),
      const SizedBox(height: 12),
      if (AppState.instance.storageWarning != null)
        Card(child: Padding(padding: const EdgeInsets.all(12), child: Text(switch (AppState.instance.storageWarning) {
          'newer_version' => AppLocalizations.of(context)!.localStorageNewerVersion,
          'restore_failed' => AppLocalizations.of(context)!.localStorageRestoreFailed,
          'save_failed' => AppLocalizations.of(context)!.localStorageSaveFailed,
          _ => AppLocalizations.of(context)!.localStorageRestoreFailed,
        }))),
      _ProfileCard(title: AppLocalizations.of(context)!.profileGeneralInfo, child: Column(children: [
        TextField(controller: name, maxLength: 60, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.profileDisplayName, prefixIcon: Icon(Icons.person_outline)), onChanged: (_) => _markDirty()),
        const SizedBox(height: 10), DropdownButtonFormField<String>(value: ageBand, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.profileAgeRange), items: [DropdownMenuItem(value: 'not_specified', child: Text(AppLocalizations.of(context)!.profileAgeNotSpecified)), ...['13-17','18-24','25-34','35-44','45-54','55+'].map((v) => DropdownMenuItem(value: v, child: Text(v)))], onChanged: (v) { setState(() { ageBand = v ?? ageBand; profileSavedLocally = false; }); _commitProfileSnapshot(); }),
        const SizedBox(height: 10), TextField(controller: country, maxLength: 2, textCapitalization: TextCapitalization.characters, inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')), LengthLimitingTextInputFormatter(2)], decoration: InputDecoration(labelText: AppLocalizations.of(context)!.profileCountry), onChanged: (_) => _markDirty()),
        const SizedBox(height: 10), TextField(controller: region, maxLength: 80, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.profileRegion), onChanged: (_) => _markDirty()),
      ])),
      _ProfileCard(title: AppLocalizations.of(context)!.profileEducation, child: Column(children: [
        DropdownButtonFormField<String>(value: education, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.profileEducationLevel), items: [DropdownMenuItem(value:'not_specified',child:Text(AppLocalizations.of(context)!.profileNotSpecified)),DropdownMenuItem(value:'primary',child:Text(AppLocalizations.of(context)!.profilePrimary)),DropdownMenuItem(value:'secondary',child:Text(AppLocalizations.of(context)!.profileSecondary)),DropdownMenuItem(value:'vocational',child:Text(AppLocalizations.of(context)!.profileVocational)),DropdownMenuItem(value:'undergraduate',child:Text(AppLocalizations.of(context)!.profileUndergraduate)),DropdownMenuItem(value:'graduate',child:Text(AppLocalizations.of(context)!.profileGraduate)),DropdownMenuItem(value:'other',child:Text(AppLocalizations.of(context)!.profileOther))], onChanged: (v) { setState(() { education = v ?? 'not_specified'; profileSavedLocally = false; }); _commitProfileSnapshot(); }),
        const SizedBox(height: 10), TextField(controller: educationOther, maxLength: 100, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.profileEducationOther), onChanged: (_) => _markDirty()),
      ])),
      _tagEditor(AppLocalizations.of(context)!.profileInterests, interestInput, interests, AppLocalizations.of(context)!.profileInterestHint),
      _tagEditor(AppLocalizations.of(context)!.profileSkills, skillInput, skills, AppLocalizations.of(context)!.profileSkillsHint),
      _ProfileCard(title: AppLocalizations.of(context)!.profileLearningPreferences, child: Column(children: [
        DropdownButtonFormField<String>(value: learningFormat, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.profileLearningFormat), items: [DropdownMenuItem(value:'not_specified',child:Text(AppLocalizations.of(context)!.profileNotSpecified)),DropdownMenuItem(value:'practical',child:Text(AppLocalizations.of(context)!.profilePractical)),DropdownMenuItem(value:'short_lessons',child:Text(AppLocalizations.of(context)!.profileShortLessons)),DropdownMenuItem(value:'videos',child:Text(AppLocalizations.of(context)!.profileVideos)),DropdownMenuItem(value:'reading',child:Text(AppLocalizations.of(context)!.profileReading)),DropdownMenuItem(value:'mixed',child:Text(AppLocalizations.of(context)!.profileMixed))], onChanged: (v) { setState(() { learningFormat = v ?? 'not_specified'; profileSavedLocally = false; }); _commitProfileSnapshot(); }),
        const SizedBox(height: 10), DropdownButtonFormField<String>(value: preferredLanguage, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.profilePreferredLanguage), items: const [DropdownMenuItem(value:'fr',child:Text('Français')),DropdownMenuItem(value:'en',child:Text('English')),DropdownMenuItem(value:'es',child:Text('Español'))], onChanged: (v) { setState(() { preferredLanguage = v ?? preferredLanguage; profileSavedLocally = false; }); _commitProfileSnapshot(); }),
      ])),
      _goalEditor(),
      _ProfileCard(title: AppLocalizations.of(context)!.profileOccupationLinks, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(AppLocalizations.of(context)!.profileOccupationPickerIntro),
        const SizedBox(height: 10),
        FutureBuilder<ExplorerData>(future: ExplorerData.shared, builder: (context, snapshot) {
          if (snapshot.hasError) return Text(AppLocalizations.of(context)!.profileExplorerUnavailable, style: TextStyle(color: Theme.of(context).colorScheme.error));
          if (!snapshot.hasData) return const LinearProgressIndicator();
          final occupations = snapshot.data!.occupations;
          final available = occupations.where((o) => !followedOccupationIds.contains((o['id'] ?? '').toString())).toList();
          String titleOf(Map<String, dynamic> o) => (o['canonical_title']?[AppState.instance.language] ?? o['canonical_title']?['fr'] ?? o['id']).toString();
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            DropdownButtonFormField<String>(
              value: selectedOccupationId,
              isExpanded: true,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.profileSelectOccupation),
              items: available.map((o) => DropdownMenuItem<String>(value: (o['id'] ?? '').toString(), child: Text(titleOf(o), overflow: TextOverflow.ellipsis))).toList(),
              onChanged: available.isEmpty ? null : (v) => setState(() => selectedOccupationId = v),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: selectedOccupationId == null ? null : () {
                setState(() {
                  if (!followedOccupationIds.contains(selectedOccupationId)) followedOccupationIds.add(selectedOccupationId!);
                  selectedOccupationId = null; profileSavedLocally = false;
                });
                _commitProfileSnapshot();
              },
              icon: const Icon(Icons.add), label: Text(AppLocalizations.of(context)!.profileFollowedOccupations),
            ),
            if (available.isEmpty && occupations.isNotEmpty) Text(AppLocalizations.of(context)!.profileNoMoreOccupations),
            if (followedOccupationIds.isNotEmpty) Wrap(spacing: 7, runSpacing: 5, children: followedOccupationIds.map((id) {
              Map<String, dynamic>? match;
              for (final occupation in occupations) { if (occupation['id'] == id) { match = occupation; break; } }
              final label = match == null ? id : titleOf(match);
              return InputChip(label: Text(label), onDeleted: () {
                setState(() { followedOccupationIds.remove(id); profileSavedLocally = false; });
                _commitProfileSnapshot();
              });
            }).toList()),
            Text(AppLocalizations.of(context)!.profileFollowedCount(followedOccupationIds.length, occupations.length), style: Theme.of(context).textTheme.bodySmall),
          ]);
        }),
      ])),
      _ProfileCard(title: AppLocalizations.of(context)!.profilePrivacy, child: Column(children: [
        ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.lock_outline), title: Text(AppLocalizations.of(context)!.profilePrivate), subtitle: Text(AppLocalizations.of(context)!.profilePublicDisabled)),
        SwitchListTile(contentPadding: EdgeInsets.zero, title: Text(AppLocalizations.of(context)!.profilePersonalization), subtitle: Text(AppLocalizations.of(context)!.profilePersonalizationDescription), value: personalization, onChanged: (v) { setState(() { personalization = v; profileSavedLocally = false; }); _commitProfileSnapshot(); }),
        SwitchListTile(contentPadding: EdgeInsets.zero, title: Text(AppLocalizations.of(context)!.profilePortfolio), subtitle: Text(AppLocalizations.of(context)!.profilePortfolioDescription), value: portfolioShare, onChanged: (v) { setState(() { portfolioShare = v; profileSavedLocally = false; }); _commitProfileSnapshot(); }),
        SwitchListTile(contentPadding: EdgeInsets.zero, title: Text(AppLocalizations.of(context)!.profileAnalytics), value: analytics, onChanged: (v) { setState(() { analytics = v; profileSavedLocally = false; }); _commitProfileSnapshot(); }),
        const SizedBox(height: 8),
        Align(alignment: Alignment.centerLeft, child: TextButton.icon(onPressed: _clearLocalData, icon: const Icon(Icons.delete_outline), label: Text(AppLocalizations.of(context)!.profileClearLocalData))),
      ])),
      FilledButton.icon(onPressed: _validateAndPreview, icon: const Icon(Icons.save_outlined), label: Text(AppLocalizations.of(context)!.profileValidatePreview)),
      const SizedBox(height: 8),
      Card(child: ListTile(leading: const Icon(Icons.phone_android), title: Text(AppLocalizations.of(context)!.profileLocalMode), subtitle: Text(profileSavedLocally ? AppLocalizations.of(context)!.profileLocalModeSaved : AppLocalizations.of(context)!.profileLocalModeDirty))),
      Text(AppLocalizations.of(context)!.profileInterconnectionNote, style: TextStyle(fontSize: 12)),
      const SizedBox(height: 20),
    ]);
  }
}


/// Shared view of the exact Profile form state. Replaced by the
/// authenticated Profile repository only during the final backend phase.
class ProfileBridge {
  static Map<String, dynamic> get current => AppState.instance.profile;
}

