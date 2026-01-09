import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:worklinker/core/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String _formatPhoneNumber(String phone) {
    // Remove all non-digit characters
    String digits = phone.replaceAll(RegExp(r'[^\d]'), '');

    // If starts with 91 and has 12 digits, it's already formatted
    if (digits.startsWith('91') && digits.length == 12) {
      return '+$digits';
    }

    // If starts with 0, remove it
    if (digits.startsWith('0')) {
      digits = digits.substring(1);
    }

    // If 10 digits, add +91 prefix
    if (digits.length == 10) {
      return '+91$digits';
    }

    // If already has country code (12 digits starting with 91)
    if (digits.length == 12 && digits.startsWith('91')) {
      return '+$digits';
    }

    // Return as is if already formatted with +
    if (phone.startsWith('+')) {
      return phone;
    }

    // Default: assume 10 digit Indian number
    if (digits.length == 10) {
      return '+91$digits';
    }

    return phone;
  }

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = context.read<AuthService>();
      String phoneInput = _phoneController.text.trim();

      // Auto-format phone number with +91 prefix
      final phoneNumber = _formatPhoneNumber(phoneInput);

      // Update the controller to show formatted number
      if (phoneNumber != phoneInput) {
        _phoneController.text = phoneNumber;
      }

      final verificationId = await authService.sendOTP(phoneNumber);

      if (mounted) {
        context.go(
            '/otp-verify?phone=$phoneNumber&verificationId=$verificationId');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.work_outline,
                    size: 80,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'WorkLinker',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Controlled Collaboration Platform',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      hintText: 'Enter 10 digit number (e.g., 8209556233)',
                      prefixIcon: const Icon(Icons.phone),
                      prefixText: '+91 ',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      String digits = value.replaceAll(RegExp(r'[^\d]'), '');
                      if (digits.length < 10) {
                        return 'Please enter a valid 10 digit phone number';
                      }
                      if (digits.length > 12) {
                        return 'Phone number is too long';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _sendOTP,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Send OTP'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
