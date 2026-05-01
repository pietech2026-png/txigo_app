import 'package:flutter/material.dart';
import 'dart:async';
import '../services/api_service.dart';
import '../global_state.dart';
import 'vehicle_selection_screen.dart';
import 'home_screen.dart';
import 'under_verification_screen.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final List<TextEditingController> _controllers =
      List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());
  
   Timer? _timer;
   int _secondsRemaining = 30; // Countdown from 30 seconds
   bool _canResend = false;
   bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _canResend = false;
    _secondsRemaining = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _canResend = true;
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Verification',
                style: TextStyle(
                  color: Color(0xFF1A73E8),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Enter the 4-digit code sent to your phone number.',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  4,
                  (index) => _buildOTPField(index),
                ),
              ),
              const SizedBox(height: 60),
              _buildVerifyButton(),
              const SizedBox(height: 30),
              Center(
                child: TextButton(
                  onPressed: _canResend ? _startTimer : null,
                  child: Text(
                    _canResend
                        ? 'Resend Code'
                        : 'Resend Code in 00:${_secondsRemaining.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: _canResend ? const Color(0xFF1A73E8) : Colors.grey,
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
  }

  Widget _buildOTPField(int index) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        maxLength: 1,
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 3) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : () async {
          setState(() => _isLoading = true);
          
          // Simulate OTP verification delay
          await Future.delayed(const Duration(seconds: 1));

          // Fetch driver status from backend
          bool exists = await ApiService.getDriverStatus(GlobalState.mobile);

          setState(() => _isLoading = false);

          if (!mounted) return;

          if (!exists || GlobalState.status == 'New') {
            // New registration - Capture Lead immediately
            await ApiService.captureLead(GlobalState.mobile);
            
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const VehicleSelectionScreen()),
            );
          } else if ((GlobalState.status == 'verified' || GlobalState.status == 'Active') && GlobalState.hasAllDocuments) {
            // Only fully verified/Active drivers with all docs can enter
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          } else {
            // New, Pending, Under Review, Rejected, or verified but missing docs
            // All go to UnderVerificationScreen which handles the messages
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const UnderVerificationScreen()),
              (route) => false,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A73E8),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        child: _isLoading 
          ? const SizedBox(
              height: 20, 
              width: 20, 
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
            )
          : const Text(
            'Verify & Continue',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
      ),
    );
  }
}
