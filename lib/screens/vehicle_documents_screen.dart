import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../global_state.dart';
import '../services/api_service.dart';

class VehicleDocumentsScreen extends StatefulWidget {
  const VehicleDocumentsScreen({super.key});

  @override
  State<VehicleDocumentsScreen> createState() => _VehicleDocumentsScreenState();
}

class _VehicleDocumentsScreenState extends State<VehicleDocumentsScreen> {
  static const Color brandBlue = Color(0xFF1A73E8);

  // RC
  final TextEditingController _rcController = TextEditingController();
  String? _rcFrontFileName;
  String? _rcBackFileName;
  String? _rcFrontUrl;
  String? _rcBackUrl;

  // Car Images
  String? _carFrontFileName;
  String? _carBackFileName;
  String? _carFrontUrl;
  String? _carBackUrl;
  
  String _selectedSittingCapacity = GlobalState.sittingCapacity;
  final List<String> _sittingOptions = [
    '4 Seater',
    '6 Seater',
    '7 Seater',
    '13 Seater',
    '15 Seater',
    '17 Seater',
    '25 Seater'
  ];

  bool _isLoading = false;
  bool _isUploadingFile = false;
  bool get _isEditable => GlobalState.status != 'verified' && GlobalState.status != 'Active';

  @override
  void initState() {
    super.initState();
    _rcController.text = GlobalState.rcNumber != 'Not provided' ? GlobalState.rcNumber : '';
    if (GlobalState.rcFrontUploaded) {
      _rcFrontFileName = 'Uploaded';
      _rcFrontUrl = GlobalState.rcFrontUrl;
    }
    if (GlobalState.rcBackUploaded) {
      _rcBackFileName = 'Uploaded';
      _rcBackUrl = GlobalState.rcBackUrl;
    }
    if (GlobalState.carFrontUploaded) {
      _carFrontFileName = 'Uploaded';
      _carFrontUrl = GlobalState.carFrontUrl;
    }
    if (GlobalState.carBackUploaded) {
      _carBackFileName = 'Uploaded';
      _carBackUrl = GlobalState.carBackUrl;
    }
  }

  bool get isAllCompleted =>
      _rcController.text.isNotEmpty && _rcFrontFileName != null &&
      _carFrontFileName != null;

