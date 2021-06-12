import 'package:acs_upb_mobile/authentication/model/user.dart';
import 'package:acs_upb_mobile/authentication/service/auth_provider.dart';
import 'package:acs_upb_mobile/main.dart';
import 'package:acs_upb_mobile/pages/faq/model/question.dart';
import 'package:acs_upb_mobile/pages/faq/service/question_provider.dart';
import 'package:acs_upb_mobile/pages/news_feed/model/news_feed_item.dart';
import 'package:acs_upb_mobile/pages/news_feed/service/news_provider.dart';
import 'package:acs_upb_mobile/pages/portal/service/website_provider.dart';
import 'package:acs_upb_mobile/pages/settings/service/request_provider.dart';
import 'package:acs_upb_mobile/pages/settings/view/request_permissions.dart';
import 'package:acs_upb_mobile/pages/settings/view/settings_page.dart';
import 'package:acs_upb_mobile/pages/timetable/model/events/uni_event.dart';
import 'package:acs_upb_mobile/pages/timetable/service/uni_event_provider.dart';
import 'package:acs_upb_mobile/resources/locale_provider.dart';
import 'package:acs_upb_mobile/resources/utils.dart';
import 'package:acs_upb_mobile/widgets/dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:preferences/preferences.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_machine/time_machine.dart';

import 'test_utils.dart';

class MockAuthProvider extends Mock implements AuthProvider {}

class MockWebsiteProvider extends Mock implements WebsiteProvider {}

class MockQuestionProvider extends Mock implements QuestionProvider {}

class MockRequestProvider extends Mock implements RequestProvider {}

class MockNewsProvider extends Mock implements NewsProvider {}

class MockUniEventProvider extends Mock implements UniEventProvider {}

