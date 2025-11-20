import 'package:flutter/material.dart';
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
  bool _codeSent = false;

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
          decoration: const InputDecoration(labelText: 'Phone'),
        ),
        if (_codeSent)
          TextField(
            controller: _otpCtrl,
            decoration: const InputDecoration(labelText: 'OTP code'),
          ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _codeSent ? _verifyOtp : _sendOtp,
          child: Text(_codeSent ? 'Verify code' : 'Send code'),
        ),
      ],
    );
  }
}
