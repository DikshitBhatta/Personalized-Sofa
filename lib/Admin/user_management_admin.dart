import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timberr/constants.dart';

class UserManagementAdmin extends StatelessWidget {
  const UserManagementAdmin({Key? key}) : super(key: key);

  Future<void> _toggleRole(DocumentReference ref, String currentRole) async {
    final newRole = currentRole == 'admin' ? 'user' : 'admin';
    await ref.update({'role': newRole});
  }

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance.collection('users').snapshots();
    return Scaffold(
      backgroundColor: kBackgroundBeige,
      appBar: AppBar(
        backgroundColor: kBackgroundBeige,
        title: const Text('User Management', style: kMerriweatherBold16),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) return const Center(child: Text('No users found'));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final doc = docs[i];
              final data = doc.data() as Map<String, dynamic>;
              final role = (data['role'] ?? 'user').toString();
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(data['name'] ?? data['displayName'] ?? 'No name'),
                  subtitle: Text(data['email'] ?? 'No email'),
                  trailing: TextButton(
                    onPressed: () => _toggleRole(doc.reference, role),
                    child: Text(role == 'admin' ? 'Remove Admin' : 'Make Admin'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
