// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'colors.dart';
import 'pages/welcome.dart';
import 'pages/signup.dart';
import 'pages/login.dart';
import 'pages/home.dart';
import 'pages/events_calendar.dart';
import 'pages/artwork_marketplace.dart';
import 'pages/galleries_and_museums.dart';
import 'pages/communities.dart';
import 'pages/artists.dart';
import 'pages/profile.dart';
import 'pages/tickets.dart';
import 'pages/orders.dart';
import 'pages/cart.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ArtVibes',
      theme: ThemeData(
        // Set the scaffold background color
        scaffoldBackgroundColor: AppColors.white,
        // Set the default font family
        fontFamily: 'Poppins',

        // Apply gray as the default color for all text styles
        textTheme: ThemeData.light().textTheme.apply(
              bodyColor:
                  AppColors.gray, // Set as the default color for body text
              displayColor: AppColors
                  .gray, // Set as the default color for display text (headlines, titles, etc.)
            ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => Welcome(),
        '/login': (context) => Login(),
        '/signup': (context) => Signup(),
        '/home': (context) => Home(),
        '/events_calendar': (context) => EventsCalendar(),
        '/artwork_marketplace': (context) => ArtworkMarketplace(),
        '/galleries_and_museums': (context) => GalleriesAndMuseums(),
        '/communities': (context) => Communities(),
        '/artists': (context) => Artists(),
        '/profile': (context) => Profile(),
        '/tickets': (context) => Tickets(),
        '/orders': (context) => Orders(),
        '/cart': (context) => Cart(),
      },
    );
  }
}
