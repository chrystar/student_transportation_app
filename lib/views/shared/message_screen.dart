import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../services/message_service.dart';

class MessageScreen extends StatefulWidget {
  final String? userRole;
  const MessageScreen({super.key, this.userRole});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  // final FlutterLocalNotificationsPlugin _notificationsPlugin =
  //     FlutterLocalNotificationsPlugin();
  bool _isLoading = false;
  String _searchQuery = '';
  File? _imageFile;
  final MessageService _messageService = MessageService();

  @override
  void initState() {
    super.initState();
    //_initializeNotifications();
    _listenToMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Future<void> _initializeNotifications() async {
  //   const androidSettings =
  //       AndroidInitializationSettings('@mipmap/ic_launcher');
  //   const IOSInitializationSettings iosSettings = IOSInitializationSettings();
  //   const initSettings =
  //       InitializationSettings(android: androidSettings, iOS: iosSettings);
  //
  //   await _notificationsPlugin.initialize(
  //     initSettings,
  //     onSelectNotification: (String? payload) async {
  //       // Handle notification tap
  //     },
  //   );
  // }

  void _listenToMessages() {
    final user = _auth.currentUser;
    if (user == null) return;

    _firestore
        .collection('messages')
        .where('recipientId', isEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
         // _showNotification(change.doc.data() as Map<String, dynamic>);
        }
      }
    });
  }


  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final ref = _storage.ref().child('message_images/${DateTime.now()}.jpg');
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _sendMessage(String recipientId, String recipientRole) async {
    if (_messageController.text.trim().isEmpty && _imageFile == null) return;

    setState(() => _isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final senderName = userDoc.get('name') as String;

      String? imageUrl;
      if (_imageFile != null) {
        imageUrl = await _uploadImage(_imageFile!);
      }

      // Create the message document
      await _firestore.collection('messages').add({
        'content': _messageController.text,
        'imageUrl': imageUrl,
        'senderId': user.uid,
        'senderName': senderName,
        'senderRole': widget.userRole,
        'recipientId': recipientId,
        'recipientRole': recipientRole,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      _messageController.clear();
      setState(() {
        _imageFile = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteMessage(String messageId) async {
    try {
      await _firestore.collection('messages').doc(messageId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message deleted')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting message: $e')),
      );
    }
  }

  Widget _buildMessageList() {
    final user = _auth.currentUser;
    if (user == null) return const SizedBox();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search messages...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('messages')
                .where('recipientId', isEqualTo: user.uid)
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final messages = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return _searchQuery.isEmpty ||
                    data['content']
                        .toString()
                        .toLowerCase()
                        .contains(_searchQuery) ||
                    data['senderName']
                        .toString()
                        .toLowerCase()
                        .contains(_searchQuery);
              }).toList();

              if (messages.isEmpty) {
                return const Center(child: Text('No messages found'));
              }

              return ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message =
                      messages[index].data() as Map<String, dynamic>;
                  final timestamp = message['timestamp'] as Timestamp?;
                  final dateString = timestamp != null
                      ? DateFormat('MMM dd, HH:mm').format(timestamp.toDate())
                      : '';

                  return Dismissible(
                    key: Key(messages[index].id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      _deleteMessage(messages[index].id);
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ListTile(
                            title: Text(message['content']),
                            subtitle: Text(
                                'From: ${message['senderName']} • $dateString'),
                            leading: CircleAvatar(
                              child:
                                  Text(message['senderName'][0].toUpperCase()),
                            ),
                            trailing: !message['isRead']
                                ? Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                  )
                                : null,
                            onTap: () async {
                              if (!message['isRead']) {
                                await messages[index]
                                    .reference
                                    .update({'isRead': true});
                              }
                            },
                          ),
                          if (message['imageUrl'] != null)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.network(
                                message['imageUrl'],
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showMessageDialog(
      String recipientId, String recipientName, String recipientRole) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Message to $recipientName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            if (_imageFile != null)
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Image.file(
                    _imageFile!,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _imageFile = null;
                      });
                    },
                  ),
                ],
              ),
            TextButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Add Image'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _sendMessage(recipientId, recipientRole);
              Navigator.pop(context);
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _messageService.getContacts(widget.userRole ?? ''),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final contact = snapshot.data!.docs[index];
            return ListTile(
              title: Text(contact['name']),
              subtitle: Text(contact['role'].toString().toUpperCase()),
              leading: CircleAvatar(
                child: Text(contact['name'][0].toUpperCase()),
              ),
              onTap: () {
                _showMessageDialog(
                    contact.id, contact['name'], contact['role']);
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Messages'),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Messages', icon: Icon(Icons.message)),
              Tab(text: 'Contacts', icon: Icon(Icons.people)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildMessageList(),
            _buildContactsList(),
          ],
        ),
      ),
    );
  }
}
