import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landing/landing_page.dart'; // La tua pagina principale
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Creato da 'flutterfire configure'

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inizializza Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Definisco il colore primario del tuo brand
    const Color primaryColor = Color(0xFFFBC02D);
    // Definisco il colore di sfondo scuro
    const Color backgroundColor = Color(0xFF121212);

    return MaterialApp(
      title: 'Fooodly',
      debugShowCheckedModeBanner: false,

      // --- QUESTO È IL TEMA PROFESSIONALE ---
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: primaryColor,
        scaffoldBackgroundColor: backgroundColor,

        // Definisco i Font per l'intera app
        textTheme: GoogleFonts.latoTextTheme( // Font di base
          Theme.of(context).textTheme.apply(
            bodyColor: Colors.grey[300],
            displayColor: Colors.white,
          ),
        ),

        // Stile per i bottoni
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.black,
            textStyle: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),

        // Stile per i TextField
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: GoogleFonts.lato(color: Colors.grey[600]),
          filled: true,
          fillColor: const Color(0xFF181818),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: primaryColor,
              width: 2,
            ),
          ),
        ),
      ),
      home: const LandingPage(),
    );
  }
}