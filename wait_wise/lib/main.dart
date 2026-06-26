import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wait_wise/app_router.dart';
import 'package:wait_wise/services/dioClient.dart';

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
    return MaterialApp.router(
      title: 'Flutter Demo',
      routerConfig: appRouter,
    );
  }
}
