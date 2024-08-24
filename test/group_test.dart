import 'package:flutter_mobile_calendar/events/group.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Event', () {
    test('should create an event with correct properties', () {
      final event = Event(10.0, 20.0, 'event1');
      expect(event.start, 10.0);
      expect(event.end, 20.0);
      expect(event.id, 'event1');
    });
  });

  group('Group', () {
    test('should add an event to the group', () {
      final group = Group();
      final event = Event(10.0, 20.0, 'event1');
      group.add(event);

      expect(group.columnsOfEvents.length, 1);
      expect(group.columnsOfEvents[0].length, 1);
      expect(group.columnsOfEvents[0][0], event);
    });

    test('should handle overlapping events', () {
      final group = Group();
      final event1 = Event(10.0, 20.0, 'event1');
      final event2 = Event(15.0, 25.0, 'event2');
      group.add(event1);
      group.add(event2);

      expect(group.columnsOfEvents.length, 2);
      expect(group.columnsOfEvents[0].length, 1);
    });

    test('should handle non-overlapping events', () {
      final group = Group();
      final event1 = Event(10.0, 20.0, 'event1');
      final event2 = Event(30.0, 40.0, 'event2');
      group.add(event1);
      group.add(event2);

      expect(group.columnsOfEvents.length, 1);
      expect(group.columnsOfEvents[0].length, 2);
    });
  });

  group('mergeEvents', () {
    test('should merge overlapping events into a single group', () {
      final events = [
        Event(10.0, 20.0, 'event1'),
        Event(15.0, 25.0, 'event2'),
        Event(30.0, 40.0, 'event3'),
      ];
      final groups = mergeEvents(events);

      expect(groups.length, 2);
      expect(groups[0].columnsOfEvents.length, 2);
      expect(groups[0].columnsOfEvents[0].length, 1);
      expect(groups[1].columnsOfEvents.length, 1);
      expect(groups[1].columnsOfEvents[0].length, 1);
    });

    test('should handle non-overlapping events', () {
      final events = [
        Event(10.0, 20.0, 'event1'),
        Event(30.0, 40.0, 'event2'),
      ];
      final groups = mergeEvents(events);

      expect(groups.length, 2);
      expect(groups[0].columnsOfEvents.length, 1);
      expect(groups[0].columnsOfEvents[0].length, 1);
      expect(groups[1].columnsOfEvents.length, 1);
      expect(groups[1].columnsOfEvents[0].length, 1);
    });
  });

  group('processEvents', () {
    test('should process events and return layout groups', () {
      final events = [
        Event(10.0, 20.0, 'event1'),
        Event(15.0, 25.0, 'event2'),
        Event(30.0, 40.0, 'event3'),
      ];
      final layoutGroups = processEvents(events);

      expect(layoutGroups.length, 2);
      expect(layoutGroups[0].items.length, 2);
      expect(layoutGroups[1].items.length, 1);
    });

    test('should generate columns as less as possible', () {
      final events = [
        Event(10.0, 20.0, 'event1'),
        Event(15.0, 30.0, 'event2'),
        Event(25.0, 40.0, 'event3'),
      ];
      final layoutGroups = processEvents(events);

      expect(layoutGroups.length, 1);
      expect(layoutGroups[0].items.length, 3);
    });
  });
}
