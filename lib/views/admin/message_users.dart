import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../shared/message_screen.dart';

class MessageUsersScreen extends StatefulWidget {
  const MessageUsersScreen({super.key});

  @override
  State<MessageUsersScreen> createState() => _MessageUsersScreenState();
}

class _MessageUsersScreenState extends State<MessageUsersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedUserType = 'all';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Message Users'),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Send Broadcast', icon: Icon(Icons.campaign)),
              Tab(text: 'Direct Messages', icon: Icon(Icons.message)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildBroadcastTab(),
            const MessageScreen(userRole: 'admin'),
          ],
        ),
      ),
    );
  }

  Widget _buildBroadcastTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Send Broadcast Message',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedUserType,
                    decoration: const InputDecoration(
                      labelText: 'Select Recipients',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'all',
                        child: Text('All Users'),
                      ),
                      DropdownMenuItem(
                        value: 'student',
                        child: Text('All Students'),
                      ),
                      DropdownMenuItem(
                        value: 'parent',
                        child: Text('All Parents'),
                      ),
                      DropdownMenuItem(
                        value: 'driver',
                        child: Text('All Drivers'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedUserType = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: _selectedUserType == 'all'
                ? _firestore.collection('users').snapshots()
                : _firestore
                    .collection('users')
                    .where('role', isEqualTo: _selectedUserType)
                    .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recipients: ${snapshot.data!.docs.length}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Selected Group: ${_selectedUserType.toUpperCase()}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
