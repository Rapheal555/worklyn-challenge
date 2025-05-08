import 'package:flutter/material.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSubmit;

  const ChatInput({super.key, required this.onSubmit});

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final message = _controller.text.trim();
    if (message.isNotEmpty) {
      widget.onSubmit(message);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      // decoration: BoxDecoration(
      //   color: Theme.of(context).cardColor,
      //   border: Border(
      //     top: BorderSide(color: Theme.of(context).dividerColor),
      //   ),
      // ),
      child: Row(
        children: [
            Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
              filled: true,
              hintText: 'What can I do for you?',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onSubmitted: (_) => _handleSubmit(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(
                Color(0xFF007AFF),
              ),
              // shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              //   RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(20),
              //   ),
              // ),
            ),
            color: Color(0xFFFFFFFF),
            icon: const Icon(Icons.arrow_upward_outlined),
            onPressed: _handleSubmit,
          ),
        ],
      ),
    );
  }
}
