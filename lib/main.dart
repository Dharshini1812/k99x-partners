import 'package:dealer/core/route/router.gr.dart';
import 'package:dealer/core/services/hive_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screen_protector/screen_protector.dart';

final _appRouter = AppRouter();

void main() async {
  await HiveService.init();
  runApp(const ProviderScope(child: MyApp()));
  // 1. Prevent screenshots and screen recording
  await ScreenProtector.preventScreenshotOn();

  // 2. Hide app preview in recent/multitasking view (iOS & Android)
  await ScreenProtector.protectDataLeakageOn();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: _appRouter.delegate(),
      routeInformationParser: _appRouter.defaultRouteParser(),
      debugShowCheckedModeBanner: false,
      title: 'K99x Partners',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}
