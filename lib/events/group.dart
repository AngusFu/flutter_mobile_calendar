class BaseRange {
  double start;
  double end;

  BaseRange(this.start, this.end);
}

class Event extends BaseRange {
  final String id;

  Event(super.start, super.end, this.id);
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
}

class Group extends BaseRange {
  List<List<Event>> columnsOfEvents;
  List<Map<String, int>> unusedRects;

  Group()
      : columnsOfEvents = [],
        unusedRects = [],
        super(double.infinity, double.negativeInfinity);

  void add(Event event) {
    bool placed = _insert(event, unusedRects);

    if (!placed) {
      double start = this.start < event.start ? this.start : event.start;
      double end = this.end > event.end ? this.end : event.end;
      List<Map<String, int>> emptyRects = _getEmptyRects(start, end);

      if (emptyRects.isNotEmpty && _insert(event, emptyRects)) {
        unusedRects = emptyRects;
      } else {
        columnsOfEvents.add([event]);
      }
    }
    start = start < event.start ? start : event.start;
    end = end > event.end ? end : event.end;
  }

  bool _insert(Event event, List<Map<String, int>> emptyRects) {
    bool placed = false;
    for (int i = 0; i < emptyRects.length; i++) {
      var rect = emptyRects[i];
      if (event.start >= rect['start']! && event.end <= rect['end']!) {
        columnsOfEvents[rect['columnIndex']!].add(event);
        placed = true;
        if (event.start == rect['start'] && event.end == rect['end']) {
          emptyRects.removeAt(i);
        } else if (event.start == rect['start']) {
          emptyRects[i]['start'] = event.end.toInt();
        } else if (event.end == rect['end']) {
          emptyRects[i]['end'] = event.start.toInt();
        } else {
          emptyRects.replaceRange(
            i,
            i + 1,
            [
              {
                'start': rect['start']!,
                'end': event.start.toInt(),
                'columnIndex': rect['columnIndex']!
              },
              {
                'start': event.end.toInt(),
                'end': rect['end']!,
                'columnIndex': rect['columnIndex']!
              }
            ],
          );
        }
        break;
      }
    }
    return placed;
  }

  List<Map<String, int>> _getEmptyRects(double start, double end) {
    List<Map<String, int>> emptyRects = [];
    for (int columnIndex = 0;
        columnIndex < columnsOfEvents.length;
        columnIndex++) {
      List<Event> column = columnsOfEvents[columnIndex];
      double lastEnd = start;
      for (Event event in column) {
        if (event.start > lastEnd) {
          emptyRects.add({
            'start': lastEnd.toInt(),
            'end': event.start.toInt(),
            'columnIndex': columnIndex
          });
        }
        lastEnd = lastEnd > event.end ? lastEnd : event.end;
      }
      if (lastEnd < end) {
        emptyRects.add({
          'start': lastEnd.toInt(),
          'end': end.toInt(),
          'columnIndex': columnIndex
        });
      }
    }
    return emptyRects;
  }

  LayoutGroup calcLayout() {
    int columnCount = columnsOfEvents.length;
    double totalHeight = end - start;

    List<EventLayout> items = [];
    for (int i = 0; i < columnsOfEvents.length; i++) {
      List<Event> events = columnsOfEvents[i];
      for (Event el in events) {
        items.add(EventLayout(
          event: el,
          column: i,
          top: (el.start - start) / totalHeight,
          height: (el.end - el.start) / totalHeight,
          bottom: (end - el.end) / totalHeight,
        ));
      }
    }

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
  events.sort((a, b) => a.start.compareTo(b.start) != 0
      ? a.start.compareTo(b.start)
      : b.end.compareTo(a.end));
  return mergeEvents(events).map((group) => group.calcLayout()).toList();
}
