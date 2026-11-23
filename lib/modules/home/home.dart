part of '../../main.dart';

class HomeDashboardPage extends StatefulWidget {
  final ValueChanged<int> onNavigate;
  const HomeDashboardPage({super.key, required this.onNavigate});
  @override State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> {
  Future<ExplorerData> future = ExplorerData.shared;

  void _retry() => setState(() { future = ExplorerData.retry(); });

  String _occupationTitle(Map<String, dynamic> occupation) =>
      (occupation['canonical_title']?[AppState.instance.language] ??
              occupation['canonical_title']?['fr'] ??
              occupation['id'] ??
              '')
          .toString();

  @override
  Widget build(BuildContext context) => FutureBuilder<ExplorerData>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _LoadState(
              message: AppLocalizations.of(context)!.explorerLoadFailure,
              error: snapshot.error.toString(),
              retry: _retry,
            );
          }
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final profile = ProfileBridge.current;
          final goals = AppState.instance.goals;
          final activeGoals = goals.where((goal) => goal['status'] == 'in_progress').toList();
          final viewedCount = AppState.instance.viewedLessonTimestamps.length;
          final matches = OrientationEngine.rank(snapshot.data!, profile)
              .where((match) => match.score > 0)
              .take(3)
              .toList();
          final hasActiveGoals = goals.any((goal) => const ['in_progress', 'paused'].contains(goal['status']));
          final hasProfileInputs =
              (profile['skills'] as List? ?? const []).isNotEmpty ||
              (profile['interest_domains'] as List? ?? const []).isNotEmpty ||
              hasActiveGoals;
          final l10n = AppLocalizations.of(context)!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(l10n.homeGreeting,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(l10n.homeIntro),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width < 420 ? 2 : 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.28,
                children: [
                  _HomeActionCard(icon: Icons.explore_outlined, title: l10n.homeExplorerCard, onTap: () => widget.onNavigate(1)),
                  _HomeActionCard(icon: Icons.route_outlined, title: l10n.homeJourneyCard, onTap: () => widget.onNavigate(2)),
                  _HomeActionCard(icon: Icons.school_outlined, title: l10n.homeAcademyCard, onTap: () => widget.onNavigate(3)),
                  _HomeActionCard(icon: Icons.person_outline, title: l10n.homeProfileCard, onTap: () => widget.onNavigate(4)),
                ],
              ),
              const SizedBox(height: 18),
              _ProfileCard(
                title: l10n.homeYourProgress,
                child: Wrap(spacing: 10, runSpacing: 10, children: [
                  _ProgressMetric(label: l10n.progressMetricActiveGoals, value: '${activeGoals.length}'),
                  _ProgressMetric(label: l10n.progressMetricLessons, value: '$viewedCount'),
                  _ProgressMetric(label: l10n.progressMetricCompletedGoals, value: '${goals.where((goal) => goal['status'] == 'completed').length}'),
                ]),
              ),
              _ProfileCard(
                title: l10n.homeTopSuggestions,
                child: !hasProfileInputs || matches.isEmpty
                    ? Text(l10n.homeNoSuggestions)
                    : Column(children: [
                        for (final match in matches)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(child: Text('${match.score}')),
                            title: Text(_occupationTitle(match.occupation)),
                            subtitle: Text('${match.score}%'),
                            onTap: () => widget.onNavigate(2),
                          ),
                      ]),
              ),
              _ProfileCard(
                title: l10n.homeYourGoals,
                child: activeGoals.isEmpty
                    ? Text(l10n.homeNoGoals)
                    : Column(children: [
                        for (final goal in activeGoals.take(4))
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.flag_outlined),
                            title: Text((goal['title'] ?? '').toString()),
                            onTap: () => widget.onNavigate(2),
                          ),
                      ]),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: () => widget.onNavigate(3),
                icon: const Icon(Icons.play_arrow),
                label: Text(l10n.homeContinueAcademy),
              ),
            ],
          );
        },
      );
}

class _HomeActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _HomeActionCard({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) => Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary, size: 25),
                Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      );
}
