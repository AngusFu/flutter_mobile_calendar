import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobile_calendar/events/group.dart';
import 'package:flutter_mobile_calendar/events/layout.dart';
import 'package:flutter_mobile_calendar/events/render.dart';

import 'package:flutter_mobile_calendar/grid_column.dart';
import 'package:flutter_mobile_calendar/infinite_list_view.dart';
import 'package:flutter_mobile_calendar/utils/lunar.dart';
import 'package:flutter_mobile_calendar/scroll_controller/linked_scroll_controller.dart';

import 'package:linked_scroll_controller/linked_scroll_controller.dart';

class NoThumbScrollBehavior extends ScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
      };
}

class CalendarThreeDayViewApp extends StatelessWidget {
  const CalendarThreeDayViewApp({super.key});

  @override
  Widget build(BuildContext context) {
    // final viewId = View.of(context).viewId;
    // final initialData = ui_web.views.getInitialData(viewId);

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        scrollBehavior: NoThumbScrollBehavior().copyWith(scrollbars: false),
        home: const Scaffold(
            backgroundColor: Colors.white, body: ThreeDayView()));
  }
}

class ThreeDayView extends StatefulWidget {
  const ThreeDayView({
    super.key,
  });

  @override
  ThreeDayViewState createState() => ThreeDayViewState();
}

enum ScrollAxis { horizontal, vertical }

class ThreeDayViewState extends State<ThreeDayView> {
  final DateTime today = DateTime.now();

  int? currentIndex;
  ScrollAxis? scrollAxis = ScrollAxis.horizontal;

  double _columnWidth = 0.0;

  late LinkedScrollControllerGroup _verticalScrollControllers;
  late ScrollController _mainVerticalScroller;
  late ScrollController _timelineVerticalScroller;

  late FixedExtentInfiniteListViewLinkedScrollControllerGroup
      _infiniteListControllers;
  late FixedExtentInfiniteScrollController _datesListController;
  late FixedExtentInfiniteScrollController _eventsListController;

  @override
  void initState() {
    super.initState();
    currentIndex = 0;

    _verticalScrollControllers = LinkedScrollControllerGroup();
    _mainVerticalScroller = _verticalScrollControllers.addAndGet();
    _timelineVerticalScroller = _verticalScrollControllers.addAndGet();

    _infiniteListControllers =
        FixedExtentInfiniteListViewLinkedScrollControllerGroup();
    _datesListController = _infiniteListControllers.addAndGet();
    _eventsListController = _infiniteListControllers.addAndGet();
  }

