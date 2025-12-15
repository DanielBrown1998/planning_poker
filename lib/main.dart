import 'package:flutter/material.dart';
import 'package:planning_poker/repository/partners_choices_repository.dart';
import 'package:planning_poker/view/home.dart';
import 'package:planning_poker/viewmodel/home_viewmodel.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<PartnersChoicesRepository>(
          create: (context) => PartnersChoicesRepository(),
        ),
        ChangeNotifierProvider(
          create: (context) => HomeViewModel(
            partnersChoicesRepository: context
                .read<PartnersChoicesRepository>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  final String appTitle = 'Planning Poker';
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.system,
      home: HomePage(title: appTitle),
    );
  }
}
