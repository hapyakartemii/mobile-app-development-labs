import 'package:flutter/material.dart';
import 'package:flutter_lab1/app/app.dart';
import 'package:flutter_lab1/app/di.dart';

/// Entry point: fills the DI container once, then starts the app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const MeteoApp());
}
