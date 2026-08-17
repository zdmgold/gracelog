import 'dart:async';
import 'package:flutter/material.dart';
import 'screens/home_dashboard.dart';

void main() {
  // Catch widget build errors (grey screen in release)
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return ErrorScreen(
      error: details.exception.toString(),
      stack: details.stack.toString(),
    );
  };

  // Watchdog: if something hangs forever before runApp, show timeout after 10s
  final timer = Timer(const Duration(seconds: 10), () {
    runApp(const ErrorApp(
      error: 'STARTUP TIMEOUT\n\nAn async operation (plugin init, database, etc.) is hanging forever and blocking the app from starting.',
      stack: '',
    ));
  });

  // Catch ALL other errors (async, exceptions, etc.)
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const GraceLogApp());
    timer.cancel(); // Success — cancel the timeout
  }, (error, stack) {
    timer.cancel();
    runApp(ErrorApp(error: error.toString(), stack: stack.toString()));
  });
}

class GraceLogApp extends StatelessWidget {
  const GraceLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GraceLog',
      debugShowCheckedModeBanner: false,
      home: const HomeDashboard(),
    );
  }
}

class ErrorApp extends StatelessWidget {
  final String error;
  final String stack;
  const ErrorApp({super.key, required this.error, required this.stack});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ErrorScreen(error: error, stack: stack),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  final String error;
  final String stack;
  const ErrorScreen({super.key, required this.error, required this.stack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'APP CRASHED',
                style: TextStyle(color: Colors.red, fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                error,
                style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
              ),
              if (stack.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text(
                  'STACK TRACE:',
                  style: TextStyle(color: Colors.orange, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  stack,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
