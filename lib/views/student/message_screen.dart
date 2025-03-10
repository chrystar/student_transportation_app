import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controllers/auth_controller.dart';
import '../../models/message_model.dart';
import '../../repositories/message_repository.dart';

class StudentMessageScreen extends StatelessWidget {
  const StudentMessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MessageScreen();
  }
}

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = AuthController();
  final TextEditingController _messageController = TextEditingController();
  final MessageRepository _messageRepository = MessageRepository();
  late Stream<List<MessageModel>> _messagesStream;
  bool _isEmergency = false;
  String _selectedRecipient = 'admin'; // Default recipient

  @override
  void initState() {
    super.initState();
    _initializeMessageStream();
  }

  void _initializeMessageStream() {
    final userId = _authController.currentUser?.uid;
    if (userId != null) {
      _messagesStream = _messageRepository.getStudentMessages(userId);
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    try {
      final userId = _authController.currentUser?.uid;
      if (userId == null) return;

      // Get student data to include name in the message
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final studentName = userDoc.get('name') ?? 'Unknown Student';

      await _messageRepository.sendMessage(
        MessageModel(
          studentId: userId,
          studentName: studentName,
          message: _messageController.text.trim(),
          timestamp: DateTime.now(),
          isEmergency: _isEmergency,
          recipientType: _selectedRecipient,
          status: MessageStatus.sent,
          read: false,
        ),
      );

      if (mounted) {
        _messageController.clear();
        setState(() {
          _isEmergency = false;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message sent successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending message: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Message List
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _messagesStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data ?? [];
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return MessageBubble(message: message);
                  },
                );
              },
            ),
          ),

          // Message Input Section
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, -2),
                  blurRadius: 4,
                  color: Colors.black,
                ),
              ],
            ),
            child: Column(
              children: [
                // Recipient and Emergency Toggle Row
                Row(
                  children: [
                    // Recipient Dropdown
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedRecipient,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(
                            value: 'admin',
                            child: Text('Admin'),
                          ),
                          DropdownMenuItem(
                            value: 'parent',
                            child: Text('Parent'),
                          ),
                        ],
                        onChanged: (String? value) {
                          if (value != null) {
                            setState(() {
                              _selectedRecipient = value;
                            });
                          }
                        },
                      ),
                    ),
                    // Emergency Toggle
                    Row(
                      children: [
                        const Text('Emergency'),
                        Switch(
                          value: _isEmergency,
                          onChanged: (value) {
                            setState(() {
                              _isEmergency = value;
                            });
                          },
                          activeColor: Colors.red,
                        ),
                      ],
                    ),
                  ],
                ),
                // Message Input Row
                Row(
                  children: [
                    // Text Field
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Type your message...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                      ),
                    ),
                    // Send Button
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _sendMessage,
                      icon: const Icon(Icons.send),
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

class MessageBubble extends StatelessWidget {
  final MessageModel message;

  const MessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Card(
        color: message.isEmergency ? Colors.red.shade100 : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    message.isEmergency ? Icons.warning : Icons.message,
                    color: message.isEmergency ? Colors.red : null,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'To: ${message.recipientType.toUpperCase()}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(
                    message.formattedTime,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(message.message),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    message.status == MessageStatus.sent
                        ? Icons.check
                        : message.status == MessageStatus.delivered
                            ? Icons.done_all
                            : Icons.check_circle,
                    size: 16,
                    color: message.status == MessageStatus.read
                        ? Colors.blue
                        : Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
