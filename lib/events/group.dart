class BaseRange {
  double start;
  double end;

  BaseRange(this.start, this.end);
}

class Event extends BaseRange {
  final String id;

  Event(super.start, super.end, this.id);

  @override
  String toString() {
    return 'Event{id: $id, start: $start, end: $end}';
  }
}

class EventLayout {
  final double top; // by percent
  final double bottom; // by percent
  final double height; // by percent
  final int column;
  final Event event;

  EventLayout({
    required this.top,
    required this.bottom,
    required this.height,
    required this.column,
    required this.event,
  });
}

class LayoutGroup extends BaseRange {
  final List<EventLayout> items;
  final int columnCount;

  LayoutGroup({
    required double start,
    required double end,
    required this.items,
    required this.columnCount,
  }) : super(start, end);

  @override
  String toString() {
    return 'LayoutGroup{start: $start, end: $end, items: $items, columnCount: $columnCount}';
  }
}

// 定义 Group 类
class Group implements BaseRange {
  @override
  double start = double.infinity;
  @override
  double end = double.negativeInfinity;
  List<List<Event>> columnsOfEvents = [];

  void add(Event event) {
    bool inserted = false;
    for (int i = 0; i < columnsOfEvents.length; i++) {
      List<Event> column = columnsOfEvents[i];
      if (column[column.length - 1].end <= event.start) {
        column.add(event);
        inserted = true;
        break;
      }
    }
    if (!inserted) {
      columnsOfEvents.add([event]);
    }
    start = start < event.start ? start : event.start;
    end = end > event.end ? end : event.end;
  }

  LayoutGroup calcLayout() {
    int columnCount = columnsOfEvents.length;
    num totalHeight = end - start;

    List<EventLayout> items = columnsOfEvents.expand((events) {
      int i = columnsOfEvents.indexOf(events);
      return events.map((el) {
        return EventLayout(
          event: el,
          column: i,
          top: (el.start - start) / totalHeight,
          height: (el.end - el.start) / totalHeight,
          bottom: (end - el.end) / totalHeight,
        );
      });
    }).toList();

    return LayoutGroup(
      start: start,
      end: end,
      items: items,
      columnCount: columnCount,
    );
  }
}

bool isOverlap(BaseRange r1, BaseRange r2) {
  return r1.start < r2.end && r2.start < r1.end;
}

List<Group> mergeEvents(List<Event> events) {
  if (events.isEmpty) return [];

  List<Group> groups = [];
  Group currentGroup = Group();
  currentGroup.add(events[0]);

  for (int i = 1; i < events.length; i++) {
    Event currentEvent = events[i];
    if (isOverlap(currentGroup, currentEvent)) {
      currentGroup.add(currentEvent);
    } else {
      groups.add(currentGroup);
      currentGroup = Group();
      currentGroup.add(currentEvent);
    }
  }

  groups.add(currentGroup);

  return groups;
}

List<LayoutGroup> processEvents(List<Event> events) {
  List<Event> sortedEvents = List.from(events);
  sortedEvents.sort((a, b) => a.start.compareTo(b.start) == 0
      ? b.end.compareTo(a.end)
      : a.start.compareTo(b.start));
  return mergeEvents(sortedEvents).map((group) => group.calcLayout()).toList();
}
