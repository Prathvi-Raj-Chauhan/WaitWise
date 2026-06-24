import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wait_wise/screens/home_screen.dart';
import 'package:wait_wise/screens/login.dart';
import 'package:wait_wise/services/dio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Dioclient.init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      
      home: LoginPage(),
    );
  }
}

