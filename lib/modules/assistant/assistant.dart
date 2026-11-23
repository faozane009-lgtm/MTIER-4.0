part of '../../main.dart';

/// Local, deterministic assistant prototype. It reads the same shared module
/// state and deliberately makes no network or Supabase requests.
class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});
  @override State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  final TextEditingController controller = TextEditingController();
  final List<Map<String, String>> messages = <Map<String, String>>[];

  String _localized(String fr, String en, String es) => switch (AppState.instance.language) {
    'en' => en,
    'es' => es,
    _ => fr,
  };

  String _greeting() => _localized(
    'Bonjour ! Je suis l’assistante M-TIER (prototype local). Je peux t’aider à comprendre tes pistes Match, organiser tes objectifs Progress et choisir une leçon Academy à partir des informations déjà présentes dans les modules.',
    'Hello! I am the M-TIER assistant (local prototype). I can help explain your Match suggestions, organize your Progress goals, and choose an Academy lesson using information already shared across the modules.',
    '¡Hola! Soy la asistente de M-TIER (prototipo local). Puedo ayudarte a comprender tus sugerencias de Match, organizar tus objetivos de Progress y elegir una lección de Academy a partir de la información compartida entre los módulos.',
  );
  Future<ExplorerData> explorerFuture = ExplorerData.shared;
  Future<AcademyData> academyFuture = AcademyData.shared;

  void _retryExplorer() => setState(() => explorerFuture = ExplorerData.retry());
  void _retryAcademy() => setState(() => academyFuture = AcademyData.retry());

  @override void dispose() { controller.dispose(); super.dispose(); }

  String _answer(String question, ExplorerData explorer, AcademyData academy) {
    final q = OrientationEngine.norm(question);
    final profile = ProfileBridge.current;
    final matches = OrientationEngine.rank(explorer, profile).where((m) => m.score > 0).take(5).toList();
    final goals = ProgressBridge.objectives;
    final activeGoals = goals.where((g) => (g['status'] ?? '') == 'in_progress').length;
    final viewed = AcademyBridge.viewedLessons.length;
    final skills = (profile['skills'] as List? ?? const []).map((e) => e.toString()).toList();
    final interests = (profile['interest_domains'] as List? ?? const []).map((e) => e.toString()).toList();
    final hasActiveGoals = goals.any((goal) => const ['in_progress', 'paused'].contains(goal['status']));
    final hasProfile = skills.isNotEmpty || interests.isNotEmpty || hasActiveGoals;

    if (AssistantIntentClassifier.isHarmfulCyberRequest(question)) {
      return _localized(
        'Je peux t’accompagner en cybersécurité dans un cadre légal et défensif : comprendre les risques, sécuriser un système, analyser des exemples fictifs et apprendre dans des laboratoires autorisés. Je ne fournis pas de consignes pour accéder à un compte ou attaquer un système sans autorisation.',
        'I can support cybersecurity learning in a legal, defensive setting: understanding risks, securing systems, reviewing fictional examples, and learning in authorized labs. I cannot provide instructions for accessing accounts or attacking systems without permission.',
        'Puedo acompañarte en el aprendizaje de la ciberseguridad dentro de un marco legal y defensivo: comprender riesgos, proteger sistemas, analizar ejemplos ficticios y aprender en laboratorios autorizados. No puedo dar instrucciones para acceder a cuentas o atacar sistemas sin permiso.',
      );
    }
    if (TextNormalizer.containsAny(q, const ['confidentialite', 'donnee', 'donnees', 'vie privee', 'privacy', 'data privacy'])) {
      return _localized(
        'Tes données sont conservées localement sur cet appareil : profil, objectifs, notes et leçons consultées ne sont pas synchronisés avec un serveur. Évite d’y saisir des mots de passe ou des informations sensibles. La synchronisation serveur sera étudiée après validation.',
        'Your data is stored locally on this device: your profile, goals, notes, and viewed lessons are not synchronized with a server. Do not enter passwords or sensitive information. Server synchronization will be considered after validation.',
        'Tus datos se guardan localmente en este dispositivo: el perfil, los objetivos, las notas y las lecciones consultadas no se sincronizan con un servidor. No introduzcas contraseñas ni información sensible. La sincronización con un servidor se estudiará después de la validación.',
      );
    }
    if (TextNormalizer.containsAny(q, const ['progress', 'progression', 'progres', 'progresser', 'objectif', 'objectifs', 'avancement', 'journal', 'goal', 'goals'])) {
      if (goals.isEmpty && viewed == 0 && ProgressBridge.evidence.isEmpty) {
        return _localized(
          'Ton espace Progress ne contient pas encore d’activité enregistrée. Tu peux commencer par créer un objectif concret dans Progress, puis consulter une leçon dans Academy.',
          'Your Progress space has no recorded activity yet. Start by creating a concrete goal in Progress, then view a lesson in Academy.',
          'Tu espacio de Progress todavía no contiene actividad registrada. Puedes empezar creando un objetivo concreto en Progress y después consultar una lección en Academy.',
        );
      }
      return _localized(
        'Voici l’état visible : $activeGoals objectif(s) en cours sur ${goals.length}, $viewed leçon(s) consultée(s) dans Academy et ${ProgressBridge.evidence.length} réalisation(s) décrite(s). Ces données sont locales et ne constituent pas une évaluation officielle. Choisis un objectif et ajoute une petite preuve de ce que tu as appris.',
        'Here is the recorded activity: $activeGoals active goal(s) out of ${goals.length}, $viewed Academy lesson(s) viewed, and ${ProgressBridge.evidence.length} described achievement(s). This local information is not an official assessment. Choose a goal and add a small piece of evidence showing what you learned.',
        'Este es el estado registrado: $activeGoals objetivo(s) en curso de ${goals.length}, $viewed lección(es) de Academy consultada(s) y ${ProgressBridge.evidence.length} logro(s) descrito(s). Estos datos son locales y no constituyen una evaluación oficial. Elige un objetivo y añade una pequeña evidencia de lo que has aprendido.',
      );
    }
    if (TextNormalizer.containsAny(q, const ['academy', 'lecon', 'lecons', 'apprendre', 'apprentissage', 'cours', 'lesson', 'lessons', 'learn', 'course'])) {
      final titles = academy.courses.take(3).map((course) => (AcademyData.localizedCourse(course, AppState.instance.language)['title'] ?? 'Parcours').toString()).join(' ; ');
      return _localized(
        'Academy contient ${academy.courses.length} parcours de démonstration : $titles. Ils sont encore au statut brouillon et ne sont ni des diplômes ni des certifications. Les leçons consultées sont reprises dans Progress.',
        'Academy contains ${academy.courses.length} demonstration learning paths: $titles. They are still drafts and are not diplomas or certifications. Viewed lessons are reflected in Progress.',
        'Academy contiene ${academy.courses.length} itinerarios de demostración: $titles. Siguen siendo borradores y no son títulos ni certificaciones. Las lecciones consultadas aparecen en Progress.',
      );
    }
    if (TextNormalizer.containsAny(q, const ['match', 'metier', 'metiers', 'orientation', 'carriere', 'career', 'occupation', 'profession'])) {
      if (matches.isEmpty) {
        return _localized(
          'Je n’ai pas encore assez d’informations dans Profil pour expliquer une recommandation Match. Renseigne quelques domaines d’intérêt, compétences ou objectifs dans Profil.',
          'There is not enough information in Profile yet to explain a Match recommendation. Add a few interests, skills, or goals in Profile.',
          'Todavía no hay suficiente información en Perfil para explicar una recomendación de Match. Añade algunos intereses, competencias u objetivos en Perfil.',
        );
      }
      final top = matches.take(3).map((m) => '${m.occupation['canonical_title']?[AppState.instance.language] ?? m.occupation['canonical_title']?['fr'] ?? m.occupation['id']} (${m.score}%)').join(' ; ');
      return _localized(
        'D’après les informations de Profil, tes premières pistes Match sont : $top. Ce score est indicatif, pas une probabilité de réussite ni une décision d’orientation. Ouvre Match pour consulter les raisons et les compétences à explorer.',
        'Based on the information in Profile, your first Match suggestions are: $top. This score is indicative, not a probability of success or a career decision. Open Match to review the reasons and skills to explore.',
        'Según la información de Perfil, tus primeras sugerencias de Match son: $top. Esta puntuación es orientativa, no es una probabilidad de éxito ni una decisión profesional. Abre Match para consultar los motivos y las competencias que puedes explorar.',
      );
    }
    if (TextNormalizer.containsAny(q, const ['profil', 'profile', 'competence', 'competences', 'interet', 'interets', 'skill', 'skills', 'interest', 'interests'])) {
      if (!hasProfile) {
        return _localized(
          'Ton Profil est encore peu renseigné. Ajoute tes centres d’intérêt, compétences et objectifs dans Profil : Match et moi pourrons alors utiliser ces mêmes informations.',
          'Your Profile is still incomplete. Add interests, skills, and goals in Profile so Match and I can use the same information.',
          'Tu Perfil todavía tiene pocos datos. Añade intereses, competencias y objetivos en Perfil para que Match y yo podamos utilizar la misma información.',
        );
      }
      return _localized(
        'Je lis les informations partagées par Profil : ${skills.length} compétence(s) et ${interests.length} domaine(s) d’intérêt. Elles alimentent Match et orientent les suggestions Academy. Cette assistante ne crée pas de copie indépendante.',
        'I use the information shared by Profile: ${skills.length} skill(s) and ${interests.length} interest area(s). They inform Match and Academy suggestions. This assistant does not create a separate profile copy.',
        'Utilizo la información compartida por Perfil: ${skills.length} competencia(s) y ${interests.length} área(s) de interés. Estos datos alimentan Match y orientan las sugerencias de Academy. Esta asistente no crea una copia independiente.',
      );
    }
    return _localized(
      'Je peux t’aider sur ton orientation, tes compétences, tes objectifs et tes apprentissages. Demande par exemple : « Explique mes pistes Match » ou « Quel parcours Academy commencer ? ».',
      'I can help with career exploration, skills, goals, and learning. Try asking: “Explain my Match suggestions” or “Which Academy path should I start?”.',
      'Puedo ayudarte con la orientación, las competencias, los objetivos y el aprendizaje. Por ejemplo: «Explica mis sugerencias de Match» o «¿Qué itinerario de Academy debería empezar?».',
    );
  }

  void _send(ExplorerData explorer, AcademyData academy, [String? suggested]) {
    final question = (suggested ?? controller.text).trim();
    if (question.isEmpty) return;
    setState(() {
      if (messages.isEmpty) messages.add({'role': 'assistant', 'text': _greeting()});
      messages.add({'role': 'user', 'text': question});
      messages.add({'role': 'assistant', 'text': _answer(question, explorer, academy)});
      controller.clear();
    });
  }

  @override Widget build(BuildContext context) => FutureBuilder<ExplorerData>(
    future: explorerFuture,
    builder: (context, explorerSnapshot) {
      if (explorerSnapshot.hasError) return _LoadState(message: AppLocalizations.of(context)!.assistantExplorerUnavailable, error: explorerSnapshot.error.toString(), retry: _retryExplorer);
      if (!explorerSnapshot.hasData) return const Center(child: CircularProgressIndicator());
      return FutureBuilder<AcademyData>(
        future: academyFuture,
        builder: (context, academySnapshot) {
          if (academySnapshot.hasError) return _LoadState(message: AppLocalizations.of(context)!.assistantAcademyUnavailable, error: academySnapshot.error.toString(), retry: _retryAcademy);
          if (!academySnapshot.hasData) return const Center(child: CircularProgressIndicator());
          final explorer = explorerSnapshot.data!;
          final academy = academySnapshot.data!;
          final matches = OrientationEngine.rank(explorer, ProfileBridge.current).where((m) => m.score > 0).length;
          return Column(children: [
            if (explorer.loadErrors.isNotEmpty) _PartialDataNotice(count: explorer.loadErrors.length, onRetry: _retryExplorer),
            if (academy.loadErrors.isNotEmpty) _PartialDataNotice(count: academy.loadErrors.length, onRetry: _retryAcademy),
            Material(color: Theme.of(context).colorScheme.surface, child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
              CircleAvatar(backgroundColor: Theme.of(context).colorScheme.primaryContainer, child: const Icon(Icons.auto_awesome)),
              const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_localized('Assistante M-TIER', 'M-TIER Assistant', 'Asistente M-TIER'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(_localized('Prototype local', 'Local prototype', 'Prototipo local') + ' · ${explorer.occupations.length} · $matches Match · ${academy.courses.length} Academy', style: Theme.of(context).textTheme.bodySmall),
              ])),
            ]))),
            Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), color: Theme.of(context).colorScheme.tertiaryContainer, child: Text(_localized('Prototype de démonstration : réponses locales déterministes, sans modèle IA distant ni envoi de données.', 'Demonstration prototype: deterministic local replies, no remote AI model and no data transmission.', 'Prototipo de demostración: respuestas locales deterministas, sin modelo de IA remoto ni envío de datos.'), style: const TextStyle(fontSize: 11))),
            Expanded(child: ListView.builder(padding: const EdgeInsets.all(12), itemCount: messages.isEmpty ? 1 : messages.length, itemBuilder: (context, index) {
              final message = messages.isEmpty ? {'role': 'assistant', 'text': _greeting()} : messages[index];
              final isUser = message['role'] == 'user';
              return Align(alignment: isUser ? Alignment.centerRight : Alignment.centerLeft, child: Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .84),
                margin: const EdgeInsets.only(bottom: 9), padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: isUser ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(14)),
                child: Text(message['text'] ?? ''),
              ));
            })),
            SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 10), child: Row(children: [
              for (final prompt in [
                _localized('Explique mes pistes Match', 'Explain my Match suggestions', 'Explica mis sugerencias de Match'),
                _localized('Comment progresser ?', 'How can I make progress?', '¿Cómo puedo progresar?'),
                _localized('Quel parcours Academy commencer ?', 'Which Academy path should I start?', '¿Qué itinerario de Academy debería empezar?'),
              ]) Padding(padding: const EdgeInsets.only(right: 6), child: ActionChip(label: Text(prompt), onPressed: () => _send(explorer, academy, prompt))),
            ])),
            SafeArea(top: false, child: Padding(padding: const EdgeInsets.fromLTRB(10, 8, 10, 10), child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(child: TextField(controller: controller, minLines: 1, maxLines: 4, textInputAction: TextInputAction.send, onSubmitted: (_) => _send(explorer, academy), decoration: InputDecoration(hintText: _localized('Pose ta question à M-TIER…', 'Ask M-TIER a question…', 'Haz una pregunta a M-TIER…'), isDense: true))),
              const SizedBox(width: 8), IconButton.filled(onPressed: () => _send(explorer, academy), icon: const Icon(Icons.send), tooltip: _localized('Envoyer', 'Send', 'Enviar')),
            ]))),
          ]);
        },
      );
    },
  );
}
