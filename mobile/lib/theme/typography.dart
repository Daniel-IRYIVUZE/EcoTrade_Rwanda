import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static TextStyle headline1 = GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold);
  static TextStyle headline2 = GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold);
  static TextStyle headline3 = GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600);
  static TextStyle body1 = GoogleFonts.inter(fontSize: 16);
  static TextStyle body2 = GoogleFonts.inter(fontSize: 14);
  static TextStyle caption = GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6B7280));
  static TextStyle button = GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.5);
  static TextStyle label = GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500);
}
