import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'l10n/generated/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app_state.dart';
import 'models/goal.dart';
import 'core/text_normalizer.dart';
import 'core/assistant_intent.dart';
import 'theme/mtier_theme.dart';

part 'modules/home/home.dart';
part 'modules/explorer/explorer.dart';
part 'modules/journey/journey.dart';
part 'modules/profile/profile.dart';
part 'modules/match/match.dart';
part 'modules/progress/progress.dart';
part 'modules/academy/academy.dart';
part 'modules/assistant/assistant.dart';

const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabasePublishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
const profileAssets = <String>[
  'assets/explorer/occupation_profiles/professional_profiles_batch_01_v0.1.json',
  'assets/explorer/occupation_profiles/professional_profiles_batch_02_v0.1.json',
  'assets/explorer/occupation_profiles/professional_profiles_batch_03_v0.1.json',
  'assets/explorer/occupation_profiles/professional_profiles_batch_04_v0.1.json',
  'assets/explorer/occupation_profiles/professional_profiles_batch_05_v0.1.json',
  'assets/explorer/occupation_profiles/professional_profiles_batch_06_v0.1.json',
  'assets/explorer/occupation_profiles/professional_profiles_batch_07_v0.1.json',
  'assets/explorer/occupation_profiles/professional_profiles_batch_08_v0.1.json',
  'assets/explorer/occupation_profiles/cybersecurity_profiles_v0.1.json',
  'assets/explorer/occupation_profiles/cross_sector_profiles_v0.3.json',
];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppState.instance.initialize();
  if (supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty) {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabasePublishableKey);
  }
  runApp(const MTierApp());
}

class MTierApp extends StatelessWidget {
  const MTierApp({super.key});
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: AppState.instance,
    builder: (context, _) => MaterialApp(
      title: 'M-TIER 4.0',
      debugShowCheckedModeBanner: false,
      locale: Locale(AppState.instance.language),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: MTierTheme.light,
      darkTheme: MTierTheme.dark,
      themeMode: switch (AppState.instance.themeMode) {
        'light' => ThemeMode.light,
        'system' => ThemeMode.system,
        _ => ThemeMode.dark,
      },
      home: const HomePage(),
    ),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tab = 0;

  void _navigate(int destination) => setState(() => tab = destination);

  void _openAssistant() {
    final l10n = AppLocalizations.of(context)!;
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => Scaffold(
        appBar: AppBar(title: Text(l10n.navAssistant)),
        body: const AssistantPage(),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: AppState.instance,
    builder: (context, _) {
      final l10n = AppLocalizations.of(context)!;
      return Scaffold(
        appBar: AppBar(
          title: const Text('M-TIER 4.0'),
          actions: [
            PopupMenuButton<String>(
              tooltip: l10n.languageMenuTooltip,
              initialValue: AppState.instance.language,
              icon: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.translate),
                const SizedBox(width: 4),
                Text(AppState.instance.language.toUpperCase()),
              ]),
              onSelected: (value) {
                AppState.instance.language = value;
                AppState.instance.commit();
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 'fr', child: Text(l10n.languageFrench)),
                PopupMenuItem(value: 'en', child: Text(l10n.languageEnglish)),
                PopupMenuItem(value: 'es', child: Text(l10n.languageSpanish)),
              ],
            ),
            PopupMenuButton<String>(
              tooltip: l10n.themeMenuTooltip,
              initialValue: AppState.instance.themeMode,
              icon: const Icon(Icons.contrast),
              onSelected: (value) {
                AppState.instance.themeMode = value;
                AppState.instance.commit();
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 'system', child: Text(l10n.themeSystem)),
                PopupMenuItem(value: 'light', child: Text(l10n.themeLight)),
                PopupMenuItem(value: 'dark', child: Text(l10n.themeDark)),
              ],
            ),
          ],
        ),
        body: Column(children: [
          if (AppState.instance.language != 'fr')
            MaterialBanner(
              content: Text(AppState.instance.language == 'en'
                  ? l10n.localizationCoverageWarningEn
                  : l10n.localizationCoverageWarningEs),
              leading: const Icon(Icons.info_outline),
              actions: [TextButton(
                onPressed: () {
                  AppState.instance.language = 'fr';
                  AppState.instance.commit();
                },
                child: Text(l10n.switchToFrench),
              )],
            ),
          Expanded(child: IndexedStack(index: tab, children: [
            HomeDashboardPage(onNavigate: _navigate),
            ExplorerPage(),
            const JourneyPage(),
            AcademyPage(),
            ProfilePage(),
          ])),
        ]),
        floatingActionButton: FloatingActionButton(
          onPressed: _openAssistant,
          tooltip: l10n.navAssistant,
          child: const Icon(Icons.auto_awesome_outlined),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (value) => setState(() => tab = value),
          destinations: [
            NavigationDestination(icon: const Icon(Icons.home_outlined), label: l10n.navHome),
            NavigationDestination(icon: const Icon(Icons.explore_outlined), label: l10n.navExplorer),
            NavigationDestination(icon: const Icon(Icons.route_outlined), label: l10n.navJourney),
            NavigationDestination(icon: const Icon(Icons.school_outlined), label: l10n.navAcademy),
            NavigationDestination(icon: const Icon(Icons.person_outline), label: l10n.navProfile),
          ],
        ),
      );
    },
  );
}

class _ProfileCard extends StatelessWidget {
  final String title; final Widget child;
  const _ProfileCard({required this.title, required this.child});
  @override Widget build(BuildContext context) => Card(margin: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.all(15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)), const SizedBox(height: 12), child])));
}

