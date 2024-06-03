import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unpack/views/login.dart';
import 'package:unpack/web_services/shipment_service.dart';
import 'package:unpack/web_services/statistics_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ShipmentService()),
        ChangeNotifierProvider(create: (context) => StatisticsService()),
        // Add more providers as needed
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Color.fromRGBO(38, 38, 38, 1.0),
        ),
        primaryColor: Color.fromRGBO(38, 38, 38, 1.0),
        secondaryHeaderColor: Color.fromRGBO(237, 69, 69, 1.0),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(10), // Adjust the value as needed
            ),
            backgroundColor: Color.fromRGBO(38, 38, 38, 1.0),
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: Login(),
    );
  }
}
