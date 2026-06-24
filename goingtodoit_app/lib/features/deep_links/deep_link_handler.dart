import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/task_model.dart';

class DeepLinkHandler {
  /// Builds the deep-link [Uri] for a task, or `null` when the task type has
  /// no external target (e.g. a plain general to-do). Pure and side-effect
  /// free so it can be unit-tested independently of [launchUrl].
  static Uri? buildUri(Task task) {
    return switch (task.type) {
      TaskType.call => Uri(scheme: 'tel', path: task.contactValue ?? ''),
      TaskType.email => Uri(
          scheme: 'mailto',
          path: task.contactValue ?? '',
          queryParameters: {'subject': task.title},
        ),
      TaskType.sms => Uri(scheme: 'sms', path: task.contactValue ?? ''),
      TaskType.calendar => _calendarUri(task),
      TaskType.general => null,
    };
  }

  /// A Google Calendar "create event" template URL with the task title and a
  /// one-hour slot starting at the due date pre-filled. Opens the calendar app
  /// (or web) with the event ready to save — the user still confirms.
  static Uri _calendarUri(Task task) {
    final start = task.dueDate;
    final end = task.dueDate.add(const Duration(hours: 1));
    String stamp(DateTime d) {
      String two(int n) => n.toString().padLeft(2, '0');
      return '${d.year}${two(d.month)}${two(d.day)}'
          'T${two(d.hour)}${two(d.minute)}${two(d.second)}';
    }

    return Uri.parse(
      'https://calendar.google.com/calendar/render?action=TEMPLATE'
      '&text=${Uri.encodeQueryComponent(task.title)}'
      '&dates=${stamp(start)}/${stamp(end)}',
    );
  }

  static Future<void> launch(BuildContext context, Task task) async {
    final uri = buildUri(task);
    if (uri == null) return; // General tasks have no external target.

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