  Future<void> _handleFileUpload(String? path, String type, Function(String, String) onUploaded) async {
    if (path == null) return;
    
    setState(() => _isUploadingFile = true);
    final String fileName = path.split('/').last;
    
    final String? url = await ApiService.uploadFile(path);
    
    setState(() {
      _isUploadingFile = false;
      if (url != null) {
        onUploaded(fileName, url);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$type uploaded successfully!'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload $type'), backgroundColor: Colors.red),
        );
      }
    });
  }

  Future<void> _pickFile(String type, Function(String, String) onUploaded) async {
    if (!_isEditable) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Upload $type',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.photo_library, color: brandBlue),
                title: const Text('Photos Gallery'),
                subtitle: const Text('Pick an image from your device photos'),
                onTap: () async {
                  Navigator.pop(context);
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
                  if (image != null) {
                    await _handleFileUpload(image.path, type, onUploaded);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: brandBlue),
                title: const Text('Capture with Camera'),
                subtitle: const Text('Take a fresh photo of the vehicle / RC'),
                onTap: () async {
                  Navigator.pop(context);
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
                  if (image != null) {
                    await _handleFileUpload(image.path, type, onUploaded);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('Vehicle Documents', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
                    const Text('Vehicle Verification', style: TextStyle(color: Color(0xFF1A73E8), fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Provide your vehicle registration and images.', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                    const SizedBox(height: 32),

                    // ---- REGISTRATION CERTIFICATE ----
                    _buildSectionHeader('Registration Certificate (RC)'),
                    const SizedBox(height: 12),
                    _buildNumberField('RC Number', _rcController, 'Enter RC number'),
                    const SizedBox(height: 20),
                    _buildSittingCapacityDropdown(),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildImageUploadTile('RC Front', _rcFrontFileName != null, () { 
                          _pickFile('RC Front', (name, url) { _rcFrontFileName = name; _rcFrontUrl = url; }); 
                        }, subtitle: _rcFrontFileName)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildImageUploadTile('RC Back', _rcBackFileName != null, () { 
                          _pickFile('RC Back', (name, url) { _rcBackFileName = name; _rcBackUrl = url; }); 
                        }, subtitle: _rcBackFileName)),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // ---- CAR IMAGES ----
                    _buildSectionHeader('Car Images'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildImageUploadTile('Car Front', _carFrontFileName != null, () { 
                          _pickFile('Car Front', (name, url) { _carFrontFileName = name; _carFrontUrl = url; }); 
                        }, subtitle: _carFrontFileName)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildImageUploadTile('Car Back', _carBackFileName != null, () { 
                          _pickFile('Car Back', (name, url) { _carBackFileName = name; _carBackUrl = url; }); 
                        }, subtitle: _carBackFileName)),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
    );
  }

  Widget _buildNumberField(String label, TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      enabled: _isEditable,
      onChanged: (_) => setState(() {}),
      style: TextStyle(
        fontSize: 16,
        color: _isEditable ? Colors.black : Colors.grey.shade600,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: _isEditable ? Colors.grey.shade100 : Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        prefixIcon: Icon(Icons.numbers, color: _isEditable ? const Color(0xFF1A73E8) : Colors.grey, size: 20),
      ),
    );
  }

  Widget _buildSittingCapacityDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sitting Capacity',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: brandBlue),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: _isEditable ? Colors.grey.shade100 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(15),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedSittingCapacity,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: brandBlue),
              style: const TextStyle(fontSize: 16, color: Colors.black),
              onChanged: _isEditable
                  ? (String? newValue) {
                      if (newValue != null) {
                        setState(() => _selectedSittingCapacity = newValue);
                      }
                    }
                  : null,
              items: _sittingOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageUploadTile(String label, bool isUploaded, VoidCallback onTap, {String? subtitle}) {
    return GestureDetector(
      onTap: _isEditable ? onTap : null,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: isUploaded ? Colors.green.shade50 : (_isEditable ? Colors.grey.shade100 : Colors.grey.shade50),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isUploaded ? Colors.green.shade300 : Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isUploaded ? Icons.check_circle : Icons.add_a_photo_outlined,
              size: 32,
              color: isUploaded ? Colors.green : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              isUploaded ? '$label ✓' : label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isUploaded ? Colors.green : Colors.grey.shade600,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            if (isUploaded && subtitle != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.green, fontSize: 10),
                ),
              ),
            if (!isUploaded && !_isUploadingFile)
              Text('JPEG / PDF', style: TextStyle(color: Colors.grey.shade400, fontSize: 10)),
            if (!isUploaded && _isUploadingFile)
              const SizedBox(height: 10, width: 10, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    if (!_isEditable) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: const Text(
          'Vehicle details locked for verification. Contact support to request changes.',
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
          onPressed: (_isLoading) ? null : () async {
            // Check if at least some data is entered
            bool hasAnyData = _rcController.text.isNotEmpty || _rcFrontFileName != null || _carFrontFileName != null;

            if (!hasAnyData) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter RC number or upload a photo to save.'), backgroundColor: Colors.orange),
              );
              return;
            }

            setState(() => _isLoading = true);

            GlobalState.rcNumber = _rcController.text.isEmpty ? 'Not provided' : _rcController.text;
            GlobalState.sittingCapacity = _selectedSittingCapacity;
            GlobalState.rcFrontUploaded = _rcFrontFileName != null;
            GlobalState.rcFrontUrl = _rcFrontUrl ?? '';
            GlobalState.rcBackUploaded = _rcBackFileName != null;
            GlobalState.rcBackUrl = _rcBackUrl ?? '';
            GlobalState.carFrontUploaded = _carFrontFileName != null;
            GlobalState.carFrontUrl = _carFrontUrl ?? '';
            GlobalState.carBackUploaded = _carBackFileName != null;
            GlobalState.carBackUrl = _carBackUrl ?? '';

            // Partial Save to Backend using REAL URLs
            await ApiService.updateDriverProgress({
              'rcNumber': GlobalState.rcNumber,
              'sittingCapacity': GlobalState.sittingCapacity,
              'documents': {
                ...GlobalState.toBackendDocuments(), 
                'rcFront': {'url': GlobalState.rcFrontUrl},
                'rcBack': {'url': GlobalState.rcBackUrl},
                'carFront': {'url': GlobalState.carFrontUrl},
                'carBack': {'url': GlobalState.carBackUrl},
              }
            });

            setState(() => _isLoading = false);
            if (mounted) {
              if (!isAllCompleted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Progress saved. Please complete all vehicle details for verification.'), backgroundColor: Colors.orange),
                );
              }
              Navigator.pop(context, true); 
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: brandBlue,
            disabledBackgroundColor: Colors.grey.shade300,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 0,
          ),
          child: _isLoading 
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Save Vehicle Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
