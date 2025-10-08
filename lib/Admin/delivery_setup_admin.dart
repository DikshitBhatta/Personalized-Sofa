import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timberr/constants.dart';

class DeliverySetupAdmin extends StatelessWidget {
  const DeliverySetupAdmin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance.collection('delivery_zones').snapshots();
    return Scaffold(
      backgroundColor: kBackgroundBeige,
      appBar: AppBar(
        backgroundColor: kBackgroundBeige,
        title: const Text('Delivery Setup', style: kMerriweatherBold16),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final docs = snap.data?.docs ?? [];
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final d = docs[i].data()! as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(d['zoneName'] ?? 'Zone'),
                  subtitle: Text('Fee: ฿${d['fee'] ?? 0}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => docs[i].reference.delete(),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              final nameC = TextEditingController();
              final feeC = TextEditingController();
              return AlertDialog(
                title: const Text('Add Delivery Zone'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: nameC, decoration: const InputDecoration(labelText: 'Zone name')),
                    TextField(controller: feeC, decoration: const InputDecoration(labelText: 'Fee (฿)'), keyboardType: TextInputType.number),
                  ],
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  ElevatedButton(
                    onPressed: () {
                      final name = nameC.text.trim();
                      final fee = double.tryParse(feeC.text.trim()) ?? 0.0;
                      if (name.isNotEmpty) {
                        FirebaseFirestore.instance.collection('delivery_zones').add({'zoneName': name, 'fee': fee});
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Add'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