void main() {
  AuthProvider mockAuthProvider;
  WebsiteProvider mockWebsiteProvider;
  MockQuestionProvider mockQuestionProvider;
  RequestProvider mockRequestProvider;
  MockNewsProvider mockNewsProvider;
  UniEventProvider mockEventProvider;

  Widget buildApp() => MultiProvider(providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => mockAuthProvider),
        ChangeNotifierProvider<UniEventProvider>(
            create: (_) => mockEventProvider),
        ChangeNotifierProvider<WebsiteProvider>(
            create: (_) => mockWebsiteProvider),
        ChangeNotifierProvider<QuestionProvider>(
            create: (_) => mockQuestionProvider),
        Provider<RequestProvider>(create: (_) => mockRequestProvider),
        ChangeNotifierProvider<NewsProvider>(create: (_) => mockNewsProvider),
      ], child: const MyApp());

  group('Settings', () {
    setUpAll(() async {
      WidgetsFlutterBinding.ensureInitialized();
      PrefService.enableCaching();
      PrefService.cache = {};
      // Assuming mock system language is English
      SharedPreferences.setMockInitialValues({'language': 'auto'});

      LocaleProvider.cultures = testCultures;
      LocaleProvider.rruleL10ns = {'en': await RruleL10nTest.create()};

      Utils.packageInfo = PackageInfo(
          version: '1.2.7', buildNumber: '6', appName: 'ACS UPB Mobile');

      // Pretend an anonymous user is already logged in
      mockAuthProvider = MockAuthProvider();
      when(mockAuthProvider.isAuthenticated).thenReturn(true);
      // ignore: invalid_use_of_protected_member
      when(mockAuthProvider.hasListeners).thenReturn(false);
      when(mockAuthProvider.currentUser).thenAnswer((_) => Future.value(null));
      when(mockAuthProvider.isAnonymous).thenReturn(true);
      when(mockAuthProvider.getProfilePictureURL())
          .thenAnswer((_) => Future.value(null));
      when(mockAuthProvider.isVerified).thenAnswer((_) => Future.value(true));

      mockWebsiteProvider = MockWebsiteProvider();
      // ignore: invalid_use_of_protected_member
      when(mockWebsiteProvider.hasListeners).thenReturn(false);
      when(mockWebsiteProvider.deleteWebsite(any))
          .thenAnswer((_) => Future.value(true));
      when(mockWebsiteProvider.fetchWebsites(any))
          .thenAnswer((_) => Future.value([]));
      when(mockWebsiteProvider.fetchFavouriteWebsites(any))
          .thenAnswer((_) => Future.value(null));

      mockQuestionProvider = MockQuestionProvider();
      // ignore: invalid_use_of_protected_member
      when(mockQuestionProvider.hasListeners).thenReturn(false);
      when(mockQuestionProvider.fetchQuestions())
          .thenAnswer((_) => Future.value(<Question>[]));
      when(mockQuestionProvider.fetchQuestions(limit: anyNamed('limit')))
          .thenAnswer((_) => Future.value(<Question>[]));

      mockRequestProvider = MockRequestProvider();
      when(mockRequestProvider.makeRequest(any))
          .thenAnswer((_) => Future.value(true));
      when(mockRequestProvider.userAlreadyRequested(any))
          .thenAnswer((_) => Future.value(false));

      mockNewsProvider = MockNewsProvider();
      // ignore: invalid_use_of_protected_member
      when(mockNewsProvider.hasListeners).thenReturn(false);
      when(mockNewsProvider.fetchNewsFeedItems())
          .thenAnswer((_) => Future.value(<NewsFeedItem>[]));
      when(mockNewsProvider.fetchNewsFeedItems(limit: anyNamed('limit')))
          .thenAnswer((_) => Future.value(<NewsFeedItem>[]));

      mockEventProvider = MockUniEventProvider();
      // ignore: invalid_use_of_protected_member
      when(mockEventProvider.hasListeners).thenReturn(false);
      when(mockEventProvider.getUpcomingEvents(LocalDate.today()))
          .thenAnswer((_) => Future.value(<UniEventInstance>[]));
      when(mockEventProvider.getUpcomingEvents(LocalDate.today(),
              limit: anyNamed('limit')))
          .thenAnswer((_) => Future.value(<UniEventInstance>[]));
      when(mockEventProvider.getAssignments(
              limit: anyNamed('limit'), retrievePast: anyNamed('retrievePast')))
          .thenAnswer((_) => Future.value(<UniEventInstance>[]));
    });

    testWidgets('Dark Mode', (WidgetTester tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      MaterialApp app = find.byType(MaterialApp).evaluate().first.widget;
      expect(app.theme.brightness, equals(Brightness.light));

      // Open settings
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();

      // Toggle dark mode
      await tester.tap(find.text('Dark Mode'));
      await tester.pumpAndSettle();

      app = find.byType(MaterialApp).evaluate().first.widget;
      expect(app.theme.brightness, equals(Brightness.dark));

      // Toggle dark mode
      await tester.tap(find.text('Dark Mode'));
      await tester.pumpAndSettle();

      app = find.byType(MaterialApp).evaluate().first.widget;
      expect(app.theme.brightness, equals(Brightness.light));
    });

    testWidgets('Language', (WidgetTester tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Open settings
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Auto'), findsOneWidget);

      // Romanian
      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Romanian'));
      await tester.pumpAndSettle();

      expect(find.text('Setări'), findsOneWidget);
      expect(find.text('Română'), findsOneWidget);

      // English
      await tester.tap(find.text('Limbă'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Engleză'));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);

      // Back to Auto (English)
      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Auto'));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Auto'), findsOneWidget);
    });
    group('Request permissions', () {
      setUpAll(() async {
        when(mockAuthProvider.currentUser).thenAnswer((_) =>
            Future.value(User(uid: '0', firstName: 'John', lastName: 'Doe')));
        when(mockAuthProvider.isAnonymous).thenReturn(false);
      });

      testWidgets('Normal scenario', (WidgetTester tester) async {
        when(mockAuthProvider.isVerified).thenAnswer((_) => Future.value(true));

        await tester.pumpWidget(buildApp());
        await tester.pumpAndSettle();

        // Open settings
        await tester.tap(find.byIcon(Icons.settings_outlined));
        await tester.pumpAndSettle();

        // Open Ask Permissions page
        expect(find.text('No special permissions'), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('ask_permissions')));
        await tester.pumpAndSettle();
        expect(find.byType(RequestPermissionsPage), findsOneWidget);

        // Send a request
        await tester.enterText(
            find.byType(TextFormField), 'I love League of Legends');
        await tester.tap(find.byType(Checkbox));
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Verify the request is sent and Settings Page pops back
        verify(mockRequestProvider.makeRequest(any));
        expect(find.byType(SettingsPage), findsOneWidget);
      });

      testWidgets('User has already sent a request scenario',
          (WidgetTester tester) async {
        when(mockAuthProvider.isVerified).thenAnswer((_) => Future.value(true));
        when(mockRequestProvider.userAlreadyRequested(any))
            .thenAnswer((_) => Future.value(true));

        await tester.pumpWidget(buildApp());
        await tester.pumpAndSettle();

        // Open settings
        await tester.tap(find.byIcon(Icons.settings_outlined));
        await tester.pumpAndSettle();

        // Open Ask Permissions page
        expect(find.text('Permissions request already sent'), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('ask_permissions')));
        await tester.pumpAndSettle();
        expect(find.byType(RequestPermissionsPage), findsOneWidget);

        // Send a request
        await tester.enterText(
            find.byType(TextFormField), 'I love League of Legends');
        await tester.tap(find.byType(Checkbox));
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Check that warning Dialog appears and press Send
        expect(find.byType(AppDialog), findsOneWidget);
        await tester.tap(find.text('SEND'));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Verify the request is sent and Settings Page pops back
        verify(mockRequestProvider.makeRequest(any));
        expect(find.byType(SettingsPage), findsOneWidget);
      });

      testWidgets('User is anonymous scenario', (WidgetTester tester) async {
        when(mockAuthProvider.isVerified).thenAnswer((_) => Future.value(true));
        when(mockAuthProvider.isAnonymous).thenReturn(true);
        when(mockRequestProvider.userAlreadyRequested(any))
            .thenAnswer((_) => Future.value(false));

        await tester.pumpWidget(buildApp());
        await tester.pumpAndSettle();

        // Open settings
        await tester.tap(find.byIcon(Icons.settings_outlined));
        await tester.pumpAndSettle();

        // Press Ask Permissions page
        expect(find.text('No special permissions'), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('ask_permissions')));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Verify nothing happens
        expect(find.byType(SettingsPage), findsOneWidget);
      });

      testWidgets('User is not verified scenario', (WidgetTester tester) async {
        when(mockAuthProvider.isVerified)
            .thenAnswer((_) => Future.value(false));
        when(mockAuthProvider.isAnonymous).thenReturn(false);
        when(mockRequestProvider.userAlreadyRequested(any))
            .thenAnswer((_) => Future.value(false));

        await tester.pumpWidget(buildApp());
        await tester.pumpAndSettle();

        // Open settings
        await tester.tap(find.byIcon(Icons.settings_outlined));
        await tester.pumpAndSettle();

        // Press Ask Permissions page
        expect(find.text('No special permissions'), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('ask_permissions')));

        // Verify Ask Permissions page is not opened
        await tester.pumpAndSettle(const Duration(seconds: 4));
        expect(find.byType(SettingsPage), findsOneWidget);
        expect(find.byType(RequestPermissionsPage), findsNothing);

        // Verify account
        when(mockAuthProvider.isVerified).thenAnswer((_) => Future.value(true));

        // Go back and open settings again
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.settings_outlined));
        await tester.pumpAndSettle();

        // Press Ask Permissions page
        expect(find.text('No special permissions'), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('ask_permissions')));

        // Verify Ask Permissions page is opened
        await tester.pumpAndSettle();
        expect(find.byType(RequestPermissionsPage), findsOneWidget);
      });
    });
  });
}
