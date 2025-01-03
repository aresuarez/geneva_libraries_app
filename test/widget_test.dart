import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geneva_libraries_app/models/library.dart';
import 'package:geneva_libraries_app/screens/home_screen.dart';
import 'package:geneva_libraries_app/services/library_service.dart';
import 'package:geneva_libraries_app/widgets/time_selector.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:geneva_libraries_app/utils/clock.dart';

@GenerateNiceMocks([MockSpec<LibraryService>()])
import 'widget_test.mocks.dart';

void main() {
  late MockLibraryService mockLibraryService;
  final fixedTime = DateTime(2024, 1, 1, 10, 0); // Monday, 10:00 AM

  setUp(() {
    mockLibraryService = MockLibraryService();
    Clock.now = () => fixedTime;
  });

  tearDown(() {
    Clock.now = () => DateTime.now();
  });

  Future<void> pumpHomeScreen(WidgetTester tester, {List<Library> libraries = const []}) async {
    when(mockLibraryService.loadLibrarySchedules())
        .thenAnswer((_) async => libraries);

    await tester.pumpWidget(MaterialApp(
      home: HomeScreen(
        title: 'Geneva Library Hours',
        libraryService: mockLibraryService,
      ),
    ));

    // Wait for loading state to complete
    await tester.pump(); // Build frame
    await tester.pump(Duration.zero); // Process microtasks
    await tester.pumpAndSettle(); // Wait for animations
  }

  Future<void> cleanupTest(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  }

  testWidgets('Shows library schedule correctly', (WidgetTester tester) async {
    final mockLibrary = Library(
      name: 'Test Library',
      schedule: {
        'monday': Schedule(timeSlots: [
          TimeSlot(open: '09:00', close: '12:00'),
          TimeSlot(open: '14:00', close: '17:00'),
        ]),
      },
    );

    await pumpHomeScreen(tester, libraries: [mockLibrary]);
    expect(find.text('Geneva Library Hours'), findsOneWidget);
    expect(find.text('Select Time'), findsOneWidget);
    await cleanupTest(tester);
  });

  testWidgets('Shows no libraries message', (WidgetTester tester) async {
    await pumpHomeScreen(tester);

    // First verify loading state is done
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // Then verify empty libraries state
    expect(find.text('No library data available'), findsOneWidget);
    
    await cleanupTest(tester);
  });

  testWidgets('Shows no open libraries message', (WidgetTester tester) async {
    final mockLibrary = Library(
      name: 'Test Library',
      schedule: {
        'monday': Schedule(timeSlots: [
          TimeSlot(open: '14:00', close: '17:00'), // Afternoon only
        ]),
      },
    );

    await pumpHomeScreen(tester, libraries: [mockLibrary]);

    // Change time to morning when library is closed
    final timeSelector = tester.widget<TimeSelector>(find.byType(TimeSelector));
    timeSelector.onTimeChanged(const TimeOfDay(hour: 10, minute: 0));
    await tester.pumpAndSettle();

    expect(find.text('No libraries open at this time.'), findsOneWidget);
    
    await cleanupTest(tester);
  });

  testWidgets('Shows restore button when time changes', (WidgetTester tester) async {
    await pumpHomeScreen(tester);
    expect(find.byIcon(Icons.restore), findsNothing);
    await cleanupTest(tester);
  });
}
