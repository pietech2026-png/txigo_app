import 'package:flutter/material.dart';
import '../global_state.dart';
import '../services/api_service.dart';
import 'profile_details_screen.dart';
import 'kyc_documents_screen.dart';
import 'vehicle_documents_screen.dart';
import 'under_verification_screen.dart';
import 'home_screen.dart';

class DocumentHubScreen extends StatefulWidget {
  const DocumentHubScreen({super.key});

  @override
  State<DocumentHubScreen> createState() => _DocumentHubScreenState();
}

class _DocumentHubScreenState extends State<DocumentHubScreen> {
  // Txigo brand colors from logo
  static const Color txigoBlue = Color(0xFF1565C0);
  static const Color txigoOrange = Color(0xFFF47920);

  int profileStatus = 0; // 0: Not Started, 1: Incomplete, 2: Completed
  int kycStatus = 0;
  int vehicleStatus = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshStatus();
  }

  Future<void> _refreshStatus() async {
    setState(() => isLoading = true);
    await ApiService.getDriverStatus(GlobalState.mobile);
    if (mounted) {
      setState(() {
        // --- Profile Status ---
        bool hasAnyProfile = GlobalState.fullName != 'Not provided' || 
                             GlobalState.dob != 'Not provided' || 
                             GlobalState.address != 'Not provided' ||
                             GlobalState.pincode != 'Not provided' ||
                             GlobalState.state != 'Not provided';
                             
        profileStatus = GlobalState.isProfileComplete ? 2 : (hasAnyProfile ? 1 : 0);
                           
        // --- KYC Status ---
        bool hasAnyKYC = GlobalState.aadharNumber != 'Not provided' || 
                         GlobalState.aadharFrontUploaded ||
                         GlobalState.panNumber != 'Not provided' ||
                         GlobalState.panFrontUploaded ||
                         GlobalState.dlNumber != 'Not provided' ||
                         GlobalState.dlFrontUploaded;
                         
        kycStatus = GlobalState.isKYCComplete ? 2 : (hasAnyKYC ? 1 : 0);
                       
        // --- Vehicle Status ---
        bool hasAnyVehicle = GlobalState.rcNumber != 'Not provided' || 
                             GlobalState.rcFrontUploaded ||
                             GlobalState.carFrontUploaded;

        vehicleStatus = GlobalState.isVehicleComplete ? 2 : (hasAnyVehicle ? 1 : 0);
        
        isLoading = false;
      });
    }
  }

  bool get isAllCompleted => GlobalState.hasAllDocuments;

  void _submitData() async {
    if (GlobalState.mobile.isEmpty || GlobalState.mobile == 'Not provided') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mobile number is missing. Please update it in Profile Details.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final bool success;
    if (GlobalState.status == 'Pending' || GlobalState.status == 'Blocked') {
      success = await ApiService.reSubmitDriverData();
    } else {
      success = await ApiService.registerDriver();
    }

    setState(() {
      isLoading = false;
    });

    if (success) {
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const UnderVerificationScreen()),
        (route) => false,
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to submit documents. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  int get completedCount => [profileStatus, kycStatus, vehicleStatus].where((s) => s == 2).length;

  void _navigateTo(Widget screen, String key) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );

    if (result == true) {
      _refreshStatus();
    }
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
        title: const Text(
          'Documents',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Verification Status',
                      style: TextStyle(
                        color: Color(0xFF1565C0),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap on each category to provide the document details and upload photos.',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    if (GlobalState.statusReason.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFFB74D)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: Color(0xFFE65100)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Admin Feedback: ${GlobalState.statusReason}',
                                style: const TextStyle(
                                  color: Color(0xFFE65100),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          '$completedCount/3 Completed',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        ...List.generate(3, (i) => Container(
                          width: 28,
                          height: 4,
                          margin: const EdgeInsets.only(left: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: i < completedCount ? txigoOrange : Colors.grey.shade200,
                          ),
                        )),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildSectionTile(
                      title: 'Profile Details',
                      subtitle: 'Full Name, DOB, Email, Address',
                      icon: Icons.person_outline,
                      status: profileStatus,
                      onTap: () => _navigateTo(const ProfileDetailsScreen(), 'profile'),
                    ),
                    const SizedBox(height: 16),
                    _buildSectionTile(
                      title: 'KYC Details',
                      subtitle: 'Aadhar, PAN Card, Driver License',
                      icon: Icons.assignment_ind_outlined,
                      status: kycStatus,
                      onTap: () => _navigateTo(const KYCDocumentsScreen(), 'kyc'),
                    ),
                    const SizedBox(height: 16),
                    _buildSectionTile(
                      title: 'Vehicle Details',
                      subtitle: 'Car RC, Vehicle Photos',
                      icon: Icons.directions_car_outlined,
                      status: vehicleStatus,
                      onTap: () => _navigateTo(const VehicleDocumentsScreen(), 'vehicle'),
                    ),
                  ],
                ),
              ),
            ),
            _buildSubmitSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required int status, // 0: Not Started, 1: Incomplete, 2: Completed
    required VoidCallback onTap,
  }) {
    Color tileColor;
    Color iconBgColor;
    Color iconColor;
    Color titleColor;
    IconData statusIcon;
    Color statusIconColor;
    double statusIconSize;

    if (status == 2) {
      // Completed
      tileColor = txigoOrange.withOpacity(0.05);
      iconBgColor = txigoOrange.withOpacity(0.1);
      iconColor = txigoOrange;
      titleColor = txigoOrange;
      statusIcon = Icons.check_circle;
      statusIconColor = Colors.green;
      statusIconSize = 24;
    } else if (status == 1) {
      // Incomplete / Partial
      tileColor = Colors.amber.withOpacity(0.05);
      iconBgColor = Colors.amber.withOpacity(0.1);
      iconColor = Colors.amber.shade700;
      titleColor = Colors.amber.shade800;
      statusIcon = Icons.error_outline;
      statusIconColor = Colors.amber.shade700;
      statusIconSize = 24;
    } else {
      // Not Started
      tileColor = Colors.grey.shade50;
      iconBgColor = Colors.grey.shade100;
      iconColor = Colors.grey;
      titleColor = Colors.black87;
      statusIcon = Icons.arrow_forward_ios;
      statusIconColor = Colors.grey.shade400;
      statusIconSize = 18;
    }

    return Container(
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: status == 2 ? txigoOrange : (status == 1 ? Colors.amber : Colors.transparent),
          width: 1.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                statusIcon,
                color: statusIconColor,
                size: statusIconSize,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: (isAllCompleted && !isLoading) ? _submitData : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: txigoOrange,
            disabledBackgroundColor: Colors.grey.shade300,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 0,
          ),
          child: isLoading 
            ? const SizedBox(
                width: 24, 
                height: 24, 
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
              )
            : const Text(
                'Submit All Documents',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
        ),
      ),
    );
  }
}
