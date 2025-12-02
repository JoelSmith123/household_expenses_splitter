import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

Widget logoScreen() {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        'Tally',
        style: GoogleFonts.modak(
          fontSize: 50,
          color: const Color(0xFF228b22),
        ),
      ),
    //   const SizedBox(height: 10),
      SizedBox(
        width: 160,
        height: 160,
        child: Image.asset('assets/images/squirrel.png'),
      ),
    ],
  );
}
