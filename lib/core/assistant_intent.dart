import 'text_normalizer.dart';

/// Conservative intent classifier: defensive context takes precedence over
/// isolated attack-related vocabulary to avoid false positives.
class AssistantIntentClassifier {
  AssistantIntentClassifier._();

  static const List<String> _defensiveContext = [
    'proteger', 'protegerse', 'proteger mi', 'proteger mi cuenta',
    'protection', 'protect', 'protect my', 'secure', 'securiser',
    'defendre', 'defense', 'defend', 'defensive', 'prevenir', 'prevention',
    'prevent', 'detecter', 'detection', 'detect', 'bloquer', 'block',
    'eviter', 'avoid', 'mitiger', 'mitigate', 'hardening',
  ];

  // Explicit first-person, instructional or imperative attack intent wins
  // over generic defensive vocabulary in mixed or contradictory prompts.
  static const List<String> _explicitHarmfulIntent = [
    'comment pirater', 'je veux pirater', 'pirater un compte', 'pirater un site',
    'comment attaquer', 'je veux attaquer', 'attaquer un site', 'attaquer un reseau',
    'voler un mot de passe', 'contourner une authentification', 'acceder sans autorisation',
    'how to hack', 'how do i hack', 'hack into', 'break into a system',
    'bypass authentication', 'steal a password', 'deploy malware',
    'quiero hackear', 'como hackear', 'quiero atacar', 'hackear una cuenta',
    'entrar en un sistema sin permiso', 'eludir la autenticacion',
  ];

  static const List<String> _harmfulPhrases = [
    'pirater un compte', 'pirater un site', 'comment pirater',
    'je veux pirater', 'attaquer un site', 'attaquer un reseau',
    'comment attaquer', 'je veux attaquer', 'voler un mot de passe',
    'contourner une authentification', 'acceder sans autorisation',
    'deployer un malware', 'installer un malware sur une cible',
    'exploiter une cible sans autorisation', 'steal a password',
    'hack an account', 'how to hack', 'how do i hack', 'hack into',
    'break into a system', 'bypass authentication', 'deploy malware',
    'robar una contrasena', 'hackear una cuenta', 'como hackear',
    'quiero hackear', 'quiero atacar', 'entrar en un sistema sin permiso',
    'eludir la autenticacion',
  ];

  static bool isHarmfulCyberRequest(String value) {
    final normalized = TextNormalizer.normalize(value);
    if (TextNormalizer.containsAny(normalized, _explicitHarmfulIntent)) return true;
    if (TextNormalizer.containsAny(normalized, _defensiveContext)) return false;
    return TextNormalizer.containsAny(normalized, _harmfulPhrases);
  }
}
