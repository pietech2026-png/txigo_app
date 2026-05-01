import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../global_state.dart';
import '../utils/formatters.dart';
import '../services/api_service.dart';

class ProfileDetailsScreen extends StatefulWidget {
  const ProfileDetailsScreen({super.key});

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  
  bool _isLoading = false;
  final List<String> _indianStates = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand',
    'Karnataka', 'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur',
    'Meghalaya', 'Mizoram', 'Nagaland', 'Odisha', 'Punjab',
    'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana', 'Tripura',
    'Uttar Pradesh', 'Uttarakhand', 'West Bengal'
  ];
  bool get _isEditable => GlobalState.status != 'verified' && GlobalState.status != 'Active';

  @override
  void initState() {
    super.initState();
    _fullNameController.text = GlobalState.fullName != 'Not provided' ? GlobalState.fullName : '';
    _mobileController.text = GlobalState.mobile;
    _dobController.text = GlobalState.dob != 'Not provided' ? GlobalState.dob : '';
    _emailController.text = GlobalState.email != 'Not provided' ? GlobalState.email : '';
    _addressController.text = GlobalState.address != 'Not provided' ? GlobalState.address : '';
    _pincodeController.text = GlobalState.pincode != 'Not provided' ? GlobalState.pincode : '';
    _stateController.text = GlobalState.state != 'Not provided' ? GlobalState.state : '';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1A73E8),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _showStatePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select State', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A73E8))),
              const SizedBox(height: 15),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _indianStates.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_indianStates[index], textAlign: TextAlign.center),
                      onTap: () {
                        setState(() {
                          _stateController.text = _indianStates[index];
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
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
          'Profile Details',
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Personal Information',
                        style: TextStyle(
                          color: Color(0xFF1A73E8),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter your details as they appear on your official documents.',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                      ),
                      const SizedBox(height: 32),
                      _buildTextField('Full Name', _fullNameController, Icons.person_outline, isRequired: true),
                      const SizedBox(height: 20),
                      _buildTextField('Mobile Number', _mobileController, Icons.phone_android_outlined, keyboardType: TextInputType.phone, isRequired: true),
                      const SizedBox(height: 20),
                      _buildDateField('Date of Birth', _dobController),
                      const SizedBox(height: 20),
                      _buildTextField('Email ID (Optional)', _emailController, Icons.email_outlined, keyboardType: TextInputType.emailAddress, isRequired: false),
                      const SizedBox(height: 20),
                      _buildTextField('Full Address', _addressController, Icons.home_outlined, maxLines: 3, isRequired: true),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(child: _buildTextField('Pincode', _pincodeController, Icons.pin_drop_outlined, keyboardType: TextInputType.number, isRequired: true)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildSelectField('State', _stateController, Icons.map_outlined, () => _showStatePicker())),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {TextInputType? keyboardType, int maxLines = 1, required bool isRequired}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          enabled: _isEditable,
          autocorrect: false,
          enableSuggestions: false,
          inputFormatters: keyboardType == TextInputType.number || keyboardType == TextInputType.phone
              ? [HindiToEnglishDigitsFormatter()]
              : [],
          style: TextStyle(
            fontSize: 16,
            color: _isEditable ? Colors.black : Colors.grey.shade600,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: _isEditable ? const Color(0xFF1A73E8) : Colors.grey, size: 20),
            filled: true,
            fillColor: _isEditable ? Colors.grey.shade100 : Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: isRequired
              ? (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return _buildSelectField(label, controller, Icons.calendar_today_outlined, () => _selectDate(context));
  }

  Widget _buildSelectField(String label, TextEditingController controller, IconData icon, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          enabled: _isEditable,
          onTap: _isEditable ? onTap : null,
          style: TextStyle(
            fontSize: 16,
            color: _isEditable ? Colors.black : Colors.grey.shade600,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: _isEditable ? const Color(0xFF1A73E8) : Colors.grey, size: 20),
            suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
            filled: true,
            fillColor: _isEditable ? Colors.grey.shade100 : Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Required';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    if (!_isEditable) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: const Text(
          'Profile locked for verification. Contact support to request changes.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade100))),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: _isLoading ? null : () async {
            bool isValid = _formKey.currentState!.validate();
            
            // Check if at least some data is entered (other than mobile)
            bool hasData = _fullNameController.text.isNotEmpty || 
                           _dobController.text.isNotEmpty ||
                           _addressController.text.isNotEmpty ||
                           _pincodeController.text.isNotEmpty ||
                           _stateController.text.isNotEmpty;

            if (!hasData) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter at least one field to save.'),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }

            setState(() => _isLoading = true);

            // Update GlobalState
            GlobalState.fullName = _fullNameController.text.isEmpty ? 'Not provided' : _fullNameController.text;
            GlobalState.mobile = _mobileController.text;
            GlobalState.dob = _dobController.text.isEmpty ? 'Not provided' : _dobController.text;
            GlobalState.email = _emailController.text.isEmpty ? 'Not provided' : _emailController.text;
            GlobalState.address = _addressController.text.isEmpty ? 'Not provided' : _addressController.text;
            GlobalState.pincode = _pincodeController.text.isEmpty ? 'Not provided' : _pincodeController.text;
            GlobalState.state = _stateController.text.isEmpty ? 'Not provided' : _stateController.text;

            // Partial Save to Backend
            await ApiService.updateDriverProgress({
              'fullName': GlobalState.fullName,
              'email': GlobalState.email,
              'dob': GlobalState.dob,
              'address': GlobalState.address,
              'pincode': GlobalState.pincode,
              'state': GlobalState.state,
            });

            setState(() => _isLoading = false);
            
            if (mounted) {
              if (!isValid) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Progress saved. Please complete all fields for verification.'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
              Navigator.pop(context, true);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A73E8),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 0,
          ),
          child: _isLoading 
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Save Profile Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
