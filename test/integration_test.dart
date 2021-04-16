import 'package:acs_upb_mobile/authentication/model/user.dart';
import 'package:acs_upb_mobile/authentication/service/auth_provider.dart';
import 'package:acs_upb_mobile/authentication/view/edit_profile_page.dart';
import 'package:acs_upb_mobile/main.dart';
import 'package:acs_upb_mobile/pages/classes/model/class.dart';
import 'package:acs_upb_mobile/pages/classes/service/class_provider.dart';
import 'package:acs_upb_mobile/pages/classes/view/class_view.dart';
import 'package:acs_upb_mobile/pages/classes/view/classes_page.dart';
import 'package:acs_upb_mobile/pages/classes/view/grading_view.dart';
import 'package:acs_upb_mobile/pages/classes/view/shortcut_view.dart';
import 'package:acs_upb_mobile/pages/faq/model/question.dart';
import 'package:acs_upb_mobile/pages/faq/service/question_provider.dart';
import 'package:acs_upb_mobile/pages/faq/view/faq_page.dart';
import 'package:acs_upb_mobile/pages/filter/model/filter.dart';
import 'package:acs_upb_mobile/pages/filter/service/filter_provider.dart';
import 'package:acs_upb_mobile/pages/filter/view/filter_page.dart';
import 'package:acs_upb_mobile/pages/home/home_page.dart';
import 'package:acs_upb_mobile/pages/news_feed/model/news_feed_item.dart';
import 'package:acs_upb_mobile/pages/news_feed/service/news_provider.dart';
import 'package:acs_upb_mobile/pages/news_feed/view/news_feed_page.dart';
import 'package:acs_upb_mobile/pages/people/model/person.dart';
import 'package:acs_upb_mobile/pages/people/service/person_provider.dart';
import 'package:acs_upb_mobile/pages/people/view/people_page.dart';
import 'package:acs_upb_mobile/pages/people/view/person_view.dart';
import 'package:acs_upb_mobile/pages/portal/model/website.dart';
import 'package:acs_upb_mobile/pages/portal/service/website_provider.dart';
import 'package:acs_upb_mobile/pages/portal/view/portal_page.dart';
import 'package:acs_upb_mobile/pages/portal/view/website_view.dart';
import 'package:acs_upb_mobile/pages/settings/service/request_provider.dart';
import 'package:acs_upb_mobile/pages/settings/view/request_permissions.dart';
import 'package:acs_upb_mobile/pages/settings/view/settings_page.dart';
import 'package:acs_upb_mobile/pages/timetable/model/academic_calendar.dart';
import 'package:acs_upb_mobile/pages/timetable/model/events/all_day_event.dart';
import 'package:acs_upb_mobile/pages/timetable/model/events/class_event.dart';
import 'package:acs_upb_mobile/pages/timetable/model/events/recurring_event.dart';
import 'package:acs_upb_mobile/pages/timetable/model/events/uni_event.dart';
import 'package:acs_upb_mobile/pages/timetable/service/uni_event_provider.dart';
import 'package:acs_upb_mobile/pages/timetable/view/events/add_event_view.dart';
import 'package:acs_upb_mobile/pages/timetable/view/events/event_view.dart';
import 'package:acs_upb_mobile/pages/timetable/view/timetable_page.dart';
import 'package:acs_upb_mobile/resources/locale_provider.dart';
import 'package:acs_upb_mobile/resources/utils.dart';
import 'package:acs_upb_mobile/widgets/search_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:preferences/preferences.dart';
import 'package:provider/provider.dart';
import 'package:rrule/rrule.dart';
import 'package:time_machine/time_machine.dart' hide Offset;
import 'package:timetable/src/header/week_indicator.dart';

import 'firebase_mock.dart';
import 'test_utils.dart';

// These tests open each page in the app on multiple screen sizes to make sure
// nothing overflows/breaks.

class MockAuthProvider extends Mock implements AuthProvider {}

class MockWebsiteProvider extends Mock implements WebsiteProvider {}

class MockFilterProvider extends Mock implements FilterProvider {}

class MockClassProvider extends Mock implements ClassProvider {}

class MockPersonProvider extends Mock implements PersonProvider {}

class MockQuestionProvider extends Mock implements QuestionProvider {}

class MockUniEventProvider extends Mock implements UniEventProvider {}

class MockNewsProvider extends Mock implements NewsProvider {}

