import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logging/logging.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:mova_cards/screens/home_screen.dart';

import 'package:mova_cards/utils/dark_mode_controller.dart';

const bool preview = false;

void main() {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late DarkModeController darkModeController;

  @override
  void initState() {
    super.initState();
    darkModeController = DarkModeController(setState);
    darkModeController.init();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    var seedColor = Colors.red;
    return ScreenUtilInit(
        designSize: const Size(411, 890),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            title: 'Мова: Карткі',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                  seedColor: seedColor,
                  dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
                  brightness: Brightness.light),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                    seedColor: seedColor,
                    dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
                    brightness: Brightness.dark),
                useMaterial3: true),
            themeMode:
                darkModeController.darkTheme ? ThemeMode.dark : ThemeMode.light,
            home: HomeScreen(
                title: 'Мова: Карткі', darkModeController: darkModeController),
          );
        });
  }
}
