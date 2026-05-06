import 'package:flutter/material.dart';
import 'utils/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartAppointmentApp());
}

class SmartAppointmentApp extends StatelessWidget {
  const SmartAppointmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Appointment',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const Scaffold(
        body: Center(
          child: Text(
            'Smart Appointment\nQueue Management',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
