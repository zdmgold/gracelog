import 'package:flutter_test/flutter_test.dart';
import 'package:gracelog/platform/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(tz_data.initializeTimeZones);

  group('NotificationService.pickLocationFor', () {
    test('matches the offset of the moment it is given', () {
      final now = DateTime.now();
      final location = NotificationService.pickLocationFor(now);

      expect(location, isNotNull);
      expect(tz.TZDateTime.from(now, location!).timeZoneOffset, now.timeZoneOffset);
    });

    test('picks a UK zone for a UTC+1 / BST moment', () {
      // Only meaningful when the machine itself is on UK time; elsewhere the
      // offset check above already covers the behaviour.
      final now = DateTime.now();
      if (now.timeZoneName != 'BST') return;

      final location = NotificationService.pickLocationFor(now)!;
      expect(location.name, anyOf('Europe/London', 'Europe/Belfast', 'GB', 'GB-Eire'));
    });
  });
}
