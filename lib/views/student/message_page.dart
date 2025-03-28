import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/message_model.dart';
import 'package:firebase_storage/firebase_storage.dart';

class MessagePage extends StatefulWidget {
  final Map<String, dynamic> user;

  const MessagePage({super.key, required this.user});

  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  File? _imageFile;

  // Function to send a message (text or image)
  Future<void> _sendMessage({String? imageUrl}) async {
    if (_messageController.text.isEmpty && imageUrl == null) return;

    final message = MessageModel(
      studentId: "student123", // Replace with actual student ID
      studentName: "Student Name", // Replace with actual student name
      message: _messageController.text,
      timestamp: DateTime.now(),
      isEmergency: false,
      recipientType: widget.user['role'], // 'admin' or 'parent'
      status: MessageStatus.sent,
      read: false,
      imageUrl: imageUrl,
    );

    await _firestore.collection('messages').add(message.toMap());

    _messageController.clear();
  }

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
      await _uploadImage();
    }
  }

  // Function to upload an image to Firebase Storage
  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      UploadTask uploadTask = _storage.ref('chat_images/$fileName.jpg').putFile(_imageFile!);
      TaskSnapshot snapshot = await uploadTask;
      String imageUrl = await snapshot.ref.getDownloadURL();

      _sendMessage(imageUrl: imageUrl); // Send image message
    } catch (e) {
      print("Error uploading image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.user['name'] ?? 'Chat')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('messages')
                  .where('recipientType', isEqualTo: widget.user['role'])
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                var messages = snapshot.data!.docs.map((doc) {
                  return MessageModel.fromDocument(doc);
                }).toList();

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return ListTile(
                      title: message.imageUrl != null
                          ? Image.network(message.imageUrl!)
                          : Text(message.message),
                      subtitle: Text(message.formattedTime),
                      trailing: message.status == MessageStatus.read
                          ? const Icon(Icons.done_all, color: Colors.blue)
                          : const Icon(Icons.done, color: Colors.grey),
                    );
                  },
                );
              },
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.image),
                onPressed: _pickImage,
              ),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(hintText: "Type a message..."),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => _sendMessage(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
