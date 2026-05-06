import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_appointment/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartAppointmentApp());
    expect(find.text('Smart Appointment\nQueue Management'), findsOneWidget);
  });
}
