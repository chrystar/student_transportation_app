import 'package:flutter/material.dart';
import '../shared/message_screen.dart';

class ParentMessageScreen extends StatelessWidget {
  const ParentMessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MessageScreen(userRole: 'parent');
  }
}
