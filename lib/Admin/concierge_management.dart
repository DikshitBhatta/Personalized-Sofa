import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timberr/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:get/get.dart';

class ConciergeManagement extends StatefulWidget {
  const ConciergeManagement({Key? key}) : super(key: key);

  @override
  State<ConciergeManagement> createState() => _ConciergeManagementState();
}

class _ConciergeManagementState extends State<ConciergeManagement> {
  final _firestore = FirebaseFirestore.instance;
  bool _loading = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _ratingController = TextEditingController(text: '4.9');
  final _visitsController = TextEditingController(text: '127');
  
  File? _selectedImage;
  String? _uploadedImageUrl;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(String conciergeName) async {
    if (_selectedImage == null) return null;
    
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('concierges')
          .child('${DateTime.now().millisecondsSinceEpoch}_${conciergeName.replaceAll(' ', '_')}.jpg');
      
      await ref.putFile(_selectedImage!);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _addConcierge() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final specialty = _specialtyController.text.trim();
    final rating = double.tryParse(_ratingController.text.trim()) ?? 4.9;
    final visits = int.tryParse(_visitsController.text.trim()) ?? 127;
    
    if (name.isEmpty || phone.isEmpty) {
      Get.snackbar('Error', 'Name and phone are required', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    
    setState(() => _loading = true);
    
    // Upload image if selected
    String? imageUrl;
    if (_selectedImage != null) {
      imageUrl = await _uploadImage(name);
    }
    
    await _firestore.collection('concierges').add({
      'name': name,
      'phone': phone,
      'email': email,
      'specialty': specialty.isEmpty ? 'Senior Furniture Design Specialist' : specialty,
      'rating': rating,
      'visits': visits,
      'photo_url': imageUrl,
      'is_default': false,
      'available': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    _nameController.clear();
    _phoneController.clear();
    _emailController.clear();
    _specialtyController.clear();
    _ratingController.text = '4.9';
    _visitsController.text = '127';
    setState(() {
      _selectedImage = null;
      _loading = false;
    });
    
    Get.snackbar('Success', 'Concierge added successfully', snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> _setAsDefault(String docId) async {
    try {
      // First, set all concierges to not default
      final allConcierges = await _firestore.collection('concierges').get();
      for (var doc in allConcierges.docs) {
        await doc.reference.update({'is_default': false});
      }
      
      // Then set this one as default
      await _firestore.collection('concierges').doc(docId).update({'is_default': true});
      
      Get.snackbar('Success', 'Default concierge updated', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to set default: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundBeige,
      appBar: AppBar(
        backgroundColor: kBackgroundBeige,
        title: const Text('Concierge Management', style: kMerriweatherBold16),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Add Concierge Form
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Add New Concierge', style: kNunitoSansBold18.copyWith(color: kOffBlack)),
                      const SizedBox(height: 16),
                      
                      // Photo Picker
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: kChristmasSilver,
                              border: Border.all(color: kSeaGreen, width: 2),
                            ),
                            child: _selectedImage != null
                                ? ClipOval(
                                    child: Image.file(
                                      _selectedImage!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_a_photo, size: 40, color: kTinGrey),
                                      const SizedBox(height: 4),
                                      Text('Add Photo', style: kNunitoSans12Grey),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _specialtyController,
                        decoration: const InputDecoration(
                          labelText: 'Specialty',
                          hintText: 'e.g., Senior Furniture Design Specialist',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _ratingController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Rating',
                                hintText: '4.9',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _visitsController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'No. of Visits',
                                hintText: '127',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _addConcierge,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kSeaGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Add Concierge', style: TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              Text('Concierge List', style: kNunitoSansBold18.copyWith(color: kOffBlack)),
              const SizedBox(height: 12),
              
              // Concierge List
              StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('concierges').orderBy('createdAt', descending: true).snapshots(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final docs = snap.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(Icons.support_agent, size: 64, color: kTinGrey),
                            const SizedBox(height: 16),
                            Text('No concierges added yet', style: kNunitoSans16.copyWith(color: kTinGrey)),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    itemBuilder: (context, i) {
                      final doc = docs[i];
                      final d = doc.data()! as Map<String, dynamic>;
                      final available = d['available'] ?? true;
                      final isDefault = d['is_default'] ?? false;
                      final photoUrl = d['photo_url'];
                      final rating = d['rating'] ?? 4.9;
                      final visits = d['visits'] ?? 127;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: isDefault ? 4 : 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isDefault ? kSeaGreen : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Photo
                                  Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isDefault ? kSeaGreen : kChristmasSilver,
                                        width: 2,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: photoUrl != null
                                          ? Image.network(
                                              photoUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => 
                                                  Image.asset('assets/SJ.jpeg', fit: BoxFit.cover),
                                            )
                                          : Image.asset('assets/SJ.jpeg', fit: BoxFit.cover),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  
                                  // Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                d['name'] ?? 'No Name',
                                                style: kNunitoSansBold18.copyWith(color: kOffBlack),
                                              ),
                                            ),
                                            if (isDefault)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: kSeaGreen,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  'DEFAULT',
                                                  style: kNunitoSans12Grey.copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          d['specialty'] ?? 'Furniture Specialist',
                                          style: kNunitoSans14.copyWith(color: kTinGrey),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(Icons.star, size: 16, color: Colors.amber),
                                            const SizedBox(width: 4),
                                            Text('$rating', style: kNunitoSans14),
                                            const SizedBox(width: 16),
                                            Icon(Icons.verified, size: 16, color: kSeaGreen),
                                            const SizedBox(width: 4),
                                            Text('$visits Visits', style: kNunitoSans14),
                                          ],
                                        ),
                                        if (d['phone'] != null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            d['phone'],
                                            style: kNunitoSans12Grey,
                                          ),
                                        ],
                                        if (d['email'] != null && d['email'].toString().isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            d['email'],
                                            style: kNunitoSans12Grey,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 12),
                              const Divider(),
                              const SizedBox(height: 8),
                              
                              // Action Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: isDefault ? null : () => _setAsDefault(doc.id),
                                      icon: Icon(
                                        isDefault ? Icons.check_circle : Icons.star_border,
                                        size: 18,
                                      ),
                                      label: Text(isDefault ? 'Default' : 'Set as Default'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: isDefault ? kSeaGreen : kOffBlack,
                                        side: BorderSide(color: isDefault ? kSeaGreen : kChristmasSilver),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: kChristmasSilver),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Text('Available', style: kNunitoSans12Grey),
                                        Switch(
                                          value: available,
                                          onChanged: (val) => doc.reference.update({'available': val}),
                                          activeColor: kSeaGreen,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: kFireOpal),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete Concierge'),
                                          content: Text('Are you sure you want to delete ${d['name']}?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () => Navigator.pop(context, true),
                                              style: ElevatedButton.styleFrom(backgroundColor: kFireOpal),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                      
                                      if (confirm == true) {
                                        await doc.reference.delete();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
