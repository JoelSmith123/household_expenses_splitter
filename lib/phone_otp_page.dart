import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class PhoneOtpPage extends StatefulWidget {
  const PhoneOtpPage({super.key});

  @override
  State<PhoneOtpPage> createState() => _PhoneOtpPageState();
}

class _PhoneOtpPageState extends State<PhoneOtpPage> {
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  late final FocusNode _otpFocus;
  bool _codeSent = false;

  @override
  void initState() {
    super.initState();
    _otpFocus = FocusNode()
      ..addListener(() {
        if (!_otpFocus.hasFocus) {
          FocusManager.instance.primaryFocus?.unfocus(); // dismiss keyboard
        }
      });
  }

  @override
  void dispose() {
    _otpFocus.dispose();
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    await supabase.auth.signInWithOtp(
      phone: _phoneCtrl.text.trim(),
    ); // sends SMS OTP
    setState(() => _codeSent = true);
  }

  Future<void> _verifyOtp() async {
    final res = await supabase.auth.verifyOTP(
      phone: _phoneCtrl.text.trim(),
      token: _otpCtrl.text.trim(),
      type: OtpType.sms,
    ); // creates session if code is valid

    // TODO: navigate to your main screen
    print('User: ${res.user?.id}');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _phoneCtrl,
          keyboardType: TextInputType.number,
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
          decoration: const InputDecoration(
            labelText: 'sign in with phone number',
            labelStyle: const TextStyle(color: Color(0xFF196719)),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: const BorderSide(color: Color(0xFF196719), width: 5),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFF196719), width: 2),
            ),
          ),
        ),
        if (_codeSent)
          TextField(
            controller: _otpCtrl,
            keyboardType: TextInputType.number,
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            decoration: const InputDecoration(
              labelText: 'OTP code',
              labelStyle: const TextStyle(color: Color(0xFF228b22)),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF228b22)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Colors.cyanAccent, width: 2),
              ),
            ),
          ),
        const SizedBox(height: 16),
        CupertinoButton(
          onPressed: _codeSent ? _verifyOtp : _sendOtp,
          child: const Text('Verify code',
              style: TextStyle(color: CupertinoColors.white)),
          color: const Color(0xFF228b22),
        ),
      ],
    );
  }
}
