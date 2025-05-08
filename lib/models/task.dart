import 'package:intl/intl.dart';

class Task {
  final String title;
  final String note;
  final DateTime dueDate;
  final String? url;
  final bool isCompleted;

  Task({
    required this.title,
    required this.note,
    required this.dueDate,
    this.url,
    this.isCompleted = false,
  });

  Task copyWith({
    String? title,
    String? note,
    DateTime? dueDate,
    String? url,
    bool? isCompleted,
  }) {
    return Task(
      title: title ?? this.title,
      note: note ?? this.note,
      dueDate: dueDate ?? this.dueDate,
      url: url ?? this.url,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'] ?? '',
      note: json['note'] ?? '',
      dueDate:
          DateTime.parse(json['dueDate'] ?? DateTime.now().toIso8601String()),
      url: json['url'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  factory Task.fromResponseString(String response) {
    String title = '';
    String note = '';
    DateTime? dueDate;
    String? url;

    final lines = response.split('\n');
    for (final line in lines) {
      if (line.startsWith('Task:')) {
        title = line.substring(5).trim();
      } else if (line.startsWith('Note:')) {
        note = line.substring(5).trim();
      } else if (line.contains('Due Date:')) {
        String dateStr = line.substring(line.indexOf(':') + 1).trim();
        try {
          final dateFormat = DateFormat("MMMM d, yyyy, 'at' h:mm a");
          dueDate = dateFormat.parse(dateStr);
        } catch (e) {
          print('Error parsing date: $e');
          print('Date string was: $dateStr');
          dueDate = DateTime.now();
        }
      } else if (line.contains('https://')) {
        url = line.substring(line.indexOf('https://')).trim();
      }
    }

    print('Parsed task: title=$title, note=$note, dueDate=$dueDate, url=$url');

    if (title.isEmpty) {
      throw FormatException('No task title found in response');
    }

    return Task(
      title: title,
      note: note,
      dueDate: dueDate ?? DateTime.now(),
      url: url,
      isCompleted: false,
    );
  }

  static List<Task> parseManyFromResponseString(String response) {
    List<Task> tasks = [];

    // Split response into individual task blocks
    final taskBlocks = response
        .split('\n\n')
        .where((block) => block.trim().startsWith(RegExp(r'\d+\.')))
        .toList();

    for (final block in taskBlocks) {
      try {
        String title = '';
        String note = '';
        DateTime? dueDate;
        String? url;

        final lines = block.split('\n');
        for (final line in lines) {
          if (line.startsWith(RegExp(r'\d+\.'))) {
            title = line.replaceFirst(RegExp(r'\d+\.\s*'), '').trim();
          } else if (line.trim().startsWith('Note:')) {
            note = line.substring(line.indexOf(':') + 1).trim();
          } else if (line.trim().startsWith('Due Date:')) {
            String dateStr = line.substring(line.indexOf(':') + 1).trim();
            try {
              final dateFormat = DateFormat("MMMM d, yyyy, 'at' h:mm a");
              dueDate = dateFormat.parse(dateStr);
            } catch (e) {
              print('Error parsing date: $e');
              print('Date string was: $dateStr');
              dueDate = DateTime.now();
            }
          }
        }

        if (title.isNotEmpty) {
          tasks.add(Task(
            title: title,
            note: note,
            dueDate: dueDate ?? DateTime.now(),
            url: url,
            isCompleted: false,
          ));
        }
      } catch (e) {
        print('Error parsing task block: $e');
        continue;
      }
    }

    // Extract URL from the last part of the message if present
    final urlMatch = RegExp(r'https://[^\s\n]+').firstMatch(response);
    if (urlMatch != null && tasks.isNotEmpty) {
      final url = urlMatch.group(0);
      // Add URL to all tasks
      tasks = tasks.map((task) => task.copyWith(url: url)).toList();
    }

    return tasks;
  }
}
