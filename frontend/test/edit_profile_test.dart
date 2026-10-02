import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/screens/profile/edit_profile_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    const channel =
        MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return null;
    });
  });

  group('Profile State and AuthProvider updateProfile Tests', () {
    test('updateProfile updates fields in memory and persists guest profile',
        () async {
      final auth = AuthProvider();
      await auth.skipLogin();

      await auth.updateProfile({
        'first_name': 'Aarav',
        'last_name': 'Patel',
        'age': 32,
        'gender': 'Male',
        'height_cm': 175.0,
        'weight_kg': 68.0,
        'bmi': 22.2,
        'preferred_city': 'Mumbai',
        'conditions': ['Hypertension'],
        'medications': ['Amlodipine 5mg'],
      });

      expect(auth.user?['first_name'], 'Aarav');
      expect(auth.user?['last_name'], 'Patel');
      expect(auth.user?['age'], 32);
      expect(auth.user?['height_cm'], 175.0);
      expect(auth.user?['weight_kg'], 68.0);
      expect(auth.user?['bmi'], 22.2);
      expect(auth.user?['preferred_city'], 'Mumbai');
      expect(auth.user?['conditions'], ['Hypertension']);
      expect(auth.user?['medications'], ['Amlodipine 5mg']);

      final prefs = await SharedPreferences.getInstance();
      final guestStr = prefs.getString('guest_profile');
      expect(guestStr, isNotNull);
      expect(guestStr!.contains('Aarav'), true);
      expect(guestStr.contains('Hypertension'), true);
      expect(guestStr.contains('Amlodipine 5mg'), true);
    });

    test('updateProfile preserves existing fields when partially updating',
        () async {
      final auth = AuthProvider();
      await auth.skipLogin();

      await auth.updateProfile({
        'first_name': 'Priya',
        'conditions': ['Asthma'],
      });

      expect(auth.user?['first_name'], 'Priya');
      expect(auth.user?['email'], 'guest@aarogyasathi.in');
      expect(auth.user?['conditions'], ['Asthma']);
    });
  });

  group('EditProfileScreen Widget Tests', () {
    Widget buildTestScreen(AuthProvider auth) {
      return ChangeNotifierProvider<AuthProvider>.value(
        value: auth,
        child: const MaterialApp(
          home: EditProfileScreen(),
        ),
      );
    }

    testWidgets('Renders all profile form fields and headers',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final auth = AuthProvider();
      await auth.skipLogin();

      await tester.pumpWidget(buildTestScreen(auth));
      await tester.pumpAndSettle();

      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Personal Details'), findsOneWidget);
      expect(find.text('Body Measurements & BMI'), findsOneWidget);
      expect(find.text('Chronic Health Conditions'), findsOneWidget);
      expect(find.text('Current Medications'), findsOneWidget);
      expect(find.text('Save Profile Changes'), findsOneWidget);

      // Verify suggested condition chips
      expect(find.text('Type 2 Diabetes'), findsOneWidget);
      expect(find.text('Hypertension'), findsOneWidget);
      expect(find.text('Asthma'), findsOneWidget);
    });

    testWidgets('Live Asian ICMR BMI calculation works dynamically',
        (tester) async {
      final auth = AuthProvider();
      await auth.skipLogin();

      await tester.pumpWidget(buildTestScreen(auth));
      await tester.pumpAndSettle();

      // Enter Height = 170 cm, Weight = 68 kg => BMI = 68 / (1.7^2) = 23.5 (Overweight Asian cutoff)
      final heightField = find.widgetWithText(TextFormField, 'Height (cm) *');
      final weightField = find.widgetWithText(TextFormField, 'Weight (kg) *');

      await tester.enterText(heightField, '170');
      await tester.pump();
      await tester.enterText(weightField, '68');
      await tester.pump();

      expect(find.text('23.5'), findsOneWidget);
      expect(find.text('Calculated BMI: Overweight (Asian Cutoff)'),
          findsOneWidget);

      // Now enter Height = 175 cm, Weight = 65 kg => BMI = 65 / (1.75^2) = 21.2 (Normal ICMR Target)
      await tester.enterText(heightField, '175');
      await tester.enterText(weightField, '65');
      await tester.pump();

      expect(find.text('21.2'), findsOneWidget);
      expect(
          find.text('Calculated BMI: Normal (ICMR Target)'), findsOneWidget);
    });

    testWidgets('Adding and toggling conditions and medications',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final auth = AuthProvider();
      await auth.skipLogin();

      await tester.pumpWidget(buildTestScreen(auth));
      await tester.pumpAndSettle();

      // Select 'Hypertension' chip
      final hyperChip = find.text('Hypertension');
      await tester.tap(hyperChip);
      await tester.pump();

      // Add custom condition
      final customCondField =
          find.widgetWithText(TextField, 'Add another condition...');
      await tester.enterText(customCondField, 'Osteoarthritis');
      final addCondBtn = find.byTooltip('Add Condition');
      await tester.tap(addCondBtn);
      await tester.pump();

      expect(find.text('Osteoarthritis'), findsOneWidget);

      // Add medication
      final medField = find.byWidgetPredicate(
        (w) =>
            w is TextField &&
            w.decoration?.hintText == 'e.g. Metformin 500mg, Amlodipine 5mg',
      );
      await tester.enterText(medField, 'Metformin 500mg');
      final addMedBtn = find.byTooltip('Add Medication');
      await tester.tap(addMedBtn);
      await tester.pump();

      expect(find.text('Metformin 500mg'), findsOneWidget);
    });

    testWidgets('Saving valid profile persists to AuthProvider',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final auth = AuthProvider();
      await auth.skipLogin();

      await tester.pumpWidget(buildTestScreen(auth));
      await tester.pumpAndSettle();

      // Fill in required fields
      final firstNameField =
          find.widgetWithText(TextFormField, 'First Name *');
      final ageField = find.widgetWithText(TextFormField, 'Age (Years) *');
      final heightField = find.widgetWithText(TextFormField, 'Height (cm) *');
      final weightField = find.widgetWithText(TextFormField, 'Weight (kg) *');

      await tester.enterText(firstNameField, 'Vikram');
      await tester.enterText(ageField, '45');
      await tester.enterText(heightField, '172');
      await tester.enterText(weightField, '70');
      await tester.pump();

      // Tap Save
      final saveBtn = find.text('Save Profile Changes');
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      expect(auth.user?['first_name'], 'Vikram');
      expect(auth.user?['age'], 45);
      expect(auth.user?['height_cm'], 172.0);
      expect(auth.user?['weight_kg'], 70.0);
    });
  });
}
