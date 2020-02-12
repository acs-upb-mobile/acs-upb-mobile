import 'package:acs_upb_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preferences/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Settings', () {
    setUpAll(() async {
      WidgetsFlutterBinding.ensureInitialized();
      PrefService.enableCaching();
      PrefService.cache = {};
      // Assuming mock system language is English
      SharedPreferences.setMockInitialValues({'language': 'auto'});
    });

    testWidgets('Dark mode', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      MaterialApp app = find.byType(MaterialApp).evaluate().first.widget;
      expect(app.theme.brightness, equals(Brightness.dark));

      // Open navigation drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Open settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Toggle dark mode
      expect(find.text("Language"), findsOneWidget);
      await tester.tap(find.text('Dark mode'));
      await tester.pumpAndSettle();

      app = find.byType(MaterialApp).evaluate().first.widget;
      expect(app.theme.brightness, equals(Brightness.light));

      // Toggle dark mode
      await tester.tap(find.text('Dark mode'));
      await tester.pumpAndSettle();

      app = find.byType(MaterialApp).evaluate().first.widget;
      expect(app.theme.brightness, equals(Brightness.dark));
    });

    testWidgets('Language', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      MaterialApp app = find
          .byType(MaterialApp)
          .evaluate()
          .first
          .widget;
      expect(app.theme.brightness, equals(Brightness.dark));

      // Open navigation drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Open settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(find.text("Auto"), findsOneWidget);

      // Romanian
      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Romanian'));
      await tester.pumpAndSettle();

      // Tap aside to close popup
      // TODO: Make popup close automatically when choosing an option
      await tester.tapAt(Offset(1, 1));
      await tester.pumpAndSettle();

      expect(find.text("Setări"), findsOneWidget);
      expect(find.text("Română"), findsOneWidget);

      // English
      await tester.tap(find.text('Limbă'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Engleză'));
      await tester.pumpAndSettle();

      await tester.tapAt(Offset(1, 1));
      await tester.pumpAndSettle();

      expect(find.text("Settings"), findsOneWidget);
      expect(find.text("English"), findsOneWidget);

      // Back to Auto (English)
      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Auto'));
      await tester.pumpAndSettle();

      await tester.tapAt(Offset(1, 1));
      await tester.pumpAndSettle();

      expect(find.text("Settings"), findsOneWidget);
      expect(find.text("Auto"), findsOneWidget);
    });
  });
}