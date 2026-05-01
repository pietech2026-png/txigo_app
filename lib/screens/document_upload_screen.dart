import 'package:flutter/material.dart';
import 'home_screen.dart';

class DocumentUploadScreen extends StatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  final List<Map<String, dynamic>> documents = [
    {
      'id': 'dl',
      'title': 'Driving License (DL)',
      'subtitle': 'Front and Back clear photo required',
      'status': 'Pending',
      'icon': Icons.badge_outlined,
      'inputId': '',
      'isImageUploaded': false,
    },
    {
      'id': 'aadhar',
      'title': 'Aadhar Card',
      'subtitle': 'Identity proof verification',
      'status': 'Pending',
      'icon': Icons.assignment_ind_outlined,
      'inputId': '',
      'isImageUploaded': false,
    },
    {
      'id': 'rc',
      'title': 'Vehicle RC',
      'subtitle': 'Registration Certificate of your vehicle',
      'status': 'Pending',
      'icon': Icons.directions_car_outlined,
      'inputId': '',
      'isImageUploaded': false,
    },
    {
      'id': 'insurance',
      'title': 'Vehicle Insurance',
      'subtitle': 'Valid insurance copy',
      'status': 'Pending',
      'icon': Icons.security_outlined,
      'inputId': '',
      'isImageUploaded': false,
    },
    {
      'id': 'photo',
      'title': 'Driver Photo',
      'subtitle': 'Clear selfie for profile',
      'status': 'Pending',
      'icon': Icons.camera_alt_outlined,
      'inputId': 'Selfie', // Placeholder for photo
      'isImageUploaded': false,
    },
  ];

  bool get isAllCompleted => documents.every((doc) => doc['status'] == 'Uploaded');

  void _showUploadBottomSheet(Map<String, dynamic> doc) {
    final TextEditingController idController = TextEditingController(text: doc['inputId']);
    bool localImageUploaded = doc['isImageUploaded'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Upload ${doc['title']}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A73E8),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Provide the identification number and upload a clear photo.',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                    const SizedBox(height: 30),
                    if (doc['id'] != 'photo') ...[
                      const Text(
                        'Document Number',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: idController,
                        decoration: InputDecoration(
                          hintText: 'e.g. MH12 20210001234',
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (val) => setModalState(() {}),
                      ),
                      const SizedBox(height: 25),
                    ],
                    const Text(
                      'Media Upload',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        // Simulate image picking
                        setModalState(() {
                          localImageUploaded = true;
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          color: localImageUploaded ? Colors.green.shade50 : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: localImageUploaded ? Colors.green.shade300 : Colors.grey.shade300,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              localImageUploaded ? Icons.check_circle : Icons.add_a_photo_outlined,
                              size: 40,
                              color: localImageUploaded ? Colors.green : Colors.grey,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              localImageUploaded ? 'Photo Captured' : 'Tap to capture or upload',
                              style: TextStyle(
                                color: localImageUploaded ? Colors.green : Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: (localImageUploaded && (idController.text.isNotEmpty || doc['id'] == 'photo'))
                            ? () {
                                setState(() {
                                  doc['status'] = 'Uploaded';
                                  doc['inputId'] = idController.text;
                                  doc['isImageUploaded'] = true;
                                });
                                Navigator.pop(context);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A73E8),
                          disabledBackgroundColor: Colors.grey.shade300,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: const Text('Confirm & Save', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
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
                        color: Color(0xFF1A73E8),
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
                    const SizedBox(height: 32),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        final doc = documents[index];
                        return _buildDocumentTile(doc);
                      },
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

  Widget _buildDocumentTile(Map<String, dynamic> doc) {
    bool isUploaded = doc['status'] == 'Uploaded';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isUploaded ? const Color(0xFF1A73E8).withOpacity(0.02) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUploaded ? const Color(0xFF1A73E8).withOpacity(0.2) : Colors.grey.shade200,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isUploaded ? const Color(0xFF1A73E8).withOpacity(0.1) : Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(
            doc['icon'],
            color: isUploaded ? const Color(0xFF1A73E8) : Colors.grey,
          ),
        ),
        title: Text(
          doc['title'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isUploaded ? const Color(0xFF1A73E8) : Colors.black87,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            isUploaded ? 'ID: ${doc['inputId']}' : doc['subtitle'],
            style: TextStyle(
              color: isUploaded ? const Color(0xFF1A73E8).withOpacity(0.6) : Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
        ),
        trailing: Icon(
          isUploaded ? Icons.check_circle : Icons.add_circle_outline,
          color: isUploaded ? Colors.green : Colors.grey.shade400,
        ),
        onTap: () => _showUploadBottomSheet(doc),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: isAllCompleted
                  ? () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                        (route) => false,
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A73E8),
                disabledBackgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
              child: const Text(
                'Submit All Documents',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
