import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pinput/pinput.dart';
import 'dart:async';
import '../../services/services.dart';
import '../../utils/utils.dart';
import 'auth_wrapper.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OTPVerificationScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();
  bool _isLoading = false;
  bool _isResending = false;
  int _resendCountdown = 60;
  Timer? _timer;
  String? _currentVerificationId;

  @override
  void initState() {
    super.initState();
    _currentVerificationId = widget.verificationId;
    _startCountdownTimer();
    // Auto-focus the OTP field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _otpFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocusNode.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdownTimer() {
    _resendCountdown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  Future<void> _verifyOTP() async {
    final otp = _otpController.text.trim();

    if (otp.length != 6) {
      Helpers.showSnackBar(
        context,
        'Please enter the complete 6-digit OTP',
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      await authService.verifyOTP(
        verificationId: _currentVerificationId!,
        otp: otp,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      // Critical change: replace stack to AuthWrapper instead of pop()
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthWrapper()),
            (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      _otpController.clear();
      String errorMessage = e.toString();
      if (errorMessage.contains('Exception:')) {
        errorMessage = errorMessage.replaceFirst('Exception: ', '');
      }

      Helpers.showSnackBar(context, errorMessage, isError: true);
    }
  }


  Future<void> _resendOTP() async {
    setState(() {
      _isResending = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      await authService.resendOTP(
        phoneNumber: widget.phoneNumber,
        onCodeSent: (verificationId) {
          if (!mounted) return;
          setState(() {
            _isResending = false;
            _currentVerificationId = verificationId;
          });
          _startCountdownTimer();
          _otpController.clear();
          Helpers.showSnackBar(context, 'OTP resent successfully!');
        },
        onVerificationFailed: (error) {
          if (!mounted) return;
          setState(() => _isResending = false);
          Helpers.showSnackBar(context, error, isError: true);
        },
        onVerificationCompleted: (userCredential) {
          if (!mounted) return;
          setState(() => _isResending = false);
          // Auto-verification completed
          Helpers.showSnackBar(context, 'Phone number verified successfully!');
        },
        onCodeAutoRetrievalTimeout: (verificationId) {
          _currentVerificationId = verificationId;
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isResending = false);
      Helpers.showSnackBar(
        context,
        'Failed to resend OTP: ${e.toString()}',
        isError: true,
      );
    }
  }

  String get _maskedPhoneNumber {
    final phoneNumber = widget.phoneNumber;
    if (phoneNumber.length > 6) {
      return phoneNumber.substring(0, phoneNumber.length - 6) +
          '••••••' +
          phoneNumber.substring(phoneNumber.length - 2);
    }
    return phoneNumber;
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
        fontSize: 20,
        color: AppConstants.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppConstants.primaryColor, width: 2),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: AppConstants.primaryColor.withOpacity(0.1),
        border: Border.all(color: AppConstants.primaryColor),
      ),
    );

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppConstants.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Verify Phone',
          style: TextStyle(
            color: AppConstants.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: AppConstants.screenPadding.copyWith(
                bottom: AppConstants.screenPadding.bottom + bottomInset,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - bottomInset,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      Text(
                        'Enter verification code',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "We've sent a 6-digit code to",
                        style: TextStyle(
                          fontSize: 16,
                          color: AppConstants.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _maskedPhoneNumber,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppConstants.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 32),

                      Center(
                        child: Pinput(
                          controller: _otpController,
                          focusNode: _otpFocusNode,
                          length: 6,
                          defaultPinTheme: defaultPinTheme,
                          focusedPinTheme: focusedPinTheme,
                          submittedPinTheme: submittedPinTheme,
                          pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                          showCursor: true,
                          onCompleted: (pin) => _verifyOTP(),
                          onChanged: (value) => setState(() {}),
                        ),
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading || _otpController.text.length != 6
                              ? null
                              : _verifyOTP,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                            ),
                            elevation: 2,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                              : const Text(
                            'Verify OTP',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Didn't receive the code? ",
                            style: TextStyle(
                              fontSize: 14,
                              color: AppConstants.textSecondary,
                            ),
                          ),
                          if (_resendCountdown > 0)
                            Text(
                              'Resend in ${_resendCountdown}s',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppConstants.textSecondary,
                              ),
                            )
                          else
                            GestureDetector(
                              onTap: _isResending ? null : _resendOTP,
                              child: Text(
                                _isResending ? 'Sending...' : 'Resend OTP',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _isResending
                                      ? AppConstants.textSecondary
                                      : AppConstants.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const Spacer(),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppConstants.textSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Make sure to check your SMS messages. The code may take up to 2 minutes to arrive.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppConstants.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
