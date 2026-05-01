import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../global_state.dart';
import 'home_screen.dart';
import 'document_hub_screen.dart';

class UnderVerificationScreen extends StatefulWidget {
  const UnderVerificationScreen({super.key});

  @override
  State<UnderVerificationScreen> createState() => _UnderVerificationScreenState();
}

class _UnderVerificationScreenState extends State<UnderVerificationScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
  }

  Future<void> _fetchStatus() async {
    setState(() => _isLoading = true);
    await ApiService.getDriverStatus(GlobalState.mobile);
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final status = GlobalState.status;
    final isRejected = status == 'Rejected' || status == 'Blocked' || status == 'Inactive';
    final isPending = status == 'Pending';
    final isVerified = status == 'verified' || status == 'Active';
    final isUnderReview = status == 'Under Review';

    if (isVerified) {
      // Future.microtask(() => Navigator.pushReplacement(...));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _fetchStatus,
            icon: const Icon(Icons.refresh, color: Color(0xFF1A73E8)),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              _buildStatusIcon(status),
              const SizedBox(height: 40),
              Text(
                status == 'Under Review' ? 'Under Verification' : status,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _getStatusMessage(status),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              if (GlobalState.statusReason.isNotEmpty) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getStatusColor(status).withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'REASON:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        GlobalState.statusReason,
                        style: const TextStyle(fontSize: 15, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              if (isVerified) _buildContinueButton(context),
              if (isPending || isRejected) _buildReSubmitButton(context),
              if (isRejected) _buildSupportSection(context),
              if (isUnderReview) _buildSupportSection(context),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(String status) {
    IconData icon;
    Color color = _getStatusColor(status);

    switch (status) {
      case 'Rejected':
      case 'Blocked':
        icon = Icons.error_outline;
        break;
      case 'Pending':
        icon = Icons.hourglass_top_outlined;
        break;
      case 'verified':
      case 'Active':
        icon = Icons.verified;
        break;
      default:
        icon = Icons.verified_user_outlined;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 100,
        color: color,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Rejected':
      case 'Blocked':
      case 'Inactive':
        return Colors.red;
      case 'Pending':
        return Colors.orange;
      case 'verified':
      case 'Active':
        return Colors.green;
      default:
        return const Color(0xFF1A73E8);
    }
  }

  String _getStatusMessage(String status) {
    switch (status) {
      case 'Blocked':
        return 'Your ID has been Blocked. Contact Txigo Partner Support for more information.';
      case 'Rejected':
      case 'Inactive':
        return 'Your application has been rejected. Please review the reason below and update your profile.';
      case 'Pending':
        return 'Action required. Please review the reason below and re-submit your details.';
      case 'verified':
      case 'Active':
        return GlobalState.hasAllDocuments 
          ? 'Your account is verified! You can now start using Txigo.' 
          : 'Your account is verified, but some documents are still missing. Please complete your profile to continue.';
      default:
        return 'Your documents are under review. Our team will verify your profile within 24-48 hours.';
    }
  }

  Widget _buildReSubmitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DocumentHubScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: const Text(
          'Re-submit Documents',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: () => _onContinuePressed(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A73E8),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        child: Text(
          GlobalState.hasAllDocuments ? 'Continue' : 'Complete Profile',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _onContinuePressed(BuildContext context) {
    if ((GlobalState.status == 'verified' || GlobalState.status == 'Active') && GlobalState.hasAllDocuments) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else if (!GlobalState.hasAllDocuments) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DocumentHubScreen()),
      );
    } else {
      // Status is everything else (Pending, Under Review, etc. - documents are complete)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your account is under review. Please wait for admin approval.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Widget _buildSupportSection(BuildContext context) {
    final method = GlobalState.supportMethod;
    final value = GlobalState.supportValue;
    Color buttonColor = method == 'WhatsApp' ? const Color(0xFF25D366) : const Color(0xFF1A73E8);
    IconData icon = method == 'WhatsApp' ? Icons.chat_bubble_outline : Icons.phone_callback_outlined;

    return Column(
      children: [
        Text(
          'Need Help? Contact Txigo Partner Support at ${value.isNotEmpty ? value : "+91 98765 43210"}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton.icon(
            onPressed: () {
              // Simulated support action
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Contacting support via $method: $value')),
              );
            },
            icon: Icon(icon),
            label: Text(
              method == 'WhatsApp' ? 'Chat on WhatsApp' : 'Call Support',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }
}
