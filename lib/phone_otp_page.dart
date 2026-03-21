import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:household_expenses_sharing_flutter_app/styles/app_styles.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/app_state.dart';

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
  late final FocusNode _phoneFocus;
  bool _codeSent = false;

  @override
  void initState() {
    super.initState();
    _otpFocus = FocusNode();
    _phoneFocus = FocusNode();
  }

  @override
  void dispose() {
    _otpFocus.dispose();
    _phoneFocus.dispose();
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
    if (!mounted) return;
    _otpCtrl.clear();
    setState(() => _codeSent = false);
    context.read<AppState>().setSignedIn(true);
    await context.read<AppState>().handleSignedIn();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _phoneCtrl,
          focusNode: _phoneFocus,
          keyboardType: TextInputType.number,
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
          decoration: const InputDecoration(
            labelText: 'sign in with phone number',
            labelStyle: const TextStyle(color: AppColors.deepGreen),
            filled: true,
            fillColor: CupertinoColors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: const BorderSide(color: AppColors.deepGreen, width: 5),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.deepGreen, width: 2),
            ),
          ),
        ),
        if (_codeSent) ...[
          const SizedBox(height: 10),
          TextField(
            controller: _otpCtrl,
            focusNode: _otpFocus,
            keyboardType: TextInputType.number,
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            decoration: const InputDecoration(
              labelText: 'OTP code',
              labelStyle: TextStyle(color: AppColors.deepGreen),
              filled: true,
              fillColor: CupertinoColors.white,
              enabledBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: AppColors.deepGreen, width: 5),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: AppColors.deepGreen, width: 2),
              ),
            ),
          ),
        ],
        
        const SizedBox(height: 16),
        CupertinoButton(
          onPressed: _codeSent ? _verifyOtp : _sendOtp,
          child: Text(
            _codeSent ? 'Verify code' : 'Send OTP code',
            style: const TextStyle(color: CupertinoColors.white),
          ),
          color: AppColors.primaryGreen,
        ),
      ],
    );
  }
}
