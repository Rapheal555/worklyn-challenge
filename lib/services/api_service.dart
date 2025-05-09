import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../models/task.dart';
import '../models/message.dart';

class ApiService {
  static const String baseUrl = 'https://api.worklyn.com/konsul/assistant.chat';

  Future<(Message, List<Task>)> sendChatMessage(String message) async {
    try {
      developer.log('Sending message: $message');

      final response = await http.put(
        Uri.parse(baseUrl),
        headers: {
          'content-type': 'application/json',
          'X-Enviroment': 'development',
          'cookie':
              'id=bnppbmdhbWJhbmRlIzFVVk46MDcwNDgyM2EtYTcwOS00ZmE4LTk5ZWItMWQ3ODk5NDk4MzJl'
        },
        body: jsonEncode({
          "message": message,
          "source": {"id": "1", "deviceId": 1},
        }),
      );

      developer.log('Response status: ${response.statusCode}');
      developer.log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          String responseMessage;

          if (data is String) {
            responseMessage = data;
          } else if (data is Map<String, dynamic>) {
            if (data.containsKey('message')) {
              responseMessage = data['message'] as String? ?? 'No response';
            } else if (data.containsKey('response')) {
              responseMessage = data['response'] as String? ?? 'No response';
            } else {
              responseMessage = json.encode(data);
            }
          } else {
            responseMessage = data.toString();
          }

          developer.log('Parsed message: $responseMessage');

          // Try to parse multiple tasks first
          List<Task> tasks = [];
          if (responseMessage.contains('Your tasks have been created:') ||
              responseMessage.contains(
                  'If you’d like to update, delete, or add details to any of these tasks, just let me know!')) {
            tasks = Task.parseManyFromResponseString(responseMessage);
          }
          // If no multiple tasks found, try single task format
          else if (responseMessage.contains('Task:') &&
              responseMessage.contains('Note:') &&
              responseMessage.contains('Due Date:')) {
            tasks = [Task.fromResponseString(responseMessage)];
          }

          return (Message(text: responseMessage, isUser: false), tasks);
        } catch (e) {
          developer.log('Error parsing response', error: e);
          throw Exception('Failed to parse response: $e');
        }
      } else {
        developer.log('Error: Non-200 status code', error: response.body);
        throw Exception(
            'Server returned ${response.statusCode}: ${response.body}');
      }
    } catch (e, stackTrace) {
      developer.log('Error in sendChatMessage',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
