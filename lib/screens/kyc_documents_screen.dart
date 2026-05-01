import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../global_state.dart';
import '../services/api_service.dart';

class KYCDocumentsScreen extends StatefulWidget {
  const KYCDocumentsScreen({super.key});

  @override
  State<KYCDocumentsScreen> createState() => _KYCDocumentsScreenState();
}

class _KYCDocumentsScreenState extends State<KYCDocumentsScreen> {
  static const Color brandBlue = Color(0xFF1A73E8);

  // Aadhar
  final TextEditingController _aadharController = TextEditingController();
  String? _aadharFrontFileName;
  String? _aadharBackFileName;
  String? _aadharFrontUrl;
  String? _aadharBackUrl;

  // PAN
  final TextEditingController _panController = TextEditingController();
  String? _panFrontFileName;
  String? _panBackFileName;
  String? _panFrontUrl;
  String? _panBackUrl;

  // DL
  final TextEditingController _dlController = TextEditingController();
  String? _dlFrontFileName;
  String? _dlBackFileName;
  String? _dlFrontUrl;
  String? _dlBackUrl;

  bool _isLoading = false;
  bool _isUploadingFile = false;
  bool get _isEditable => GlobalState.status != 'verified' && GlobalState.status != 'Active';

  @override
  void initState() {
    super.initState();
    _aadharController.text = GlobalState.aadharNumber != 'Not provided' ? GlobalState.aadharNumber : '';
    if (GlobalState.aadharFrontUploaded) {
      _aadharFrontFileName = 'Uploaded';
      _aadharFrontUrl = GlobalState.aadharFrontUrl;
    }
    if (GlobalState.aadharBackUploaded) {
      _aadharBackFileName = 'Uploaded';
      _aadharBackUrl = GlobalState.aadharBackUrl;
    }

    _panController.text = GlobalState.panNumber != 'Not provided' ? GlobalState.panNumber : '';
    if (GlobalState.panFrontUploaded) {
      _panFrontFileName = 'Uploaded';
      _panFrontUrl = GlobalState.panFrontUrl;
    }
    if (GlobalState.panBackUploaded) {
      _panBackFileName = 'Uploaded';
      _panBackUrl = GlobalState.panBackUrl;
    }

    _dlController.text = GlobalState.dlNumber != 'Not provided' ? GlobalState.dlNumber : '';
    if (GlobalState.dlFrontUploaded) {
      _dlFrontFileName = 'Uploaded';
      _dlFrontUrl = GlobalState.dlFrontUrl;
    }
    if (GlobalState.dlBackUploaded) {
      _dlBackFileName = 'Uploaded';
      _dlBackUrl = GlobalState.dlBackUrl;
    }
  }

