import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildingCard({required String title, required List<Widget> children}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300, width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withValues(alpha: 0.12),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 250, 235, 148),
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 17,
              color: Colors.black87,
            ),
          ),
        ),

        // Body
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(children: children),
        ),
      ],
    ),
  );
}

Widget buildFieldRow(List<Widget> children, {List<int>? flexes}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        for (int i = 0; i < children.length; i++) ...[
          Expanded(flex: flexes != null && i < flexes.length ? flexes[i] : 1, child: children[i]),
          if (i != children.length - 1) const SizedBox(width: 18),
        ],
      ],
    ),
  );
}
