import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:country_picker/country_picker.dart';
import '../../services/services.dart';
import '../../utils/utils.dart';
import 'otp_verification_screen.dart';

class LoginPhoneScreen extends StatefulWidget {
  const LoginPhoneScreen({super.key});

  @override
  State<LoginPhoneScreen> createState() => _LoginPhoneScreenState();
}

class _LoginPhoneScreenState extends State<LoginPhoneScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocus = FocusNode();
  bool _isLoading = false;
  Country _selectedCountry = Country.parse('IN'); // Default to India

  @override
  void initState() {
    super.initState();
    // Autofocus when opening this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _phoneFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  String get _fullPhoneNumber {
    return '+${_selectedCountry.phoneCode}${_phoneController.text.trim()}';
  }

  bool get _isValidPhoneNumber {
    final phoneNumber = _phoneController.text.trim();
    return phoneNumber.isNotEmpty && phoneNumber.length >= 10;
  }

  Future<void> _sendOTP() async {
    if (!_isValidPhoneNumber) {
      Helpers.showSnackBar(
        context,
        'Please enter a valid phone number',
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      await authService.sendOTP(
        phoneNumber: _fullPhoneNumber,
        onCodeSent: (verificationId) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTPVerificationScreen(
                verificationId: verificationId,
                phoneNumber: _fullPhoneNumber,
              ),
            ),
          );
        },
        onVerificationFailed: (error) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          Helpers.showSnackBar(context, error, isError: true);
        },
        onVerificationCompleted: (userCredential) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          // Auto-verification completed; AuthWrapper will handle next navigation.
          Navigator.of(context).pop(); // go back to wrapper if you came here via Landing
        },
        onCodeAutoRetrievalTimeout: (verificationId) {
          // Optional: handle timeout UI
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      Helpers.showSnackBar(
        context,
        'Failed to send OTP: ${e.toString()}',
        isError: true,
      );
    }
  }

  void _selectCountry() {
    showCountryPicker(
      context: context,
      countryListTheme: CountryListThemeData(
        flagSize: 25,
        backgroundColor: Colors.white,
        textStyle: TextStyle(fontSize: 16, color: AppConstants.textPrimary),
        bottomSheetHeight: 500,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        inputDecoration: InputDecoration(
          labelText: 'Search',
          hintText: 'Start typing to search',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: AppConstants.primaryColor),
          ),
        ),
      ),
      onSelect: (Country country) {
        setState(() {
          _selectedCountry = country;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold will resize when keyboard appears
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppConstants.textPrimary,
        title: Text(
          'Sign in',
          style: TextStyle(
            color: AppConstants.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;
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
                      const SizedBox(height: 8),
                      Text(
                        'Enter your phone number',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "We'll send you a verification code",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppConstants.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          GestureDetector(
                            onTap: _selectCountry,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _selectedCountry.flagEmoji,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '+${_selectedCountry.phoneCode}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: AppConstants.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: AppConstants.textSecondary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              focusNode: _phoneFocus,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                hintText: 'Phone number',
                                hintStyle: TextStyle(
                                  color: AppConstants.textSecondary,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: AppConstants.primaryColor),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                              onChanged: (value) => setState(() {}),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _sendOTP,
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
                            'Send OTP',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
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
