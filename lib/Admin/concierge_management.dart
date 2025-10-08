import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timberr/constants.dart';

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

  Future<void> _addConcierge() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final specialty = _specialtyController.text.trim();
    if (name.isEmpty || phone.isEmpty) return;
    setState(() => _loading = true);
    await _firestore.collection('concierges').add({
      'name': name,
      'phone': phone,
      'email': email,
      'specialty': specialty.isEmpty ? 'General Consultation' : specialty,
      'available': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
    _nameController.clear();
    _phoneController.clear();
    _emailController.clear();
    _specialtyController.clear();
    setState(() => _loading = false);
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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Full Name')),
                      const SizedBox(height: 8),
                      TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone Number')),
                      const SizedBox(height: 8),
                      TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email Address')),
                      const SizedBox(height: 8),
                      TextField(controller: _specialtyController, decoration: const InputDecoration(labelText: 'Specialty (optional)', hintText: 'e.g., Sofa Design, Interior Consultation')),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _addConcierge,
                          child: _loading ? const CircularProgressIndicator() : const Text('Add Concierge'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('concierges').orderBy('createdAt', descending: true).snapshots(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  final docs = snap.data?.docs ?? [];
                  if (docs.isEmpty) return const Center(child: Text('No concierges added'));
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    itemBuilder: (context, i) {
                      final d = docs[i].data()! as Map<String, dynamic>;
                      final available = d['available'] ?? true;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: available ? Colors.green : Colors.red,
                            child: Text(
                              (d['name'] ?? 'N').toString().substring(0, 1).toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(d['name'] ?? 'No Name', style: kNunitoSansSemiBold16),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(d['phone'] ?? 'No Phone', style: kNunitoSans12Grey),
                              if (d['email'] != null && d['email'].toString().isNotEmpty)
                                Text(d['email'], style: kNunitoSans12Grey),
                              if (d['specialty'] != null && d['specialty'].toString().isNotEmpty)
                                Text('${d['specialty']}', style: kNunitoSans12Grey.copyWith(fontStyle: FontStyle.italic)),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: available,
                                onChanged: (val) => docs[i].reference.update({'available': val}),
                                activeColor: Colors.green,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => docs[i].reference.delete(),
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