  bool get isAllCompleted =>
      _aadharController.text.isNotEmpty && _aadharFrontFileName != null &&
      _panController.text.isNotEmpty && _panFrontFileName != null &&
      _dlController.text.isNotEmpty && _dlFrontFileName != null;

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
                subtitle: const Text('Take a fresh photo of the document'),
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
        title: const Text('KYC Documents', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
                    const Text('Identity Proof', style: TextStyle(color: Color(0xFF1A73E8), fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Provide your identity documents for verification.', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                    const SizedBox(height: 32),

                    // ---- AADHAR CARD ----
                    _buildSectionHeader('Aadhar Card'),
                    const SizedBox(height: 12),
                    _buildNumberField('Aadhar Card Number', _aadharController, 'Enter 12-digit Aadhar number'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildImageUploadTile('Aadhar Front', _aadharFrontFileName != null, () { 
                          _pickFile('Aadhar Front', (name, url) { 
                            _aadharFrontFileName = name; 
                            _aadharFrontUrl = url; 
                          }); 
                        }, subtitle: _aadharFrontFileName)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildImageUploadTile('Aadhar Back', _aadharBackFileName != null, () { 
                          _pickFile('Aadhar Back', (name, url) { 
                            _aadharBackFileName = name; 
                            _aadharBackUrl = url; 
                          }); 
                        }, subtitle: _aadharBackFileName)),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // ---- PAN CARD ----
                    _buildSectionHeader('PAN Card'),
                    const SizedBox(height: 12),
                    _buildNumberField('PAN Card Number', _panController, 'Enter PAN number'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildImageUploadTile('PAN Front', _panFrontFileName != null, () { 
                          _pickFile('PAN Front', (name, url) { 
                            _panFrontFileName = name; 
                            _panFrontUrl = url; 
                          }); 
                        }, subtitle: _panFrontFileName)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildImageUploadTile('PAN Back', _panBackFileName != null, () { 
                          _pickFile('PAN Back', (name, url) { 
                            _panBackFileName = name; 
                            _panBackUrl = url; 
                          }); 
                        }, subtitle: _panBackFileName)),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // ---- DRIVING LICENSE ----
                    _buildSectionHeader('Driving License (DL)'),
                    const SizedBox(height: 12),
                    _buildNumberField('DL Number', _dlController, 'Enter DL number'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildImageUploadTile('DL Front', _dlFrontFileName != null, () { 
                          _pickFile('DL Front', (name, url) { 
                            _dlFrontFileName = name; 
                            _dlFrontUrl = url; 
                          }); 
                        }, subtitle: _dlFrontFileName)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildImageUploadTile('DL Back', _dlBackFileName != null, () { 
                          _pickFile('DL Back', (name, url) { 
                            _dlBackFileName = name; 
                            _dlBackUrl = url; 
                          }); 
                        }, subtitle: _dlBackFileName)),
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
          'Documents locked for verification. Contact support to request changes.',
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
            bool hasAnyData = _aadharController.text.isNotEmpty || _aadharFrontFileName != null ||
                              _panController.text.isNotEmpty || _panFrontFileName != null ||
                              _dlController.text.isNotEmpty || _dlFrontFileName != null;

            if (!hasAnyData) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter at least one field or upload a document to save.'), backgroundColor: Colors.orange),
              );
              return;
            }

            setState(() => _isLoading = true);

            GlobalState.aadharNumber = _aadharController.text.isEmpty ? 'Not provided' : _aadharController.text;
            GlobalState.aadharFrontUploaded = _aadharFrontFileName != null;
            GlobalState.aadharFrontUrl = _aadharFrontUrl ?? '';
            GlobalState.aadharBackUploaded = _aadharBackFileName != null;
            GlobalState.aadharBackUrl = _aadharBackUrl ?? '';

            GlobalState.panNumber = _panController.text.isEmpty ? 'Not provided' : _panController.text;
            GlobalState.panFrontUploaded = _panFrontFileName != null;
            GlobalState.panFrontUrl = _panFrontUrl ?? '';
            GlobalState.panBackUploaded = _panBackFileName != null;
            GlobalState.panBackUrl = _panBackUrl ?? '';

            GlobalState.dlNumber = _dlController.text.isEmpty ? 'Not provided' : _dlController.text;
            GlobalState.dlFrontUploaded = _dlFrontFileName != null;
            GlobalState.dlFrontUrl = _dlFrontUrl ?? '';
            GlobalState.dlBackUploaded = _dlBackFileName != null;
            GlobalState.dlBackUrl = _dlBackUrl ?? '';

            // Partial Save to Backend using REAL URLs
            await ApiService.updateDriverProgress({
              'aadharNumber': GlobalState.aadharNumber,
              'panNumber': GlobalState.panNumber,
              'dlNumber': GlobalState.dlNumber,
              'documents': {
                'aadharFront': {'url': GlobalState.aadharFrontUrl},
                'aadharBack': {'url': GlobalState.aadharBackUrl},
                'panFront': {'url': GlobalState.panFrontUrl},
                'panBack': {'url': GlobalState.panBackUrl},
                'dlFront': {'url': GlobalState.dlFrontUrl},
                'dlBack': {'url': GlobalState.dlBackUrl},
              }
            });

            setState(() => _isLoading = false);
            if (mounted) {
              if (!isAllCompleted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Progress saved. Please complete all documents for verification.'), backgroundColor: Colors.orange),
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
            : const Text('Save KYC Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
