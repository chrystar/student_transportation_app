import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ParentMessageScreen extends StatefulWidget {
  final String recipientId;
  final String recipientName;

  const ParentMessageScreen({
    super.key,
    required this.recipientId,
    required this.recipientName,
  });

  @override
  _ParentMessageScreenState createState() => _ParentMessageScreenState();
}

class _ParentMessageScreenState extends State<ParentMessageScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Function to send a message
  Future<void> _sendMessage() async {
    if (_formKey.currentState!.validate()) {
      try {
        final senderId = _auth.currentUser!.uid;
        final messageText = _messageController.text.trim();

        if (messageText.isNotEmpty) {
          // Add the message to the 'messages' collection
          await _firestore.collection('messages').add({
            'senderId': senderId,
            'senderName': 'Parent', // You can store parent's name
            'recipientId': widget.recipientId,
            'recipientName': widget.recipientName,
            'recipientType': 'child', // Add recipient type
            'message': messageText,
            'timestamp': FieldValue.serverTimestamp(),
            'isEmergency': false, // Add isEmergency field, default is false
          });

          _messageController.clear(); // Clear the input field after sending
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error sending message: $e'),
              duration: const Duration(seconds: 5),
            ),
          );
        }
        print('Error sending message: $e');
      }
    }
  }

  // Function to display message
  String _getMessageTime(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'Unknown';
    }
    DateTime messageTime = timestamp.toDate();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate =
    DateTime(messageTime.year, messageTime.month, messageTime.day);

    if (messageDate == today) {
      return DateFormat('h:mm a').format(messageTime); // 1:23 PM
    } else if (messageDate.isAfter(today.subtract(const Duration(days: 7)))) {
      return DateFormat('E').format(messageTime); // Mon, Tue, Wed
    } else {
      return DateFormat('MMM d, y').format(messageTime); // Jan 1, 2023
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Message ${widget.recipientName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Display the chat messages
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('messages')
                      .where('senderId', isEqualTo: _auth.currentUser!.uid)
                      .where('recipientId', isEqualTo: widget.recipientId)
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('Error loading messages'),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final messages = snapshot.data!.docs;

                    if (messages.isEmpty) {
                      return const Center(
                        child: Text('No messages yet. Send a message!'),
                      );
                    }

                    return ListView.builder(
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final data = message.data() as Map<String, dynamic>;
                        final isMe =
                            data['senderId'] == _auth.currentUser!.uid;

                        return _buildMessageBubble(data, isMe);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              // Input field for typing a new message
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _messageController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a message';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        hintText: 'Type your message...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Button to send the message
                  ElevatedButton(
                    onPressed: _sendMessage,
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to build message bubble
  Widget _buildMessageBubble(Map<String, dynamic> data, bool isMe) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[200] : Colors.grey[300],
          borderRadius: BorderRadius.circular(15),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Column(
          crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              data['message'],
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getMessageTime(data['timestamp']),
              style: TextStyle(
                fontSize: 12,
                color: isMe ? Colors.blue[800] : Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