  @override
  void dispose() {
    super.dispose();
    _infiniteListControllers.dispose();

    _timelineVerticalScroller.dispose();
    _mainVerticalScroller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 47,
          child: _buildTimeline(),
        ),
        Expanded(child: _buildMain())
      ],
    );
  }

  Widget _buildTimeline() {
    return CustomScrollView(
      controller: _timelineVerticalScroller,
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: SliverHeaderDelegate.fixedHeight(
            height: 80,
            forceRebuild: false,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xffffffff),
                boxShadow: [
                  BoxShadow(
                    // 0px 4px 8px 0px rgba(0,0,0,0.04)
                    color: Colors.black.withOpacity(0.04),
                    spreadRadius: 0,
                    blurRadius: 8,
                    offset: const Offset(0, 4), // 阴影位置
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverFixedExtentList.builder(
          itemExtent: 1360 / 25,
          itemCount: 25,
          itemBuilder: (context, index) {
            return FractionalTranslation(
              translation: const Offset(0, -.5),
              child: Center(
                child: index > 0
                    ? Text(
                        "${index.toString().padLeft(2, '0')}:00",
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color.fromRGBO(0, 0, 0, 0.54),
                        ),
                      )
                    : null,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMain() {
    var itemWidth = (MediaQuery.of(context).size.width - 47) / 3;
    var shouldRebuild = _columnWidth != itemWidth;
    if (_columnWidth != itemWidth) {
      _columnWidth = itemWidth;
    }

    return CustomScrollView(
      controller: _mainVerticalScroller,
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: SliverHeaderDelegate.fixedHeight(
            height: 80,
            forceRebuild: shouldRebuild,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xffffffff),
                boxShadow: [
                  BoxShadow(
                    // 0px 4px 8px 0px rgba(0,0,0,0.04)
                    color: Colors.black.withOpacity(0.04),
                    spreadRadius: 0,
                    blurRadius: 8,
                    offset: const Offset(0, 4), // 阴影位置
                  ),
                ],
              ),
              child: _buildDatesScrollView(),
            ),
          ),
        ),
        SliverFixedExtentList(
          itemExtent: 1360,
          delegate: SliverChildListDelegate([
            Container(
              height: 1360,
              color: Colors.white,
              child: _buildEventColumn(),
            ),
          ]),
        ),
      ],
    );
  }

  Widget _buildDatesScrollView() {
    return InfiniteListView.builder(
      anchor: 0.0,
      physics: scrollAxis == ScrollAxis.vertical
          ? const NeverScrollableScrollPhysics()
          : const FixedExtentInfiniteViewScrollPhysics(),
      cacheExtent: 10,
      itemExtent: _columnWidth,
      scrollDirection: Axis.horizontal,
      controller: _datesListController,
      itemBuilder: (context, index) {
        return SizedBox(
            width: _columnWidth,
            height: 80,
            child: DateCell(
                date: today.add(Duration(days: index)),
                active: currentIndex == index));
      },
    );
  }

  Widget _buildEventColumn() {
    return InfiniteListView.builder(
      anchor: 1 / 3,
      physics: const FixedExtentInfiniteViewScrollPhysics(),
      cacheExtent: 10,
      itemExtent: _columnWidth,
      scrollDirection: Axis.horizontal,
      controller: _eventsListController,
      itemBuilder: (context, index) {
        var layouts = getDayEventsLayout(
            width: _columnWidth,
            height: 1360,
            groups: processEvents(DataService.getEventsForDate()));

        return EventsGridPaper(
          color: const Color.fromARGB(255, 60, 138, 62),
          width: _columnWidth,
          height: 1360 / 25,
          // child: const EventsColumn(),
          child: CustomPaint(
            painter: EventPainter(layouts.map((layout) {
              return LayoutInfo(
                  style: layout,
                  typoData: TypoData(
                    text: 'Event',
                    color: layout.color,
                    iconsPath2D: [],
                  ));
            }).toList()),
          ),
        );
      },
    );
  }
}

class DataService {
  static List<Event> getEventsForDate() {
    var listOfEvents = <Event>[];
    var rnd = Random();
    var count = rnd.nextInt(30);
    for (var i = 0; i < count; i++) {
      var start = rnd.nextInt(24 * 60 * 60 * 1000);
      var end = start + 60 * 60 * 1000;
      listOfEvents.add(Event(start.toDouble(), end.toDouble(), i.toString()));
    }
    return listOfEvents;
  }
}

// class EventsColumn extends StatelessWidget {
//   const EventsColumn({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // generate random events
//     var listOfEvents = <Event>[];
//     var rnd = Random();
//     for (var i = 0; i < 10; i++) {
//       // random start and end time
//       var start = rnd.nextInt(24 * 60 * 60 * 1000);
//       var end = start + 60 * 60 * 1000;
//       listOfEvents.add(Event(start.toDouble(), end.toDouble(), i.toString()));
//     }

//     final layouts = getDayEventsLayout(
//         width: 110, height: 1360, groups: processEvents(listOfEvents));

//     return Stack(
//       children: layouts.map((el) {
//         return Positioned(
//           left: el.left,
//           top: el.top,
//           width: el.width,
//           height: el.height,
//           child: Container(
//             width: el.width,
//             height: el.height,
//             decoration: BoxDecoration(
//               color: el.backgroundColor,
//               borderRadius: BorderRadius.circular(el.borderRadius),
//               border: Border(
//                   left: BorderSide(
//                 color: el.borderColor,
//                 width: el.borderLeftWidth,
//                 style: BorderStyle.solid,
//               )),
//             ),
//             child: const Text(''),
//           ),
//         );
//       }).toList(),
//     );
//   }
// }

class DateCell extends StatelessWidget {
  final DateTime date;
  final bool active;

  const DateCell({super.key, required this.date, required this.active});

  @override
  Widget build(BuildContext context) {
    var calendar = CalendarUtils.solar2lunar(date.year, date.month, date.day);
    var descList = [
      calendar["lunarFestival"],
      calendar["Term"],
      calendar["festival"],
      calendar["IDayCn"],
    ];
    descList.removeWhere((element) => element == null);
    dynamic desc = descList.firstOrNull;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("${calendar["ncWeek"]?.toString().replaceAll("星期", "周")}",
            style: const TextStyle(
                fontSize: 12,
                height: 14 / 12,
                color: Color.fromRGBO(0, 0, 0, .62),
                fontWeight: FontWeight.w400)),
        Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            child: Text("${calendar["cDay"]}",
                style: TextStyle(
                    fontSize: 16,
                    height: 24 / 16,
                    color: const Color.fromRGBO(32, 32, 32, 1),
                    fontWeight: active ? FontWeight.bold : FontWeight.normal))),
        Text("$desc",
            style: const TextStyle(
                fontSize: 12,
                height: 1.5,
                color: Color.fromRGBO(150, 150, 150, 1),
                fontWeight: FontWeight.w400)),
      ],
    );
  }
}

typedef SliverHeaderBuilder = Widget Function(
    BuildContext context, double shrinkOffset, bool overlapsContent);

class SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  // child 为 header
  SliverHeaderDelegate({
    required this.maxHeight,
    this.minHeight = 0,
    this.forceRebuild = false,
    required Widget child,
  })  : builder = ((a, b, c) => child),
        assert(minHeight <= maxHeight && minHeight >= 0);

  //最大和最小高度相同
  SliverHeaderDelegate.fixedHeight({
    required double height,
    required Widget child,
    this.forceRebuild = false,
  })  : maxHeight = height,
        minHeight = height,
        builder = ((a, b, c) => child);

  //需要自定义builder时使用
  SliverHeaderDelegate.builder({
    required this.maxHeight,
    this.minHeight = 0,
    this.forceRebuild = false,
    required this.builder,
  });

  bool forceRebuild = false;
  final double maxHeight;
  final double minHeight;
  final SliverHeaderBuilder builder;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    Widget child = builder(context, shrinkOffset, overlapsContent);
    //测试代码：如果在调试模式，且子组件设置了key，则打印日志
    assert(() {
      if (child.key != null) {
        if (kDebugMode) {
          print(
              '${child.key}: shrink: $shrinkOffset, overlaps:$overlapsContent');
        }
      }
      return true;
    }());
    // 让 header 尽可能充满限制的空间；宽度为 Viewport 宽度，
    // 高度随着用户滑动在[minHeight,maxHeight]之间变化。
    return SizedBox.expand(
      child: child,
    );
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(SliverHeaderDelegate oldDelegate) {
    return oldDelegate.forceRebuild ||
        oldDelegate.maxExtent != maxExtent ||
        oldDelegate.minExtent != minExtent;
  }
}
