import 'package:flutter_test/flutter_test.dart';
import 'package:goingtodoit_app/core/task_model.dart';
import 'package:goingtodoit_app/features/deep_links/deep_link_handler.dart';

Task _task(TaskType type, {String? contact, String title = 'Do the thing'}) =>
    Task(
      id: 't1',
      title: title,
      type: type,
      contactValue: contact,
      dueDate: DateTime(2030, 1, 1),
    );

void main() {
  group('DeepLinkHandler.buildUri', () {
    test('call builds a tel: URI', () {
      final uri =
          DeepLinkHandler.buildUri(_task(TaskType.call, contact: '+15551234'))!;
      expect(uri.scheme, 'tel');
      expect(uri.path, '+15551234');
    });

    test('sms builds an sms: URI', () {
      final uri =
          DeepLinkHandler.buildUri(_task(TaskType.sms, contact: '5550000'))!;
      expect(uri.scheme, 'sms');
      expect(uri.path, '5550000');
    });

    test('email builds a mailto: URI with subject', () {
      final uri = DeepLinkHandler.buildUri(
        _task(TaskType.email, contact: 'a@b.com', title: 'Hello there'),
      )!;
      expect(uri.scheme, 'mailto');
      expect(uri.path, 'a@b.com');
      expect(uri.queryParameters['subject'], 'Hello there');
    });

    test('missing contact does not throw and yields empty path', () {
      final uri = DeepLinkHandler.buildUri(_task(TaskType.call))!;
      expect(uri.scheme, 'tel');
      expect(uri.path, '');
    });

    test('calendar builds a Google Calendar template URL', () {
      final task = _task(TaskType.calendar, title: 'Plan trip');
      final uri = DeepLinkHandler.buildUri(task)!;
      expect(uri.scheme, 'https');
      expect(uri.host, 'calendar.google.com');
      expect(uri.queryParameters['action'], 'TEMPLATE');
      expect(uri.queryParameters['text'], 'Plan trip');
      // dates = <start>/<end>, one hour apart, starting at the due date.
      expect(uri.queryParameters['dates'], '20300101T000000/20300101T010000');
    });

    test('general task has no external deep-link target', () {
      expect(DeepLinkHandler.buildUri(_task(TaskType.general)), isNull);
    });
  });
}
