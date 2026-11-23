# M-TIER 4.0 — design system v0.1

## Direction

A calm, focused, accessible career-learning interface using Material 3. The default theme is dark; users can choose dark, light, or system appearance. The global language and theme preferences are stored in the same versioned local state.

## Tokens

| Token | Value | Use |
|---|---|---|
| Dark background | `#0B1110` | Main dark canvas |
| Dark surface | `#141D1A` | Cards and filled controls |
| Dark accent | `#C8F169` | Primary action and focus accent |
| Dark text | `#F0F4EE` | Main text |
| Light background | `#F5F7F1` | Main light canvas |
| Light primary | `#49651A` | Primary controls |
| Light surface | `#FFFFFF` | Cards and controls |
| Input radius | 14 dp | Form controls |

## Implementation

- `lib/theme/mtier_theme.dart` contains the Material 3 dark and light themes.
- `AppState.themeMode` accepts only `dark`, `light`, or `system` and persists locally.
- `MTierApp` maps the persisted value to Flutter `ThemeMode`.
- The app bar provides an appearance menu; changes apply immediately.
- No external font is bundled until its official source and integrity can be verified; system font remains the fallback.

## Remaining design QA

The theme foundation is implemented, but the full visual redesign is not closed. Remaining work includes component consistency across all six modules, 360 dp overflow checks in FR/EN/ES, contrast review for every state, onboarding polish, and widget tests for light/dark/system. No golden-test pass is claimed.

## Navigation

The primary navigation contains five destinations: Home, Explorer, Journey (Match and Progress as internal tabs), Academy, and Profile. The M-TIER assistant is opened from a persistent floating action button rather than taking a sixth navigation slot. The Home dashboard displays only values read from shared local data; it does not invent activity statistics.

## Contraste des couleurs principales

Les couples de couleurs principaux ont été vérifiés numériquement pendant la préparation : texte sombre clair/surface sombre ≈ 15,47:1 ; texte sur accent sombre ≈ 12,90:1 ; texte clair/surface blanche ≈ 16,53:1 ; primaire clair/surface blanche ≈ 6,65:1. Un test Flutter vérifie ces quatre couples. Cela ne remplace pas une revue WCAG complète de chaque composant, état et texte secondaire.
