import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_application_4/main.dart' as app;
void main(){
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('verify login screen works', (WidgetTester tester) async{
    app.main();
    await tester.pumpAndSettle();
    // ---- Step 1: Launch ----
      expect(find.text('Login'), findsOneWidget);
      final emailField = find.byKey(const Key('emailField'));
      final passwordField = find.byKey(const Key('passwordField'));
      final loginButton = find.byKey(const Key('loginButton'));

      await tester.enterText(emailField, 'manish@gmail.com');
      await tester.enterText(passwordField, 'manish@1234');
      await tester.tap(loginButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));
  });
}
