import 'package:flutter/material.dart';
import '../models/task.dart';
import 'task_preview.dart';

class TaskList extends StatelessWidget {
  final List<Task> tasks;
  final Function(Task)? onTaskUpdated;
  final Function(Task)? onTaskDeleted;

  const TaskList({
    super.key,
    required this.tasks,
    this.onTaskUpdated,
    this.onTaskDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasks.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: TaskPreview(
            task: task,
            onTaskUpdated: onTaskUpdated,
            onTaskDeleted: onTaskDeleted,
          ),
        );
      },
    );
  }
}
