import 'package:flutter/material.dart';
import '../models/message.dart';
import '../models/task.dart';
import 'task_preview.dart';

class ChatMessage extends StatelessWidget {
  final Message message;
  final Function(Task)? onTaskUpdated;
  final Function(Task)? onTaskDeleted;

  const ChatMessage({
    super.key,
    required this.message,
    this.onTaskUpdated,
    this.onTaskDeleted,
  });

  List<Task> _parseTasksFromMessage(String text) {
    if (text.contains('Your tasks have been created:') ||
        text.contains(
            'If you’d like to update, delete, or add details to any of these tasks, just let me know!')) {
      return Task.parseManyFromResponseString(text);
    } else if (text.contains('Task:') &&
        text.contains('Note:') &&
        text.contains('Due Date:')) {
      try {
        return [Task.fromResponseString(text)];
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final tasks = _parseTasksFromMessage(message.text);

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: message.isUser
              ? Theme.of(context).primaryColor
              : tasks.isNotEmpty
                  ? Colors.white
                  : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (tasks.isEmpty)
              Container(
                constraints: const BoxConstraints(maxWidth: 280),
                child: Text(
                  message.text,
                  style: TextStyle(
                    color: message.isUser ? Colors.white : Colors.black87,
                    fontSize: 15,
                  ),
                ),
              )
            else ...[
              Container(
                constraints: const BoxConstraints(maxWidth: 280),
                child: Text(
                  message.text.split('\n\n')[0], // Show only the first line
                  style: TextStyle(
                    color: message.isUser ? Colors.white : Colors.black87,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...tasks.map((task) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: TaskPreview(
                      task: task,
                      inChat: true,
                      onTaskUpdated: onTaskUpdated,
                      onTaskDeleted: onTaskDeleted,
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}
