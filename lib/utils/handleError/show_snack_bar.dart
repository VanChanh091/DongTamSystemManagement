import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showSnackBarSuccess(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: GoogleFonts.inter(color: Colors.white)),
      backgroundColor: Colors.blue.shade600,
      duration: const Duration(seconds: 2),
    ),
  );
}

void showSnackBarError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: GoogleFonts.inter(color: Colors.white)),
      backgroundColor: Colors.red.shade600,
      duration: const Duration(seconds: 2),
    ),
  );
}
