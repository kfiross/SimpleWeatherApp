import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemes {
  const AppThemes._();

  static ThemeData light(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    var appBarTheme = Theme.of(context).appBarTheme;

    return ThemeData.light().copyWith(
      appBarTheme: appBarTheme.copyWith(
        textTheme: GoogleFonts.varelaRoundTextTheme(
          textTheme.apply(bodyColor: Colors.white),
        ),
      ),
      textTheme: GoogleFonts.varelaRoundTextTheme(
        textTheme.apply(bodyColor: Colors.black, displayColor: Colors.black),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  static ThemeData dark(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    var appBarTheme = Theme.of(context).appBarTheme;

    return ThemeData.dark().copyWith(
      appBarTheme: appBarTheme.copyWith(
        textTheme: GoogleFonts.varelaRoundTextTheme(
          textTheme.apply(bodyColor: Colors.white),
        ),
      ),
      textTheme: GoogleFonts.varelaRoundTextTheme(
        textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