class MockRequestProvider extends Mock implements RequestProvider {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

Future<void> main() async {
  AuthProvider mockAuthProvider;
  WebsiteProvider mockWebsiteProvider;
  FilterProvider mockFilterProvider;
  ClassProvider mockClassProvider;
  PersonProvider mockPersonProvider;
  MockQuestionProvider mockQuestionProvider;
  MockNewsProvider mockNewsProvider;
  UniEventProvider mockEventProvider;
  RequestProvider mockRequestProvider;

  setupFirebaseAuthMocks();
  await Firebase.initializeApp();

  // Test layout for different screen sizes
  // TODO(AdrianMargineanu): Use Flutter driver for integration tests, setting screen sizes here isn't reliable
  final screenSizes = <Size>[
    // Phone
    const Size(720, 1280),
    // Tablet
    const Size(600, 1024),
  ];

  // Add landscape mode sizes
  screenSizes.addAll(List<Size>.from(screenSizes)
      .map((size) => Size(size.height, size.width)));

  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildApp() => MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>(create: (_) => mockAuthProvider),
          ChangeNotifierProvider<WebsiteProvider>(
              create: (_) => mockWebsiteProvider),
          ChangeNotifierProvider<FilterProvider>(
              create: (_) => mockFilterProvider),
          ChangeNotifierProvider<ClassProvider>(
              create: (_) => mockClassProvider),
          ChangeNotifierProvider<PersonProvider>(
              create: (_) => mockPersonProvider),
          ChangeNotifierProvider<QuestionProvider>(
              create: (_) => mockQuestionProvider),
          ChangeNotifierProvider<NewsProvider>(create: (_) => mockNewsProvider),
          ChangeNotifierProvider<UniEventProvider>(
              create: (_) => mockEventProvider),
          Provider<RequestProvider>(create: (_) => mockRequestProvider),
        ],
        child: const MyApp(),
      );

  setUp(() async {
    WidgetsFlutterBinding.ensureInitialized();
    PrefService.enableCaching();
    PrefService.cache = {};
    PrefService.setString('language', 'en');

    await Firebase.initializeApp();

    LocaleProvider.cultures = testCultures;
    LocaleProvider.rruleL10ns = {'en': await RruleL10nTest.create()};

    Utils.packageInfo = PackageInfo(
        version: '1.2.7', buildNumber: '6', appName: 'ACS UPB Mobile');

    // Pretend an anonymous user is already logged in
    mockAuthProvider = MockAuthProvider();
    when(mockAuthProvider.isAuthenticated).thenReturn(true);
    // ignore: invalid_use_of_protected_member
    when(mockAuthProvider.hasListeners).thenReturn(false);
    when(mockAuthProvider.isAnonymous).thenReturn(true);
    when(mockAuthProvider.currentUser).thenAnswer((_) => Future.value(null));
    when(mockAuthProvider.isVerified).thenAnswer((_) => Future.value(false));

    mockWebsiteProvider = MockWebsiteProvider();
    // ignore: invalid_use_of_protected_member
    when(mockWebsiteProvider.hasListeners).thenReturn(false);
    when(mockWebsiteProvider.deleteWebsite(any, context: anyNamed('context')))
        .thenAnswer((_) => Future.value(true));
    when(mockAuthProvider.getProfilePictureURL(context: anyNamed('context')))
        .thenAnswer((_) => Future.value(null));
    when(mockWebsiteProvider.fetchWebsites(any, context: anyNamed('context')))
        .thenAnswer((_) => Future.value([
              Website(
                  id: '1',
                  relevance: null,
                  category: WebsiteCategory.learning,
                  infoByLocale: {'en': 'info-en', 'ro': 'info-ro'},
                  label: 'Moodle1',
                  link: 'http://acs.curs.pub.ro/',
                  isPrivate: false,
                  source: 'official'),
              Website(
                  id: '2',
                  relevance: null,
                  category: WebsiteCategory.learning,
                  infoByLocale: {},
                  label: 'OCW1',
                  link: 'https://ocw.cs.pub.ro/',
                  isPrivate: false,
                  source: 'official'),
              Website(
                  id: '3',
                  relevance: null,
                  category: WebsiteCategory.learning,
                  infoByLocale: {'en': 'info-en', 'ro': 'info-ro'},
                  label: 'Moodle2',
                  link: 'http://acs.curs.pub.ro/',
                  isPrivate: false,
                  source: 'official'),
              Website(
                  id: '4',
                  relevance: null,
                  category: WebsiteCategory.learning,
                  infoByLocale: {},
                  label: 'OCW2',
                  link: 'https://ocw.cs.pub.ro/',
                  isPrivate: false,
                  source: 'official'),
              Website(
                  id: '5',
                  relevance: null,
                  category: WebsiteCategory.association,
                  infoByLocale: {},
                  label: 'LSAC1',
                  link: 'https://lsacbucuresti.ro/',
                  isPrivate: false,
                  source: 'official'),
              Website(
                  id: '6',
                  relevance: null,
                  category: WebsiteCategory.administrative,
                  infoByLocale: {},
                  label: 'LSAC2',
                  link: 'https://lsacbucuresti.ro/',
                  isPrivate: false,
                  source: 'official'),
              Website(
                  id: '7',
                  relevance: null,
                  category: WebsiteCategory.resource,
                  infoByLocale: {},
                  label: 'LSAC3',
                  link: 'https://lsacbucuresti.ro/',
                  isPrivate: false,
                  source: 'official'),
              Website(
                  id: '8',
                  relevance: null,
                  category: WebsiteCategory.other,
                  infoByLocale: {},
                  label: 'LSAC4',
                  link: 'https://lsacbucuresti.ro/',
                  isPrivate: false,
                  source: 'official'),
            ]));
    when(mockWebsiteProvider.fetchFavouriteWebsites(
            uid: anyNamed('uid'), context: anyNamed('context')))
        .thenAnswer((_) async => (await mockWebsiteProvider.fetchWebsites(any,
                context: anyNamed('context')))
            .take(3));

    mockFilterProvider = MockFilterProvider();
    // ignore: invalid_use_of_protected_member
    when(mockFilterProvider.hasListeners).thenReturn(false);
    when(mockFilterProvider.filterEnabled).thenReturn(true);
    final filter = Filter(
        localizedLevelNames: [
          {'en': 'Degree', 'ro': 'Nivel de studiu'},
          {'en': 'Major', 'ro': 'Specializare'},
          {'en': 'Year', 'ro': 'An'},
          {'en': 'Series', 'ro': 'Serie'},
          {'en': 'Group', 'ro': 'Group'}
        ],
        root: FilterNode(name: 'All', value: true, children: [
          FilterNode(name: 'BSc', value: true, children: [
            FilterNode(name: 'CTI', value: true, children: [
              FilterNode(name: 'CTI-1', value: true, children: [
                FilterNode(name: '1-CA'),
                FilterNode(
                  name: '1-CB',
                  value: true,
                  children: [
                    FilterNode(name: '311CB'),
                    FilterNode(name: '312CB'),
                    FilterNode(name: '313CB'),
                    FilterNode(
                      name: '314CB',
                      value: true,
                    ),
                  ],
                ),
                FilterNode(name: '1-CC'),
                FilterNode(
                  name: '1-CD',
                  children: [
                    FilterNode(name: '311CD'),
                    FilterNode(name: '312CD'),
                    FilterNode(name: '313CD'),
                    FilterNode(name: '314CD'),
                  ],
                ),
              ]),
              FilterNode(
                name: 'CTI-2',
              ),
              FilterNode(
                name: 'CTI-3',
              ),
              FilterNode(
                name: 'CTI-4',
              ),
            ]),
            FilterNode(name: 'IS')
          ]),
          FilterNode(name: 'MSc', children: [
            FilterNode(
              name: 'IA',
            ),
            FilterNode(name: 'SPRC'),
          ])
        ]));
    when(mockFilterProvider.cachedFilter).thenReturn(filter);
    when(mockFilterProvider.fetchFilter(context: anyNamed('context')))
        .thenAnswer((_) => Future.value(filter));

    mockClassProvider = MockClassProvider();
    // ignore: invalid_use_of_protected_member
    when(mockClassProvider.hasListeners).thenReturn(false);
    final userClassHeaders = [
      ClassHeader(
        id: '3',
        name: 'Programming',
        acronym: 'PC',
        category: 'A',
      ),
      ClassHeader(
        id: '4',
        name: 'Physics',
        acronym: 'PH',
        category: 'D',
      )
    ];
    when(mockClassProvider.userClassHeadersCache).thenReturn(userClassHeaders);
    when(mockClassProvider.fetchClassHeaders(uid: anyNamed('uid')))
        .thenAnswer((_) => Future.value([
              ClassHeader(
                id: '1',
                name: 'Maths 1',
                acronym: 'M1',
                category: 'A/B',
              ),
              ClassHeader(
                id: '2',
                name: 'Maths 2',
                acronym: 'M2',
                category: 'A/C',
              ),
            ] +
            userClassHeaders));
    when(mockClassProvider.fetchUserClassIds(
            uid: anyNamed('uid'), context: anyNamed('context')))
        .thenAnswer((_) => Future.value(['3', '4']));
    when(mockClassProvider.fetchClassInfo(any, context: anyNamed('context')))
        .thenAnswer((_) => Future.value(
              Class(
                header: ClassHeader(
                  id: '3',
                  name: 'Programming',
                  acronym: 'PC',
                  category: 'A',
                ),
                shortcuts: [
                  Shortcut(
                      type: ShortcutType.main,
                      name: 'OCW',
                      link: 'https://ocw.cs.pub.ro/courses/programare'),
                  Shortcut(
                      type: ShortcutType.other,
                      name: 'Google',
                      link: 'https://google.com'),
                ],
                grading: {
                  'Exam': 4,
                  'Lab': 1.5,
                  'Homework': 4,
                  'Extra homework': 0.5,
                },
              ),
            ));

    mockPersonProvider = MockPersonProvider();
    // ignore: invalid_use_of_protected_member
    when(mockPersonProvider.hasListeners).thenReturn(false);
    when(mockPersonProvider.fetchPeople(context: anyNamed('context')))
        .thenAnswer((_) => Future.value([
              Person(
                name: 'John Doe',
                email: 'john.doe@cs.pub.ro',
                phone: '0712345678',
                office: 'AB123',
                position: 'Associate Professor, Dr., Department Council',
                photo: 'https://cdn.worldvectorlogo.com/logos/flutter-logo.svg',
              ),
              Person(
                name: 'Jane Doe',
                email: 'jane.doe@cs.pub.ro',
                phone: '-',
                office: 'Narnia',
                position: 'Professor, Dr.',
                photo: 'https://cdn.worldvectorlogo.com/logos/flutter-logo.svg',
              ),
              Person(
                name: 'Mary Poppins',
                email: 'supercalifragilistic.expialidocious@cs.pub.ro',
                phone: '0712-345-678',
                office: 'Mary Poppins\' office',
                position: 'Professor, Dr., Head of Department',
                photo: 'https://cdn.worldvectorlogo.com/logos/flutter-logo.svg',
              ),
            ]));

    when(mockPersonProvider.mostRecentLecturer(any,
            context: anyNamed('context')))
        .thenAnswer((_) => Future.value('Jane Doe'));

    mockQuestionProvider = MockQuestionProvider();
    // ignore: invalid_use_of_protected_member
    when(mockQuestionProvider.hasListeners).thenReturn(false);
    when(mockQuestionProvider.fetchQuestions(context: anyNamed('context')))
        .thenAnswer((_) => Future.value(<Question>[
              Question(
                  question: 'Care este programul la secretariat?',
                  answer:
                      'Secretariatul este deschis în timpul săptămânii între orele 9:00 si 11:00.',
                  tags: ['Licență']),
              Question(
                  question: 'Cum mă conectez la eduroam?',
                  answer:
                      'Conectarea în rețeaua *eduroam* se face pe baza aceluiași cont folosit și pe site-ul de cursuri.',
                  tags: ['Conectare', 'Informații'])
            ]));
    when(mockQuestionProvider.fetchQuestions(limit: anyNamed('limit')))
        .thenAnswer((_) => Future.value(<Question>[
              Question(
                  question: 'Care este programul la secretariat?',
                  answer:
                      'Secretariatul este deschis în timpul săptămânii între orele 9:00 si 11:00.',
                  tags: ['Licență']),
              Question(
                  question: 'Cum mă conectez la eduroam?',
                  answer:
                      'Conectarea în rețeaua *eduroam* se face pe baza aceluiași cont folosit și pe site-ul de cursuri.',
                  tags: ['Conectare', 'Informații'])
            ]));

    mockNewsProvider = MockNewsProvider();
    // ignore: invalid_use_of_protected_member
    when(mockNewsProvider.hasListeners).thenReturn(false);
    when(mockNewsProvider.fetchNewsFeedItems(context: anyNamed('context')))
        .thenAnswer((_) => Future.value(<NewsFeedItem>[
              NewsFeedItem(
                  '03.10.2020',
                  'Cazarea studentilor de anul II licenta',
                  'https://acs.pub.ro/noutati/cazarea-studentilor-de-anul-ii-licenta/'),
              NewsFeedItem(
                  '03.10.2020',
                  'Festivitatea de deschidere a anului universitar 2020-2021',
                  'https://acs.pub.ro/noutati/festivitatea-de-deschidere-a-anului-universitar-2020-2021/')
            ]));
    when(mockNewsProvider.fetchNewsFeedItems(limit: anyNamed('limit')))
        .thenAnswer((_) => Future.value(<NewsFeedItem>[
              NewsFeedItem(
                  '03.10.2020',
                  'Cazarea studentilor de anul II licenta',
                  'https://acs.pub.ro/noutati/cazarea-studentilor-de-anul-ii-licenta/'),
              NewsFeedItem(
                  '03.10.2020',
                  'Festivitatea de deschidere a anului universitar 2020-2021',
                  'https://acs.pub.ro/noutati/festivitatea-de-deschidere-a-anului-universitar-2020-2021/')
            ]));

    mockEventProvider = MockUniEventProvider();
    // ignore: invalid_use_of_protected_member
    when(mockEventProvider.hasListeners).thenReturn(false);
    final now = LocalDate.today();
    final weekStart = now.subtractDays(now.dayOfWeek - DayOfWeek.monday);
    final holidays = [
      // Holiday on Tuesday and Wednesday next week
      AllDayUniEvent(
        name: 'Holiday',
        start: weekStart.addWeeks(1).addDays(1),
        end: weekStart.addWeeks(1).addDays(2),
        id: 'holiday0',
      ),
      AllDayUniEvent(
        name: 'Inter-semester holiday',
        start: weekStart.addWeeks(2).subtractDays(2),
        end: weekStart.addWeeks(3).subtractDays(1),
        id: 'holiday1',
      ),
    ];
    final calendar = AcademicCalendar(
      id: '2020',
      semesters: [
        AllDayUniEvent(
          start: weekStart,
          end: weekStart.addWeeks(2).subtractDays(3),
          id: 'semester1',
        ),
        AllDayUniEvent(
          start: weekStart.addWeeks(3),
          end: weekStart.addWeeks(5).subtractDays(3),
          id: 'semester2',
        ),
      ],
      holidays: holidays,
    );
    when(mockEventProvider.fetchCalendars())
        .thenAnswer((_) => Future.value({'2020': calendar}));
    final rruleEveryWeekFirstSem = RecurrenceRule(
      frequency: Frequency.weekly,
      interval: 1,
      until: weekStart.addWeeks(2).subtractDays(3).atMidnight(),
    );
    final rruleEveryTwoWeeksFirstSem = RecurrenceRule(
      frequency: Frequency.weekly,
      interval: 2,
      until: weekStart.addWeeks(2).subtractDays(3).atMidnight(),
    );
    final rruleEveryWeek = RecurrenceRule(
      frequency: Frequency.weekly,
      interval: 1,
    );
    final rruleEveryTwoWeeks = RecurrenceRule(
      frequency: Frequency.weekly,
      interval: 2,
    );
    const duration = Period(hours: 2);
    final events = [
      RecurringUniEvent(
        name: 'M1',
        calendar: calendar,
        rrule: rruleEveryWeekFirstSem,
        start: weekStart.at(LocalTime(8, 0, 0)),
        duration: duration,
        id: '0',
      ),
      RecurringUniEvent(
        name: 'M2',
        calendar: calendar,
        rrule: rruleEveryTwoWeeksFirstSem,
        start: weekStart.at(LocalTime(10, 0, 0)),
        duration: duration,
        id: '1',
      ),
      RecurringUniEvent(
        name: 'T1',
        calendar: calendar,
        rrule: rruleEveryWeekFirstSem,
        start: weekStart.addDays(1).at(LocalTime(8, 0, 0)),
        duration: duration,
        id: '2',
      ),
      RecurringUniEvent(
        name: 'T2',
        calendar: calendar,
        rrule: rruleEveryTwoWeeksFirstSem,
        start: weekStart.addDays(1).at(LocalTime(9, 0, 0)),
        duration: duration,
        id: '3',
      ),
      RecurringUniEvent(
        name: 'W1',
        calendar: calendar,
        rrule: rruleEveryWeekFirstSem,
        start: weekStart.addDays(2).at(LocalTime(8, 0, 0)),
        duration: duration,
        id: '4',
      ),
      RecurringUniEvent(
        name: 'W2',
        rrule: rruleEveryWeek,
        start: weekStart.addDays(2).at(LocalTime(10, 0, 0)),
        duration: duration,
        id: '5',
      ),
      RecurringUniEvent(
        name: 'W3',
        rrule: rruleEveryTwoWeeks,
        start: weekStart.addDays(2).at(LocalTime(12, 0, 0)),
        duration: duration,
        id: '6',
      ),
      ClassEvent(
        classHeader: userClassHeaders[0],
        type: UniEventType.lecture,
        teacher: Person(name: 'Jane Doe'),
        location: 'AB123',
        degree: 'BSc',
        relevance: ['314CB'],
        calendar: calendar,
        rrule: rruleEveryWeek,
        start: weekStart.addDays(3).at(LocalTime(10, 0, 0)),
        duration: duration,
        id: '7',
      ),
      RecurringUniEvent(
        classHeader: userClassHeaders[1],
        type: UniEventType.lecture,
        location: 'AB123',
        degree: 'BSc',
        relevance: ['314CB'],
        calendar: calendar,
        rrule: rruleEveryTwoWeeks,
        start: weekStart.addDays(3).at(LocalTime(12, 0, 0)),
        duration: duration,
        id: '8',
      ),
      RecurringUniEvent(
        name: 'F1',
        calendar: calendar,
        rrule: rruleEveryWeek,
        start: weekStart.addDays(4).at(LocalTime(10, 0, 0)),
        duration: duration,
        id: '9',
      ),
      RecurringUniEvent(
        name: 'F2',
        calendar: calendar,
        rrule: rruleEveryTwoWeeks,
        start: weekStart.addDays(4).at(LocalTime(12, 0, 0)),
        duration: duration,
        id: '10',
      ),
    ];
    when(mockEventProvider.getAllDayEventsIntersecting(any))
        .thenAnswer((invocation) {
      final DateInterval interval = invocation.positionalArguments[0];
      return Stream.value(holidays
          .map((holiday) =>
              holiday.generateInstances(intersectingInterval: interval))
          .expand((e) => e));
    });
    when(mockEventProvider.getPartDayEventsIntersecting(any))
        .thenAnswer((invocation) {
      final LocalDate date = invocation.positionalArguments[0];
      return Stream.value(events
          .map((event) => event.generateInstances(
              intersectingInterval: DateInterval(date, date)))
          .expand((e) => e));
    });
    when(mockEventProvider.empty).thenReturn(false);
    when(mockEventProvider.deleteEvent(any, context: anyNamed('context')))
        .thenAnswer((_) => Future.value(true));
    when(mockEventProvider.updateEvent(any, context: anyNamed('context')))
        .thenAnswer((_) => Future.value(true));
    when(mockEventProvider.addEvent(any, context: anyNamed('context')))
        .thenAnswer((_) => Future.value(true));

    mockRequestProvider = MockRequestProvider();
    when(mockRequestProvider.makeRequest(any, context: anyNamed('context')))
        .thenAnswer((_) => Future.value(true));
    when(mockRequestProvider.userAlreadyRequested(any,
            context: anyNamed('context')))
        .thenAnswer((_) => Future.value(false));
  });

  group('Home', () {
    setUp(() {
      when(mockAuthProvider.currentUser).thenAnswer((_) => Future.value(User(
          uid: '0',
          firstName: 'John',
          lastName: 'Doe',
          sources: ['official'])));
      when(mockAuthProvider.currentUserFromCache).thenReturn(User(
          uid: '0', firstName: 'John', lastName: 'Doe', sources: ['official']));
    });
    for (final size in screenSizes) {
      testWidgets('${size.width}x${size.height}', (WidgetTester tester) async {
        await binding.setSurfaceSize(size);

        await tester.pumpWidget(buildApp());
        await tester.pumpAndSettle();

        expect(find.byType(HomePage), findsOneWidget);

        // Open home
        await tester.tap(find.byIcon(Icons.home));
        await tester.pumpAndSettle();

        expect(find.byType(HomePage), findsOneWidget);
      });
    }
  });

  group('Timetable', () {
    setUp(() {
      when(mockAuthProvider.currentUser).thenAnswer((_) => Future.value(User(
          uid: '0',
          firstName: 'John',
          lastName: 'Doe',
          permissionLevel: 3,
          sources: ['official'])));
      when(mockAuthProvider.currentUserFromCache).thenReturn(User(
          uid: '0',
          firstName: 'John',
          lastName: 'Doe',
          permissionLevel: 3,
          sources: ['official']));
      when(mockAuthProvider.isAuthenticated).thenReturn(true);
      when(mockAuthProvider.isAnonymous).thenReturn(false);
      when(mockAuthProvider.uid).thenReturn('0');
    });

    group('Timetable no events/no classes', () {
      setUp(() {
        when(mockAuthProvider.currentUser).thenAnswer((_) => Future.value(User(
            uid: '0',
            firstName: 'John',
            lastName: 'Doe',
            sources: ['official'])));
        when(mockAuthProvider.currentUserFromCache).thenReturn(User(
            uid: '0',
            firstName: 'John',
            lastName: 'Doe',
            sources: ['official']));
        when(mockEventProvider.getAllDayEventsIntersecting(any))
            .thenAnswer((_) => Stream.value([]));
        when(mockEventProvider.getPartDayEventsIntersecting(any))
            .thenAnswer((_) => Stream.value([]));
        when(mockEventProvider.empty).thenReturn(true);

        when(mockClassProvider.userClassHeadersCache).thenReturn(null);
      });

      for (final size in screenSizes) {
        testWidgets('${size.width}x${size.height}',
            (WidgetTester tester) async {
          await binding.setSurfaceSize(size);

          await tester.pumpWidget(buildApp());
          await tester.pumpAndSettle();

          // Open timetable
          await tester.tap(find.byIcon(Icons.calendar_today_outlined));
          await tester.pumpAndSettle();

          expect(find.byType(TimetablePage), findsOneWidget);
          expect(find.text('No events to show'), findsOneWidget);

          await tester.tap(find.text('CHOOSE CLASSES'));
          await tester.pumpAndSettle();

          expect(find.byType(AddClassesPage), findsOneWidget);
        });
      }
    });

    group('Timetable no events/no filter', () {
      setUp(() {
        when(mockEventProvider.getAllDayEventsIntersecting(any))
            .thenAnswer((_) => Stream.value([]));
        when(mockEventProvider.getPartDayEventsIntersecting(any))
            .thenAnswer((_) => Stream.value([]));
        when(mockEventProvider.empty).thenReturn(true);

        when(mockFilterProvider.cachedFilter).thenReturn(null);
      });

      for (final size in screenSizes) {
        testWidgets('${size.width}x${size.height}',
            (WidgetTester tester) async {
          await binding.setSurfaceSize(size);

          await tester.pumpWidget(buildApp());
          await tester.pumpAndSettle();

          // Open timetable
          await tester.tap(find.byIcon(Icons.calendar_today_outlined));
          await tester.pumpAndSettle();

          expect(find.byType(TimetablePage), findsOneWidget);
          expect(find.text('No events to show'), findsOneWidget);

          await tester.tap(find.text('OPEN FILTER'));
          await tester.pumpAndSettle();

          expect(find.byType(FilterPage), findsOneWidget);
        });
      }
    });

    group('Timetable no events/no permissions', () {
      setUp(() {
        when(mockAuthProvider.currentUser).thenAnswer((_) => Future.value(User(
            uid: '0',
            firstName: 'John',
            lastName: 'Doe',
            permissionLevel: 0,
            sources: ['official'])));
        when(mockAuthProvider.currentUserFromCache).thenReturn(User(
            uid: '0',
            firstName: 'John',
            lastName: 'Doe',
            permissionLevel: 0,
            sources: ['official']));
        when(mockAuthProvider.isAnonymous).thenReturn(false);
        when(mockAuthProvider.isVerified).thenAnswer((_) => Future.value(true));

        when(mockEventProvider.getAllDayEventsIntersecting(any))
            .thenAnswer((_) => Stream.value([]));
        when(mockEventProvider.getPartDayEventsIntersecting(any))
            .thenAnswer((_) => Stream.value([]));
        when(mockEventProvider.empty).thenReturn(true);
      });

      for (final size in screenSizes) {
        testWidgets('${size.width}x${size.height}',
            (WidgetTester tester) async {
          await binding.setSurfaceSize(size);

          await tester.pumpWidget(buildApp());
          await tester.pumpAndSettle();

          // Open timetable
          await tester.tap(find.byIcon(Icons.calendar_today_outlined));
          await tester.pumpAndSettle();

          expect(find.byType(TimetablePage), findsOneWidget);
          expect(find.text('No events to show'), findsOneWidget);

          await tester.tap(find.text('REQUEST PERMISSIONS'));
          await tester.pumpAndSettle();

          expect(find.byType(RequestPermissionsPage), findsOneWidget);
        });
      }
    });

    group('Timetable no events/add some', () {
      setUp(() {
        when(mockEventProvider.getAllDayEventsIntersecting(any))
            .thenAnswer((_) => Stream.value([]));
        when(mockEventProvider.getPartDayEventsIntersecting(any))
            .thenAnswer((_) => Stream.value([]));
        when(mockEventProvider.empty).thenReturn(true);
      });

      for (final size in screenSizes) {
        testWidgets('${size.width}x${size.height}',
            (WidgetTester tester) async {
          await binding.setSurfaceSize(size);

          await tester.pumpWidget(buildApp());
          await tester.pumpAndSettle();

          // Open timetable
          await tester.tap(find.byIcon(Icons.calendar_today_outlined));
          await tester.pumpAndSettle();

          expect(find.byType(TimetablePage), findsOneWidget);
          expect(find.text('No events to show'), findsOneWidget);
          expect(
              find.byKey(const ValueKey('no_events_message')), findsOneWidget);

          await tester.tap(find.text('CANCEL'));
          await tester.pumpAndSettle();

          expect(find.text('No events to show'), findsNothing);
        });
      }
    });

    group('Timetable events', () {
      for (final size in screenSizes) {
        if (size.width > size.height) {
          // TODO(IoanaAlexandru): In landscape mode the test fails in a weird
          // way - it seems as if two weeks are visible at the same time, but
          // the behaviour cannot be reproduced on a device. Skipping this
          // test in landscape mode for now.
          continue;
        }

        testWidgets('${size.width}x${size.height}',
            (WidgetTester tester) async {
          await binding.setSurfaceSize(size);

          await tester.pumpWidget(buildApp());
          await tester.pumpAndSettle();

          // Open timetable
          await tester.tap(find.byIcon(Icons.calendar_today_outlined));
          await tester.pumpAndSettle();

          expect(find.byType(TimetablePage), findsOneWidget);

          // Scroll to previous week
          await tester.drag(find.text('Tue'), Offset(size.width - 30, 0));
          await tester.pumpAndSettle();

          // Expect previous week
          final previousWeek = WeekYearRules.iso
              .getWeekOfWeekYear(LocalDate.today().subtractWeeks(1));
          expect(
              find.byWidgetPredicate((widget) =>
                  widget is WeekIndicator &&
                  widget.week.toString() == previousWeek.toString()),
              findsOneWidget);

          expect(find.text('Holiday'), findsNothing);
          expect(find.text('Inter-semester holiday'), findsNothing);
          expect(find.text('M1'), findsNothing);
          expect(find.text('M2'), findsNothing);
          expect(find.text('T1'), findsNothing);
          expect(find.text('T2'), findsNothing);
          expect(find.text('W1'), findsNothing);
          expect(find.text('W2'), findsNothing);
          expect(find.text('W3'), findsNothing);
          expect(find.text('PC'), findsNothing);
          expect(find.text('PH'), findsNothing);
          expect(find.text('F1'), findsNothing);
          expect(find.text('F2'), findsNothing);

          // Scroll back to current week
          await tester.drag(find.text('Sun'), Offset(-size.width + 10, 0));
          await tester.pumpAndSettle();

          // Expect current week
          final currentWeek =
              WeekYearRules.iso.getWeekOfWeekYear(LocalDate.today());
          expect(
              find.byWidgetPredicate((widget) =>
                  widget is WeekIndicator &&
                  widget.week.toString() == currentWeek.toString()),
              findsOneWidget);

          expect(find.text('Holiday'), findsNothing);
          expect(find.text('Inter-semester holiday'), findsNothing);
          expect(find.text('M1'), findsOneWidget);
          expect(find.text('M2'), findsOneWidget);
          expect(find.text('T1'), findsOneWidget);
          expect(find.text('T2'), findsOneWidget);
          expect(find.text('W1'), findsOneWidget);
          expect(find.text('W2'), findsOneWidget);
          expect(find.text('W3'), findsOneWidget);
          expect(find.text('PC'), findsOneWidget);
          expect(find.text('PH'), findsOneWidget);
          expect(find.text('F1'), findsOneWidget);
          expect(find.text('F2'), findsOneWidget);

          // Scroll to next week
          await tester.drag(find.text('Sun'), Offset(-size.width + 10, 0));
          await tester.pumpAndSettle();

          // Expect next week
          final nextWeek = WeekYearRules.iso
              .getWeekOfWeekYear(LocalDate.today().addWeeks(1));
          expect(
              find.byWidgetPredicate((widget) =>
                  widget is WeekIndicator &&
                  widget.week.toString() == nextWeek.toString()),
              findsOneWidget);

          expect(find.text('Holiday'), findsOneWidget);
          expect(find.text('Inter-semester holiday'), findsOneWidget);
          expect(find.text('M1'), findsOneWidget);
          expect(find.text('M2'), findsNothing);
          expect(find.text('T1'), findsNothing);
          expect(find.text('T2'), findsNothing);
          expect(find.text('W1'), findsNothing);
          expect(find.text('W2'), findsOneWidget);
          expect(find.text('W3'), findsNothing);
          expect(find.text('PC'), findsOneWidget);
          expect(find.text('PH'), findsNothing);
          expect(find.text('F1'), findsOneWidget);
          expect(find.text('F2'), findsNothing);

          // Scroll to next week
          await tester.drag(find.text('Sun'), Offset(-size.width + 10, 0));
          await tester.pumpAndSettle();

          // Expect next week
          final nextNextWeek = WeekYearRules.iso
              .getWeekOfWeekYear(LocalDate.today().addWeeks(2));
          expect(
              find.byWidgetPredicate((widget) =>
                  widget is WeekIndicator &&
                  widget.week.toString() == nextNextWeek.toString()),
              findsOneWidget);

          expect(find.text('Holiday'), findsNothing);
          expect(find.text('Inter-semester holiday'), findsOneWidget);
          expect(find.text('M1'), findsNothing);
          expect(find.text('M2'), findsNothing);
          expect(find.text('T1'), findsNothing);
          expect(find.text('T2'), findsNothing);
          expect(find.text('W1'), findsNothing);
          expect(find.text('W2'), findsOneWidget);
          expect(find.text('W3'), findsOneWidget);
          expect(find.text('PC'), findsNothing);
          expect(find.text('PH'), findsNothing);
          expect(find.text('F1'), findsNothing);
          expect(find.text('F2'), findsNothing);

          // Scroll to next week
          await tester.drag(find.text('Sun'), Offset(-size.width + 10, 0));
          await tester.pumpAndSettle();

          // Expect next week
          final nextNextNextWeek = WeekYearRules.iso
              .getWeekOfWeekYear(LocalDate.today().addWeeks(3));
          expect(
              find.byWidgetPredicate((widget) =>
                  widget is WeekIndicator &&
                  widget.week.toString() == nextNextNextWeek.toString()),
              findsOneWidget);

          expect(find.text('Holiday'), findsNothing);
          expect(find.text('Inter-semester holiday'), findsNothing);
          expect(find.text('M1'), findsNothing);
          expect(find.text('M2'), findsNothing);
          expect(find.text('T1'), findsNothing);
          expect(find.text('T2'), findsNothing);
          expect(find.text('W1'), findsNothing);
          expect(find.text('W2'), findsOneWidget);
          expect(find.text('W3'), findsNothing);
          expect(find.text('PC'), findsOneWidget);
          expect(find.text('PH'), findsOneWidget);
          expect(find.text('F1'), findsOneWidget);
          expect(find.text('F2'), findsOneWidget);

          // Navigate to today
          await tester.tap(find.byIcon(Icons.today_outlined));
          await tester.pumpAndSettle();

          // Expect current week
          expect(
              find.byWidgetPredicate((widget) =>
                  widget is WeekIndicator &&
                  widget.week.toString() == currentWeek.toString()),
              findsOneWidget);
        });
      }
    });

    group('Event page - open all day event', () {
      for (final size in screenSizes) {
        testWidgets('${size.width}x${size.height}',
            (WidgetTester tester) async {
          await binding.setSurfaceSize(size);

          await tester.pumpWidget(buildApp());
          await tester.pumpAndSettle();

          // Open timetable
          await tester.tap(find.byIcon(Icons.calendar_today_outlined));
          await tester.pumpAndSettle();

          // Expect current week
          final currentWeek =
              WeekYearRules.iso.getWeekOfWeekYear(LocalDate.today());
          expect(
              find.byWidgetPredicate((widget) =>
                  widget is WeekIndicator &&
                  widget.week.toString() == currentWeek.toString()),
              findsOneWidget);

          // Scroll to next week
          await tester.drag(find.text('Sun'), Offset(-size.width + 10, 0));
          await tester.pumpAndSettle();

          // Expect next week
          final nextWeek = WeekYearRules.iso
              .getWeekOfWeekYear(LocalDate.today().addWeeks(1));
          expect(
              find.byWidgetPredicate((widget) =>
                  widget is WeekIndicator &&
                  widget.week.toString() == nextWeek.toString()),
              findsOneWidget);

          // Open holiday event
          await tester.tap(find.text('Holiday'));
          await tester.pumpAndSettle();

          expect(find.byType(EventView), findsOneWidget);
        });
      }
    });

    group('Event page - add event', () {
      for (final size in screenSizes) {
        testWidgets('${size.width}x${size.height}',
            (WidgetTester tester) async {
          await binding.setSurfaceSize(size);

          await tester.pumpWidget(buildApp());
          await tester.pumpAndSettle();

          // Open timetable
          await tester.tap(find.byIcon(Icons.calendar_today_outlined));
          await tester.pumpAndSettle();

          // Open add event page
          await tester
              .tapAt(tester.getCenter(find.text('Sat')).translate(0, 100));
          await tester.pumpAndSettle();

          expect(find.byType(AddEventView), findsOneWidget);

          // Select type
          await tester.tap(find.text('Type'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Seminar').last);
          await tester.pumpAndSettle();

          // Select class
          await tester.tap(find.text('Class'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Programming').last);
          await tester.pumpAndSettle();

          // Press back
          await tester.tap(find.byIcon(Icons.arrow_back));
          await tester.pumpAndSettle();

          await tester
              .tapAt(tester.getCenter(find.text('Sat')).translate(0, 100));
          await tester.pumpAndSettle();

          expect(find.byType(AddEventView), findsOneWidget);

          // Select type
          await tester.tap(find.text('Type'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Lecture').last);
          await tester.pumpAndSettle();

          // Select lecturer - partial name
          await tester.tap(find.byIcon(Icons.person_outlined));
          await tester.pumpAndSettle();
          await tester.enterText(find.byKey(const Key('Autocomplete')), 'John');
          await tester.pumpAndSettle();
          await tester.tap(find.text('John Doe'));
          await tester.pumpAndSettle();

          // Select lecturer - new name
          await tester.tap(find.byIcon(Icons.person_outlined));
          await tester.pumpAndSettle();
          await tester.enterText(
              find.byKey(const Key('Autocomplete')), 'Isabel Steward');
          await tester.tap(find.text('Isabel Steward'));
          await tester.pumpAndSettle();

          // Select lecturer - check autocomplete suggestions
          await tester.tap(find.byIcon(Icons.person_outlined));
          await tester.pumpAndSettle();
          await tester.enterText(find.byKey(const Key('Autocomplete')), 'Doe');
          await tester.pumpAndSettle();

          expect(find.text('Jane Doe'), findsOneWidget);
          expect(find.text('John Doe'), findsOneWidget);

          await tester.tap(find.text('Jane Doe'));
          await tester.pumpAndSettle();
        });
      }
    });

    group('Event page - edit event', () {
      for (final size in screenSizes) {
        testWidgets('${size.width}x${size.height}',
            (WidgetTester tester) async {
          await binding.setSurfaceSize(size);

          await tester.pumpWidget(buildApp());
          await tester.pumpAndSettle();

          // Open timetable
          await tester.tap(find.byIcon(Icons.calendar_today_outlined));
          await tester.pumpAndSettle();

          // Open PC event
          await tester.tap(find.text('PC'));
          await tester.pumpAndSettle();

          expect(find.byType(EventView), findsOneWidget);

          // Open class page
          await tester.tap(find.text('Programming'));
          await tester.pumpAndSettle();

          expect(find.byType(ClassView), findsOneWidget);
          expect(find.byIcon(Icons.person_outlined), findsOneWidget);
          expect(find.byKey(const Key('LecturerCard')), findsOneWidget);

          // Press back
          await tester.tap(find.byIcon(Icons.arrow_back));
          await tester.pumpAndSettle();

          expect(find.byType(EventView), findsOneWidget);
          expect(find.byIcon(Icons.person_outlined), findsOneWidget);
          expect(find.text('Jane Doe'), findsOneWidget);

          await tester.tap(find.byIcon(Icons.person_outlined));
          await tester.pumpAndSettle();

          expect(find.byType(PersonView), findsOneWidget);

          // Press back
          await tester.tap(find.byIcon(Icons.arrow_back));
          await tester.pumpAndSettle();

          // Open edit event page
          await tester.tap(find.byIcon(Icons.edit_outlined));
          await tester.pumpAndSettle();

          expect(find.byType(AddEventView), findsOneWidget);
          expect(find.text('Lecturer'), findsOneWidget);
          expect(find.text('Location'), findsOneWidget);
          expect(find.text('Week'), findsOneWidget);
          expect(find.text('Day'), findsOneWidget);

          // Select lecturer
          await tester.tap(find.text('Lecturer'));
          await tester.pumpAndSettle();
          await tester.enterText(find.byKey(const Key('Autocomplete')), 'Doe');
          await tester.pumpAndSettle();

          expect(find.text('Jane Doe'), findsOneWidget);
          expect(find.text('John Doe'), findsOneWidget);

          await tester.enterText(
              find.byKey(const Key('Autocomplete')), 'John Doe');
          await tester.pumpAndSettle();

          FocusManager.instance.primaryFocus.unfocus();
          await tester.pumpAndSettle();
          await tester.tap(find.text('John Doe').last);
          await tester.pumpAndSettle();

          FocusManager.instance.primaryFocus.unfocus();
          await tester.pumpAndSettle();

          expect(find.text('Jane Doe'), findsNothing);
          expect(find.text('John Doe'), findsOneWidget);

          // Press save
          await tester.tap(find.text('Save'));
          await tester.pumpAndSettle(const Duration(seconds: 5));

          expect(find.byType(TimetablePage), findsOneWidget);

          // Open PC event
          await tester.tap(find.text('PC'));
          await tester.pumpAndSettle();

          expect(find.byType(EventView), findsOneWidget);
          expect(find.byIcon(Icons.person_outlined), findsOneWidget);

          // Press back
          await tester.tap(find.byIcon(Icons.arrow_back));
          await tester.pumpAndSettle();

          expect(find.byType(TimetablePage), findsOneWidget);
        });
      }
    });

    group('Event page - delete event', () {
      for (final size in screenSizes) {
        testWidgets('${size.width}x${size.height}',
            (WidgetTester tester) async {
          await binding.setSurfaceSize(size);

          await tester.pumpWidget(buildApp());
          await tester.pumpAndSettle();

          // Open timetable
          await tester.tap(find.byIcon(Icons.calendar_today_outlined));
          await tester.pumpAndSettle();

          // Open PH event
          await tester.tap(find.text('PH'));
          await tester.pumpAndSettle();

          expect(find.byType(EventView), findsOneWidget);

          // Open edit event page
          await tester.tap(find.byIcon(Icons.edit_outlined));
          await tester.pumpAndSettle();

          expect(find.byType(AddEventView), findsOneWidget);

          // Open delete dialog
          await tester.tap(find.byIcon(Icons.more_vert_outlined));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Delete event'));
          await tester.pumpAndSettle();

          // Confirm deletion
          expect(find.text('Are you sure you want to delete this event?'),
              findsOneWidget);
          await tester.tap(find.text('DELETE EVENT'));
          await tester.pumpAndSettle(const Duration(seconds: 5));

          verify(
              mockEventProvider.deleteEvent(any, context: anyNamed('context')));
          expect(find.byType(TimetablePage), findsOneWidget);
        });
      }
    });
  });

  group('Classes', () {
    group('Class', () {
      setUp(() {
        when(mockAuthProvider.currentUser).thenAnswer((_) => Future.value(User(
            uid: '0',
            firstName: 'John',
            lastName: 'Doe',
            sources: ['official'])));
        when(mockAuthProvider.currentUserFromCache).thenReturn(User(
            uid: '0',
            firstName: 'John',
            lastName: 'Doe',
            sources: ['official']));
        when(mockAuthProvider.isAuthenticated).thenReturn(true);
        when(mockAuthProvider.isAnonymous).thenReturn(false);
        when(mockAuthProvider.uid).thenReturn('0');
      });

      for (final size in screenSizes) {
        testWidgets('${size.width}x${size.height}',
            (WidgetTester tester) async {
          await binding.setSurfaceSize(size);

          await tester.pumpWidget(buildApp());
          await tester.pumpAndSettle();

          // Open timetable
          await tester.tap(find.byIcon(Icons.calendar_today_outlined));
          await tester.pumpAndSettle();

          // Open classes
          await tester.tap(find.byIcon(FeatherIcons.bookOpen));
          await tester.pumpAndSettle();

          // Open class view
          expect(find.byType(ClassesPage), findsOneWidget);
        });
      }
    });

    group('Add class', () {
      setUp(() {
        when(mockAuthProvider.currentUser).thenAnswer((_) => Future.value(User(
            uid: '0',
            firstName: 'John',
            lastName: 'Doe',
            sources: ['official'])));
        when(mockAuthProvider.currentUserFromCache).thenReturn(User(
            uid: '0',
            firstName: 'John',
            lastName: 'Doe',
            sources: ['official']));
        when(mockAuthProvider.isAuthenticated).thenReturn(true);
        when(mockAuthProvider.isAnonymous).thenReturn(false);
        when(mockAuthProvider.uid).thenReturn('0');
      });

      for (final size in screenSizes) {
        testWidgets('${size.width}x${size.height}',
            (WidgetTester tester) async {
          await binding.setSurfaceSize(size);

          await tester.pumpWidget(buildApp());
          await tester.pumpAndSettle();

          // Open timetable
          await tester.tap(find.byIcon(Icons.calendar_today_outlined));
          await tester.pumpAndSettle();

          // Open classes
          await tester.tap(find.byIcon(FeatherIcons.bookOpen));
          await tester.pumpAndSettle();

          // Open add class view
          await tester.tap(find.byIcon(Icons.edit_outlined));
          await tester.pumpAndSettle();

          expect(find.byType(AddClassesPage), findsOneWidget);

          // Save
          await tester.tap(find.text('Save'));
          await tester.pumpAndSettle();

          expect(find.byType(ClassesPage), findsOneWidget);
        });
      }
    });

    group('Class view', () {
      setUp(() {
        when(mockAuthProvider.currentUser).thenAnswer((_) => Future.value(User(
            uid: '0',
            firstName: 'John',
            lastName: 'Doe',
            permissionLevel: 3,
            sources: ['official'])));
        when(mockAuthProvider.currentUserFromCache).thenReturn(User(
            uid: '0',
            firstName: 'John',
            lastName: 'Doe',
            permissionLevel: 3,
            sources: ['official']));
        when(mockAuthProvider.isAuthenticated).thenReturn(true);
        when(mockAuthProvider.isAnonymous).thenReturn(false);
        when(mockAuthProvider.uid).thenReturn('0');
      });

      for (final size in screenSizes) {
        testWidgets('${size.width}x${size.height}',
            (WidgetTester tester) async {
          await binding.setSurfaceSize(size);

          await tester.pumpWidget(buildApp());
          await tester.pumpAndSettle();

          // Open timetable
          await tester.tap(find.byIcon(Icons.calendar_today_outlined));
          await tester.pumpAndSettle();

          // Open classes
          await tester.tap(find.byIcon(FeatherIcons.bookOpen));
          await tester.pumpAndSettle();

          // Open class view
          await tester.tap(find.text('PC'));
          await tester.pumpAndSettle();

          expect(find.byType(ClassView), findsOneWidget);

          // Open add shortcut view
          await tester.tap(find.byIcon(Icons.add_outlined));
          await tester.pumpAndSettle();

          expect(find.byType(ShortcutView), findsOneWidget);

          await tester.tap(find.byIcon(Icons.arrow_back));
          await tester.pumpAndSettle();

          expect(find.byType(ClassView), findsOneWidget);

          // Open grading view
          await tester.tap(find.byIcon(Icons.edit_outlined));
          await tester.pumpAndSettle();

          expect(find.byType(GradingView), findsOneWidget);

          await tester.tap(find.text('Save'));
          await tester.pumpAndSettle();

          expect(find.byType(ClassView), findsOneWidget);
        });
      }
    });
  });

  group('Settings', () {
    setUp(() {
      when(mockAuthProvider.currentUser).thenAnswer((_) => Future.value(User(
          uid: '0',
          firstName: 'John',
          lastName: 'Doe',
          sources: ['official'])));
      when(mockAuthProvider.currentUserFromCache).thenReturn(User(
          uid: '0', firstName: 'John', lastName: 'Doe', sources: ['official']));
    });

    for (final size in screenSizes) {
      testWidgets('${size.width}x${size.height}', (WidgetTester tester) async {
        await binding.setSurfaceSize(size);

        await tester.pumpWidget(buildApp());
        await tester.pumpAndSettle();

        // Open settings
        await tester.tap(find.byIcon(Icons.settings_outlined));
        await tester.pumpAndSettle();

        expect(find.byType(SettingsPage), findsOneWidget);
      });
    }
  });

  group('Portal', () {
    setUp(() {
      when(mockAuthProvider.currentUser).thenAnswer((_) => Future.value(User(
          uid: '0',
          firstName: 'John',
          lastName: 'Doe',
          sources: ['official'])));
      when(mockAuthProvider.currentUserFromCache).thenReturn(User(
          uid: '0', firstName: 'John', lastName: 'Doe', sources: ['official']));
    });

    for (final size in screenSizes) {
      testWidgets('${size.width}x${size.height}', (WidgetTester tester) async {
        await binding.setSurfaceSize(size);

        await tester.pumpWidget(buildApp());
        await tester.pumpAndSettle();

        // Open portal
        await tester.tap(find.byIcon(FeatherIcons.globe));
        await tester.pumpAndSettle();

        expect(find.byType(PortalPage), findsOneWidget);
      });
    }
  });

  group('Filter', () {
    setUp(() {
      when(mockAuthProvider.currentUser).thenAnswer((_) => Future.value(User(
          uid: '0',
          firstName: 'John',
          lastName: 'Doe',
          sources: ['official'])));
      when(mockAuthProvider.currentUserFromCache).thenReturn(User(
          uid: '0', firstName: 'John', lastName: 'Doe', sources: ['official']));
    });

    for (final size in screenSizes) {
      testWidgets('${size.width}x${size.height}', (WidgetTester tester) async {
        await binding.setSurfaceSize(size);

        await tester.pumpWidget(buildApp());
        await tester.pumpAndSettle();

        // Open filter popup menu
        await tester.tap(find.byIcon(FeatherIcons.globe));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(FeatherIcons.filter));
        await tester.pumpAndSettle();

        // Open filter on portal page
        await tester.tap(find.text('Filter by relevance'));
        await tester.pumpAndSettle();

        expect(find.byType(FilterPage), findsOneWidget);
      });
    }
  });

  group('Add website', () {
    setUp(() {
      when(mockAuthProvider.currentUser).thenAnswer((_) => Future.value(User(
          uid: '0',
          firstName: 'John',
          lastName: 'Doe',
          sources: ['official'])));
      when(mockAuthProvider.currentUserFromCache).thenReturn(User(
          uid: '0', firstName: 'John', lastName: 'Doe', sources: ['official']));
      when(mockAuthProvider.isAuthenticated).thenReturn(true);
      when(mockAuthProvider.isAnonymous).thenReturn(false);
    });

    for (final size in screenSizes) {
      testWidgets('${size.width}x${size.height}', (WidgetTester tester) async {
        await binding.setSurfaceSize(size);

        await tester.pumpWidget(buildApp());
        await tester.pumpAndSettle();

        // Open portal page
        await tester.tap(find.byIcon(FeatherIcons.globe));
        await tester.pumpAndSettle();

        // Open add website page
        final addWebsiteButton =
            find.byKey(const ValueKey('add_website_associations'));
        await tester.ensureVisible(addWebsiteButton);
        await tester.pumpAndSettle();

        await tester.tap(addWebsiteButton);
        await tester.pumpAndSettle();

        expect(find.byType(WebsiteView), findsOneWidget);
      });
    }
  });

  group('Edit website', () {
    setUp(() {
      when(mockAuthProvider.isAuthenticated).thenReturn(true);
      when(mockAuthProvider.isAnonymous).thenReturn(false);
      when(mockAuthProvider.currentUser).thenAnswer((_) => Future.value(User(
          uid: '1',
          firstName: 'John',
          lastName: 'Doe',
          permissionLevel: 3,
          sources: ['official'])));
      when(mockAuthProvider.currentUserFromCache).thenAnswer((_) => User(
          uid: '1',
          firstName: 'John',
          lastName: 'Doe',
          permissionLevel: 3,
          sources: ['official']));
    });

    for (final size in screenSizes) {
      testWidgets('${size.width}x${size.height}', (WidgetTester tester) async {
        await binding.setSurfaceSize(size);

        await tester.pumpWidget(buildApp());
        await tester.pumpAndSettle();

        // Open portal page
        await tester.tap(find.byIcon(FeatherIcons.globe));
        await tester.pumpAndSettle();

        // Enable editing
        await tester.tap(find.byIcon(Icons.edit_outlined));
        await tester.pumpAndSettle();

        // Open edit website page
        await tester.ensureVisible(find.text('LSAC1'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('LSAC1'));
        await tester.pumpAndSettle();

        expect(find.byType(WebsiteView), findsOneWidget);
      });
    }
  });

  group('Delete website', () {
    setUp(() {
      when(mockAuthProvider.isAuthenticated).thenReturn(true);
      when(mockAuthProvider.isAnonymous).thenReturn(false);
      when(mockAuthProvider.currentUser).thenAnswer((_) => Future.value(User(
          uid: '1',
          firstName: 'John',
          lastName: 'Doe',
          permissionLevel: 3,
          sources: ['official'])));
      when(mockAuthProvider.currentUserFromCache).thenAnswer((_) => User(
          uid: '1',
          firstName: 'John',
          lastName: 'Doe',
          permissionLevel: 3,
          sources: ['official']));
    });

    for (final size in screenSizes) {
      testWidgets('${size.width}x${size.height}', (WidgetTester tester) async {
        await binding.setSurfaceSize(size);

        await tester.pumpWidget(buildApp());
        await tester.pumpAndSettle();

        // Open portal page
        await tester.tap(find.byIcon(FeatherIcons.globe));
        await tester.pumpAndSettle();

        // Enable editing
        await tester.tap(find.byIcon(Icons.edit_outlined));
        await tester.pumpAndSettle();

        // Open edit website page
        await tester.ensureVisible(find.text('LSAC1'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('LSAC1'));
        await tester.pumpAndSettle();

        // Open delete dialog
        await tester.tap(find.byIcon(Icons.more_vert_outlined));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Delete website'));
        await tester.pumpAndSettle();

        // Cancel
        expect(find.text('Are you sure you want to delete this website?'),
            findsOneWidget);
        await tester.tap(find.text('CANCEL'));
        await tester.pumpAndSettle();

        // Open delete dialog
        await tester.tap(find.byIcon(Icons.more_vert_outlined));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Delete website'));
        await tester.pumpAndSettle();

        // Confirm deletion
        expect(find.text('Are you sure you want to delete this website?'),
            findsOneWidget);
        await tester.tap(find.text('DELETE WEBSITE'));
        await tester.pumpAndSettle(const Duration(seconds: 5));

        verify(mockWebsiteProvider.deleteWebsite(any,
            context: anyNamed('context')));
        expect(find.byType(PortalPage), findsOneWidget);
      });
    }
  });
  group('Edit Profile', () {
    setUp(() {
      when(mockAuthProvider.isVerified).thenAnswer((_) => Future.value(false));
      when(mockAuthProvider.isAuthenticated).thenReturn(true);
      when(mockAuthProvider.isAnonymous).thenReturn(false);
      when(mockAuthProvider.currentUser).thenAnswer((_) => Future.value(User(
          uid: '1',
          firstName: 'John',
          lastName: 'Doe',
          permissionLevel: 3,
          sources: ['official'])));
      when(mockAuthProvider.currentUserFromCache).thenReturn(User(
          uid: '1',
          firstName: 'John',
          lastName: 'Doe',
          permissionLevel: 3,
          sources: ['official']));
      when(mockAuthProvider.email).thenReturn('john.doe@stud.acs.upb.ro');
      when(mockAuthProvider.getProfilePictureURL(context: anyNamed('context')))
          .thenAnswer((_) => Future.value(null));
    });

    for (final size in screenSizes) {
      testWidgets('${size.width}x${size.height}', (WidgetTester tester) async {
        await binding.setSurfaceSize(size);

        await tester.pumpWidget(buildApp());
        await tester.pumpAndSettle();

        // Open Edit Profile page
        await tester.tap(find.byIcon(Icons.edit_outlined));
        await tester.pumpAndSettle();

        expect(find.byType(EditProfilePage), findsOneWidget);
      });

      testWidgets('${size.width}x${size.height}, delete account',
          (WidgetTester tester) async {
        await binding.setSurfaceSize(size);

        await tester.pumpWidget(buildApp());
        await tester.pumpAndSettle();

        // Open Edit Profile page
        await tester.tap(find.byIcon(Icons.edit_outlined));
        await tester.pumpAndSettle();

        //Open delete account popup
        await tester.tap(find.byIcon(Icons.more_vert_outlined));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Delete account'));
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey('delete_account_button')),
            findsOneWidget);
      });

      testWidgets('${size.width}x${size.height}, change password',
          (WidgetTester tester) async {
        await binding.setSurfaceSize(size);

        await tester.pumpWidget(buildApp());
        await tester.pumpAndSettle();

        // Open Edit Profile page
        await tester.tap(find.byIcon(Icons.edit_outlined));
        await tester.pumpAndSettle();

        //Open change password popup
        await tester.tap(find.byIcon(Icons.more_vert_outlined));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Change password'));
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey('change_password_button')),
            findsOneWidget);
      });

      testWidgets('${size.width}x${size.height}, change email',
          (WidgetTester tester) async {
        await binding.setSurfaceSize(size);

        await tester.pumpWidget(buildApp());
        await tester.pumpAndSettle();

        // Open Edit Profile page
        await tester.tap(find.byIcon(Icons.edit_outlined));
        await tester.pumpAndSettle();

        // Edit the email
        await tester.enterText(
            find.text('john.doe'), 'johndoe@stud.acs.upb.ro');

        //Open change email popup
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        expect(
            find.byKey(const ValueKey('change_email_button')), findsOneWidget);
      });
    }
  });

  group('People page', () {
    setUp(() {
      when(mockAuthProvider.isAuthenticated).thenReturn(true);
      when(mockAuthProvider.isAnonymous).thenReturn(true);
    });

    for (final size in screenSizes) {
      testWidgets('${size.width}x${size.height}', (WidgetTester tester) async {
        await binding.setSurfaceSize(size);

        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(buildApp());
          await tester.pumpAndSettle();

          // Open people page
          await tester.tap(find.byIcon(Icons.people_outlined));
          await tester.pumpAndSettle();

          expect(find.byType(PeoplePage), findsOneWidget);

          // Open bottom sheet with person info
          final names = ['John Doe', 'Jane Doe', 'Mary Poppins'];
          for (final name in names) {
            await tester.tap(find.text(name));
            await tester.pumpAndSettle();
          }

          expect(find.byType(PersonView), findsOneWidget);
        });
      });
    }
  });

  group('Show faq page', () {
    for (final size in screenSizes) {
      testWidgets('${size.width}x${size.height}', (WidgetTester tester) async {
        await binding.setSurfaceSize(size);

        await tester.pumpWidget(buildApp());
        await tester.pumpAndSettle();

        final showMoreFaq =
            find.byKey(const ValueKey('show_more_faq'), skipOffstage: false);

        // Ensure FAQ card is visible
        await tester.ensureVisible(showMoreFaq);
        await tester.pumpAndSettle();

        // Open faq page
        await tester.tap(showMoreFaq);
        await tester.pumpAndSettle();

        expect(find.byType(FaqPage), findsOneWidget);

        await tester.tap(find.byIcon(Icons.search_outlined));
        await tester.pumpAndSettle();

        expect(find.byType(SearchBar), findsOneWidget);

        final cancelSearchBar = find.byKey(const ValueKey('cancel_search_bar'));

        await tester.tap(cancelSearchBar);
        await tester.pumpAndSettle();

        expect(find.byType(SearchBar), findsNothing);
      });
    }
  });

  group('Show news feed page', () {
    for (final size in screenSizes) {
      testWidgets('${size.width}x${size.height}', (WidgetTester tester) async {
        await binding.setSurfaceSize(size);

        await tester.pumpWidget(buildApp());
        await tester.pumpAndSettle();

        // Open news feed page
        final showMoreNewsFeed =
            find.byKey(const ValueKey('show_more_news_feed'));

        await tester.tap(showMoreNewsFeed);
        await tester.pumpAndSettle();

        expect(find.byType(NewsFeedPage), findsOneWidget);
      });
    }
  });
}
