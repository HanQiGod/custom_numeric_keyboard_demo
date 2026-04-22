import 'package:custom_numeric_keyboard_demo/src/pages/number_keyboard_page.dart';
import 'package:flutter/material.dart';

class CustomNumericKeyboardDemoApp extends StatelessWidget {
  const CustomNumericKeyboardDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFFE07A4F);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Custom Numeric Keyboard Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          primary: const Color(0xFF18202F),
          surface: const Color(0xFFFFFAF3),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5EFE6),
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: const Color(0xFF18202F),
          displayColor: const Color(0xFF18202F),
        ),
      ),
      home: const NumberKeyboardPage(),
    );
  }
}
