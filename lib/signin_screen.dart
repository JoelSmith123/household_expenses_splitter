import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

import 'phone_otp_page.dart';

Widget signinScreen() {
  return Consumer<AppState>(
    builder: (context, appState, child) {
      return Material(
        color: Colors.transparent, // so it respects the Cupertino bg color
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Welcome to Tally!',
              style: GoogleFonts.modak(
                fontSize: 40,
                color: const Color(0xFF228b22),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 44),
            PhoneOtpPage(),
          ],
        ),
      );
    },
  );
}
