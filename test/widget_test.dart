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
        title: 'Geneva Library Opening Hours',
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
    final mockLibrary = const Library(
      name: 'Test Library',
      schedule: {
        'monday':  Schedule(timeSlots: [
          TimeSlot(open: '09:00', close: '12:00'),
          TimeSlot(open: '14:00', close: '17:00'),
        ]),
      },
    );

    await pumpHomeScreen(tester, libraries: [mockLibrary]);
    expect(find.text('Geneva Library Opening Hours'), findsOneWidget);
    expect(find.text('Select Date'), findsOneWidget);
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
    final mockLibrary = const Library(
      name: 'Test Library',
      schedule: {
        'monday': Schedule(timeSlots: [
          TimeSlot(open: '14:00', close: '17:00'), // Afternoon only
        ]),
      },
    );

    await pumpHomeScreen(tester, libraries: [mockLibrary]);

    // Find and tap the time selector
    await tester.tap(find.byType(TimeSelector));
    await tester.pumpAndSettle();

    // Simulate selecting 10:00 AM from time picker
    await tester.tap(find.text('10')); // Select hour
    await tester.pumpAndSettle();
    
    // Tap the confirm button instead of tapping at offset
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(find.text('No libraries open at this time.'), findsOneWidget);
    
    await cleanupTest(tester);
  });

  testWidgets('Shows restore button and it resets time when pressed', (WidgetTester tester) async {
    final mockLibrary = const Library(
      name: 'Test Library',
      schedule: {
        'monday': Schedule(timeSlots: [
          TimeSlot(open: '09:00', close: '13:00'),
        ]),
      },
    );

    await pumpHomeScreen(tester, libraries: [mockLibrary]);
    
    // Restore button should always be visible
    expect(find.byIcon(Icons.restore), findsOneWidget);
    
    // Change time to 14:00
    await tester.tap(find.byType(TimeSelector));
    await tester.pumpAndSettle();
    await tester.tap(find.text('14')); 
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    
    // Press restore button
    await tester.tap(find.byIcon(Icons.restore));
    await tester.pumpAndSettle();
    
    // Verify library is shown (meaning we're back to 10:00 when library is open)
    final libraryTile = find.byWidgetPredicate((widget) => 
      widget is Text && 
      widget.data!.startsWith('Test Library') && 
      (widget.data!.contains('1:00 PM') || widget.data!.contains('13:00'))
    );
    expect(libraryTile, findsOneWidget);
    
    await cleanupTest(tester);
  });
}
