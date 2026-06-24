import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/task_model.dart';

class DeepLinkHandler {
  static Future<void> launch(BuildContext context, Task task) async {
    final uri = switch (task.type) {
      TaskType.call => Uri(scheme: 'tel', path: task.contactValue ?? ''),
      TaskType.email => Uri(
          scheme: 'mailto',
          path: task.contactValue ?? '',
          queryParameters: {'subject': task.title},
        ),
      TaskType.sms => Uri(scheme: 'sms', path: task.contactValue ?? ''),
      TaskType.calendar => Uri(
          scheme: 'content',
          host: '',
          path: '/com.android.calendar',
        ),
      TaskType.general => Uri(path: ''),
    };

    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open target app.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error launching task: $e')),
        );
      }
    }
  }
}
