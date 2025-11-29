import 'dart:convert';
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

Map<String, dynamic> extractError(Object e) {
  if (e is Map<String, dynamic>) return e;

  try {
    final decoded = jsonDecode(e.toString());
    if (decoded is Map<String, dynamic>) return decoded;
  } catch (_) {}

  return {"status": null, "message": e.toString(), "errorCode": null};
}
