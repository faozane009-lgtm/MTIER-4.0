import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mtier/theme/mtier_theme.dart';

void main() {
  double contrast(Color first, Color second) {
    final a = first.computeLuminance();
    final b = second.computeLuminance();
    final lighter = a > b ? a : b;
    final darker = a > b ? b : a;
    return (lighter + 0.05) / (darker + 0.05);
  }

  test('M-TIER provides distinct dark and light Material 3 themes', () {
    expect(MTierTheme.dark.useMaterial3, isTrue);
    expect(MTierTheme.dark.brightness, Brightness.dark);
    expect(MTierTheme.light.useMaterial3, isTrue);
    expect(MTierTheme.light.brightness, Brightness.light);
    expect(MTierTheme.dark.colorScheme.primary, MTierTheme.accent);
  });

  test('main text and primary controls meet WCAG AA contrast targets', () {
    expect(contrast(MTierTheme.dark.colorScheme.onSurface, MTierTheme.dark.colorScheme.surface), greaterThanOrEqualTo(4.5));
    expect(contrast(MTierTheme.dark.colorScheme.onPrimary, MTierTheme.dark.colorScheme.primary), greaterThanOrEqualTo(4.5));
    expect(contrast(MTierTheme.light.colorScheme.onSurface, MTierTheme.light.colorScheme.surface), greaterThanOrEqualTo(4.5));
    expect(contrast(MTierTheme.light.colorScheme.primary, MTierTheme.light.colorScheme.surface), greaterThanOrEqualTo(4.5));
  });
}
