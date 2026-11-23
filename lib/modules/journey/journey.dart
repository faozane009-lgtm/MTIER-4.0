part of '../../main.dart';

class JourneyPage extends StatelessWidget {
  const JourneyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.surface,
            child: TabBar(
              tabs: [
                Tab(text: l10n.journeyTabMatch, icon: const Icon(Icons.route_outlined)),
                Tab(text: l10n.journeyTabProgress, icon: const Icon(Icons.insights_outlined)),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(children: [
              OrientationPage(),
              ProgressPage(),
            ]),
          ),
        ],
      ),
    );
  }
}
