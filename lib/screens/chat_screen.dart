import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../widgets/chat_input.dart';
import '../widgets/task_list.dart';
import '../models/task.dart';
import '../models/message.dart';
import '../widgets/chat_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ApiService _apiService = ApiService();
  final List<Message> _messages = [];
  final List<Task> _tasks = [];
  int _selectedIndex = 0;
  bool _isLoading = false;

  void _handleSubmit(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _messages.add(Message(text: message, isUser: true));
    });

    try {
      final (responseMessage, tasks) =
          await _apiService.sendChatMessage(message);
      setState(() {
        _messages.add(responseMessage);
        if (tasks.isNotEmpty) {
          _tasks.addAll(tasks);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(tasks.length == 1
                  ? 'Task created successfully!'
                  : '${tasks.length} tasks created successfully!'),
              action: SnackBarAction(
                label: 'View Tasks',
                onPressed: () => setState(() => _selectedIndex = 1),
              ),
            ),
          );
          // Automatically switch to tasks tab after a short delay
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() => _selectedIndex = 1);
            }
          });
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _messages.add(Message(
          text: 'Error: ${e.toString()}',
          isUser: false,
        ));
      });
    }
  }

  void _handleTaskUpdated(Task updatedTask) {
    setState(() {
      // Update task in tasks list
      final taskIndex = _tasks.indexWhere(
          (t) => t.title == updatedTask.title && t.note == updatedTask.note);

      if (taskIndex != -1) {
        _tasks[taskIndex] = updatedTask;

        // Only update chat message if the date changed (not for completion toggle)
        if (_tasks[taskIndex].dueDate != updatedTask.dueDate) {
          // Update task in chat messages
          for (int i = 0; i < _messages.length; i++) {
            if (!_messages[i].isUser &&
                _messages[i].text.contains('Task: ${updatedTask.title}')) {
              final newText = _messages[i].text.replaceAll(
                    RegExp(r'Due Date:.*?(?=\n|$)'),
                    'Due Date: ${DateFormat("MMMM d, yyyy, 'at' h:mm a").format(updatedTask.dueDate)}',
                  );
              _messages[i] = Message(text: newText, isUser: false);
              break;
            }
          }
        }
      }
    });
  }

  void _handleTaskDeleted(Task task) {
    setState(() {
      // Remove task from tasks list
      _tasks.removeWhere((t) => t.title == task.title && t.note == task.note);

      // Update chat messages to remove task preview
      for (int i = 0; i < _messages.length; i++) {
        if (!_messages[i].isUser &&
            _messages[i].text.contains('Task: ${task.title}')) {
          // Remove the task preview from the message
          final newText = _messages[i].text.split('Task:')[0].trim();
          if (newText.isNotEmpty) {
            _messages[i] = Message(text: newText, isUser: false);
          } else {
            _messages.removeAt(i);
          }
          break;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task deleted'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat' , style: TextStyle(fontWeight: FontWeight.w600 ),),
        backgroundColor: Color(0xFFFFFFFF),
        
      ),
      backgroundColor: Color(0xFFFFFFFF),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    return ChatMessage(
                      message: _messages[index],
                      onTaskUpdated: _handleTaskUpdated,
                      onTaskDeleted: _handleTaskDeleted,
                    );
                  },
                ),
              ),
              ChatInput(onSubmit: _handleSubmit),
            ],
          ),
          TaskList(
            tasks: _tasks,
            onTaskUpdated: _handleTaskUpdated,
            onTaskDeleted: _handleTaskDeleted,
          ),
          const Center(child: Text('Settings')),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.chat), label: 'Chat'),
          NavigationDestination(icon: Icon(Icons.task), label: 'Tasks'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
