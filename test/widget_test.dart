// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:siiadmision/config/theme_controller.dart';
import 'package:siiadmision/main.dart';

void main() {
  testWidgets('Login screen renders main actions', (WidgetTester tester) async {
    final view = tester.view;
    final originalSize = view.physicalSize;
    final originalRatio = view.devicePixelRatio;
    view.physicalSize = const Size(1440, 1024);
    view.devicePixelRatio = 1.0;
    addTearDown(() {
      view.physicalSize = originalSize;
      view.devicePixelRatio = originalRatio;
    });

    await tester.pumpWidget(MyApp(themeController: themeController));
    await tester.pumpAndSettle();

    expect(find.text('Inicio de Sesión'), findsOneWidget);
    expect(find.text('Iniciar Sesión'), findsOneWidget);
  });
}
