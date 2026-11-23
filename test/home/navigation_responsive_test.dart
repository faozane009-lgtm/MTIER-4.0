import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mtier/app/app_state.dart';
import 'package:mtier/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('five-destination navigation and Home fit a 360 dp viewport', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await AppState.instance.initialize();
    await AppState.instance.clearLocalData();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);

    await tester.pumpWidget(const MTierApp());
    for (var attempt = 0; attempt < 8; attempt++) {
      await tester.pump(const Duration(milliseconds: 200));
    }

    expect(find.byType(NavigationDestination), findsNWidgets(5));
    expect(tester.takeException(), isNull);

    for (final locale in const ['en', 'es', 'fr']) {
      AppState.instance.language = locale;
      AppState.instance.commit();
      await tester.pump();
      expect(find.byType(NavigationDestination), findsNWidgets(5));
      expect(tester.takeException(), isNull, reason: 'No overflow in $locale at 360 dp');
    }

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    await AppState.instance.clearLocalData();
  });
}
