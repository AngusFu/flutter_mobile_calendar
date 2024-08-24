import 'dart:math' as math;

import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Infinite ListView
///
/// ListView that builds its children with to an infinite extent.
///
class InfiniteListView extends StatefulWidget {
  /// See [ListView.builder]
  const InfiniteListView.builder({
    super.key,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    required this.controller,
    this.physics,
    this.padding,
    this.itemExtent,
    required this.itemBuilder,
    this.itemCount,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent,
    this.anchor = 0.0,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
  }) : separatorBuilder = null;

  /// See [ListView.separated]
  const InfiniteListView.separated({
    super.key,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    required this.controller,
    this.physics,
    this.padding,
    required this.itemBuilder,
    required this.separatorBuilder,
    this.itemCount,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent,
    this.anchor = 0.0,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
  }) : itemExtent = null;

  /// See: [ScrollView.scrollDirection]
  final Axis scrollDirection;

  /// See: [ScrollView.reverse]
  final bool reverse;

  /// See: [ScrollView.controller]
  final FixedExtentInfiniteScrollController controller;

  /// See: [ScrollView.physics]
  final ScrollPhysics? physics;

  /// See: [BoxScrollView.padding]
  final EdgeInsets? padding;

  /// See: [ListView.builder]
  final IndexedWidgetBuilder itemBuilder;

  /// See: [ListView.separated]
  final IndexedWidgetBuilder? separatorBuilder;

  /// See: [SliverChildBuilderDelegate.childCount]
  final int? itemCount;

  /// See: [ListView.itemExtent]
  final double? itemExtent;

  /// See: [ScrollView.cacheExtent]
  final double? cacheExtent;

  /// See: [ScrollView.anchor]
  final double anchor;

  /// See: [SliverChildBuilderDelegate.addAutomaticKeepAlives]
  final bool addAutomaticKeepAlives;

  /// See: [SliverChildBuilderDelegate.addRepaintBoundaries]
  final bool addRepaintBoundaries;

  /// See: [SliverChildBuilderDelegate.addSemanticIndexes]
  final bool addSemanticIndexes;

  /// See: [ScrollView.dragStartBehavior]
  final DragStartBehavior dragStartBehavior;

  /// See: [ScrollView.keyboardDismissBehavior]
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// See: [ScrollView.restorationId]
  final String? restorationId;

  /// See: [ScrollView.clipBehavior]
  final Clip clipBehavior;

  @override
  InfiniteListViewState createState() => InfiniteListViewState();
}

class InfiniteListViewState extends State<InfiniteListView> {
  FixedExtentInfiniteScrollController? _controller;

  FixedExtentInfiniteScrollController get _effectiveController =>
      widget.controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> slivers = _buildSlivers(context, negative: false);
    final List<Widget> negativeSlivers = _buildSlivers(context, negative: true);
    final AxisDirection axisDirection = _getDirection(context);
    final scrollPhysics =
        widget.physics ?? const AlwaysScrollableScrollPhysics();
    return FixedExtentScrollable(
      axisDirection: axisDirection,
      controller: _effectiveController,
      physics: scrollPhysics,
      itemExtent: widget.itemExtent ?? 0,
      viewportBuilder: (BuildContext context, ViewportOffset offset) {
        return Builder(builder: (BuildContext context) {
          /// Build negative [ScrollPosition] for the negative scrolling [Viewport].
          final state = Scrollable.of(context);
          final negativeOffset = FixedExtentInfiniteScrollPosition(
            physics: scrollPhysics,
            context: state,
            initialPixels: -offset.pixels,
            keepScrollOffset: _effectiveController.keepScrollOffset,
            negativeScroll: true,
          );

          /// Keep the negative scrolling [Viewport] positioned to the [ScrollPosition].
          offset.addListener(() {
            negativeOffset._forceNegativePixels(offset.pixels);
          });

          /// Stack the two [Viewport]s on top of each other so they move in sync.
          return Stack(
            children: <Widget>[
              Viewport(
                axisDirection: flipAxisDirection(axisDirection),
                anchor: 1.0 - widget.anchor,
                offset: negativeOffset,
                slivers: negativeSlivers,
                cacheExtent: widget.cacheExtent,
              ),
              Viewport(
                axisDirection: axisDirection,
                anchor: widget.anchor,
                offset: offset,
                slivers: slivers,
                cacheExtent: widget.cacheExtent,
              ),
            ],
          );
        });
      },
    );
  }

  AxisDirection _getDirection(BuildContext context) {
    return getAxisDirectionFromAxisReverseAndDirectionality(
        context, widget.scrollDirection, widget.reverse);
  }

  List<Widget> _buildSlivers(BuildContext context, {bool negative = false}) {
    final itemExtent = widget.itemExtent;
    final padding = widget.padding ?? EdgeInsets.zero;
    return <Widget>[
      SliverPadding(
        padding: negative
            ? padding - EdgeInsets.only(bottom: padding.bottom)
            : padding - EdgeInsets.only(top: padding.top),
        sliver: (itemExtent != null)
            ? SliverFixedExtentList(
                delegate: negative
                    ? negativeChildrenDelegate
                    : positiveChildrenDelegate,
                itemExtent: itemExtent,
              )
            : SliverList(
                delegate: negative
                    ? negativeChildrenDelegate
                    : positiveChildrenDelegate,
              ),
      )
    ];
  }

  SliverChildDelegate get negativeChildrenDelegate {
    return SliverChildBuilderDelegate(
      (BuildContext context, int index) {
        final separatorBuilder = widget.separatorBuilder;
        if (separatorBuilder != null) {
          final itemIndex = (-1 - index) ~/ 2;
          return index.isOdd
              ? widget.itemBuilder(context, itemIndex)
              : separatorBuilder(context, itemIndex);
        } else {
          return widget.itemBuilder(context, -1 - index);
        }
      },
      childCount: widget.itemCount,
      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
      addRepaintBoundaries: widget.addRepaintBoundaries,
    );
  }

  SliverChildDelegate get positiveChildrenDelegate {
    final separatorBuilder = widget.separatorBuilder;
    final itemCount = widget.itemCount;
    return SliverChildBuilderDelegate(
      (separatorBuilder != null)
          ? (BuildContext context, int index) {
              final itemIndex = index ~/ 2;
              return index.isEven
                  ? widget.itemBuilder(context, itemIndex)
                  : separatorBuilder(context, itemIndex);
            }
          : widget.itemBuilder,
      childCount: separatorBuilder == null
          ? itemCount
          : (itemCount != null ? math.max(0, itemCount * 2 - 1) : null),
      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
      addRepaintBoundaries: widget.addRepaintBoundaries,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(EnumProperty<Axis>('scrollDirection', widget.scrollDirection));
    properties.add(FlagProperty('reverse',
        value: widget.reverse, ifTrue: 'reversed', showName: true));
    properties.add(DiagnosticsProperty<ScrollController>(
        'controller', widget.controller,
        showName: false, defaultValue: null));
    properties.add(DiagnosticsProperty<ScrollPhysics>('physics', widget.physics,
        showName: false, defaultValue: null));
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry>(
        'padding', widget.padding,
        defaultValue: null));
    properties.add(
        DoubleProperty('itemExtent', widget.itemExtent, defaultValue: null));
    properties.add(
        DoubleProperty('cacheExtent', widget.cacheExtent, defaultValue: null));
  }
}

class FixedExtentScrollable extends Scrollable {
  const FixedExtentScrollable({
    super.key,
    required this.itemExtent,
    required super.viewportBuilder,
    super.axisDirection,
    super.controller,
    super.physics,
  });

  final double itemExtent;

  @override
  FixedExtentScrollableState createState() => FixedExtentScrollableState();
}

/// This [ScrollContext] is used by [FixedExtentInfiniteScrollPosition] to read the
/// prescribed [itemExtent].
class FixedExtentScrollableState extends ScrollableState {
  double get itemExtent {
    // Downcast because only _FixedExtentScrollable can make _FixedExtentScrollableState.
    final FixedExtentScrollable actualWidget = widget as FixedExtentScrollable;
    return actualWidget.itemExtent;
  }
}

/// Metrics for a [ScrollPosition] to a scroll view with fixed item sizes.
///
/// The metrics are available on [ScrollNotification]s generated from a scroll
/// views such as [ListWheelScrollView]s with a [FixedExtentScrollController]
/// and exposes the current [itemIndex] and the scroll view's extents.
///
/// `FixedExtent` refers to the fact that the scrollable items have the same
/// size. This is distinct from `Fixed` in the parent class name's
/// [FixedScrollMetrics] which refers to its immutability.
class FixedExtentMetrics extends FixedScrollMetrics {
  /// Creates an immutable snapshot of values associated with a
  /// [ListWheelScrollView].
  FixedExtentMetrics({
    required super.minScrollExtent,
    required super.maxScrollExtent,
    required super.pixels,
    required super.viewportDimension,
    required super.axisDirection,
    required this.itemIndex,
    required super.devicePixelRatio,
  });

  @override
  FixedExtentMetrics copyWith({
    double? minScrollExtent,
    double? maxScrollExtent,
    double? pixels,
    double? viewportDimension,
    AxisDirection? axisDirection,
    int? itemIndex,
    double? devicePixelRatio,
  }) {
    return FixedExtentMetrics(
      minScrollExtent: minScrollExtent ??
          (hasContentDimensions ? this.minScrollExtent : null),
      maxScrollExtent: maxScrollExtent ??
          (hasContentDimensions ? this.maxScrollExtent : null),
      pixels: pixels ?? (hasPixels ? this.pixels : null),
      viewportDimension: viewportDimension ??
          (hasViewportDimension ? this.viewportDimension : null),
      axisDirection: axisDirection ?? this.axisDirection,
      itemIndex: itemIndex ?? this.itemIndex,
      devicePixelRatio: devicePixelRatio ?? this.devicePixelRatio,
    );
  }

  /// The scroll view's currently selected item index.
  final int itemIndex;
}

/// Same as a [ScrollController] except it provides [ScrollPosition] objects with infinite bounds.
class FixedExtentInfiniteScrollController extends ScrollController {
  /// Creates a new [FixedExtentInfiniteScrollController]
  FixedExtentInfiniteScrollController(
      {super.initialScrollOffset, super.keepScrollOffset, super.debugLabel});

  /// The currently selected item index that's closest to the center of the viewport.
  ///
  /// There are circumstances that this [FixedExtentScrollController] can't know
  /// the current item. Reading [selectedItem] will throw an [AssertionError] in
  /// the following cases:
  ///
  /// 1. No scroll view is currently using this [FixedExtentScrollController].
  /// 2. More than one scroll views using the same [FixedExtentScrollController].
  ///
  /// The [hasClients] property can be used to check if a scroll view is
  /// attached prior to accessing [selectedItem].
  int get selectedItem {
    assert(
      positions.isNotEmpty,
      'FixedExtentScrollController.selectedItem cannot be accessed before a '
      'scroll view is built with it.',
    );
    assert(
      positions.length == 1,
      'The selectedItem property cannot be read when multiple scroll views are '
      'attached to the same FixedExtentScrollController.',
    );
    final FixedExtentInfiniteScrollPosition position = this.position;
    return position.itemIndex;
  }

  /// Animates the controlled scroll view to the given item index.
  ///
  /// The animation lasts for the given duration and follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  Future<void> animateToItem(
    int itemIndex, {
    required Duration duration,
    required Curve curve,
  }) async {
    if (!hasClients) {
      return;
    }

    await Future.wait<void>(<Future<void>>[
      for (final FixedExtentInfiniteScrollPosition position
          in positions.cast<FixedExtentInfiniteScrollPosition>())
        position.animateTo(
          itemIndex * position.itemExtent,
          duration: duration,
          curve: curve,
        ),
    ]);
  }

  /// Changes which item index is centered in the controlled scroll view.
  ///
  /// Jumps the item index position from its current value to the given value,
  /// without animation, and without checking if the new value is in range.
  void jumpToItem(int itemIndex) {
    for (final FixedExtentInfiniteScrollPosition position
        in positions.cast<FixedExtentInfiniteScrollPosition>()) {
      position.jumpTo(itemIndex * position.itemExtent);
    }
  }

  @override
  ScrollPosition createScrollPosition(ScrollPhysics physics,
      ScrollContext context, ScrollPosition? oldPosition) {
    return FixedExtentInfiniteScrollPosition(
      physics: physics,
      context: context,
      initialPixels: initialScrollOffset,
      keepScrollOffset: keepScrollOffset,
      oldPosition: oldPosition,
      debugLabel: debugLabel,
    );
  }

  /// Returns the attached [ScrollPosition], from which the actual scroll offset
  /// of the [ScrollView] can be obtained.
  ///
  /// Calling this is only valid when only a single position is attached.
  @override
  FixedExtentInfiniteScrollPosition get position {
    return super.positions.cast<FixedExtentInfiniteScrollPosition>().single;
  }
}

class FixedExtentInfiniteScrollPosition extends ScrollPositionWithSingleContext
    implements FixedExtentMetrics {
  FixedExtentInfiniteScrollPosition({
    required super.physics,
    required super.context,
    super.initialPixels,
    super.keepScrollOffset,
    super.oldPosition,
    super.debugLabel,
    this.negativeScroll = false,
  });

  final bool negativeScroll;

  void _forceNegativePixels(double value) {
    super.forcePixels(-value);
  }

  @override
  void saveScrollOffset() {
    if (!negativeScroll) {
      super.saveScrollOffset();
    }
  }

  @override
  void restoreScrollOffset() {
    if (!negativeScroll) {
      super.restoreScrollOffset();
    }
  }

  @override
  double get minScrollExtent => double.negativeInfinity;

  @override
  double get maxScrollExtent => double.infinity;

  static double _getItemExtentFromScrollContext(ScrollContext context) {
    final FixedExtentScrollableState scrollable =
        context as FixedExtentScrollableState;
    return scrollable.itemExtent;
  }

  double get itemExtent => _getItemExtentFromScrollContext(context);

  @override
  int get itemIndex {
    return _getItemFromOffset(
      offset: pixels,
      itemExtent: itemExtent,
      minScrollExtent: minScrollExtent,
      maxScrollExtent: maxScrollExtent,
    );
  }

  @override
  FixedExtentMetrics copyWith({
    double? minScrollExtent,
    double? maxScrollExtent,
    double? pixels,
    double? viewportDimension,
    AxisDirection? axisDirection,
    int? itemIndex,
    double? devicePixelRatio,
  }) {
    return FixedExtentMetrics(
      minScrollExtent: minScrollExtent ??
          (hasContentDimensions ? this.minScrollExtent : null),
      maxScrollExtent: maxScrollExtent ??
          (hasContentDimensions ? this.maxScrollExtent : null),
      pixels: pixels ?? (hasPixels ? this.pixels : null),
      viewportDimension: viewportDimension ??
          (hasViewportDimension ? this.viewportDimension : null),
      axisDirection: axisDirection ?? this.axisDirection,
      itemIndex: itemIndex ?? this.itemIndex,
      devicePixelRatio: devicePixelRatio ?? this.devicePixelRatio,
    );
  }
}

int _getItemFromOffset({
  required double offset,
  required double itemExtent,
  required double minScrollExtent,
  required double maxScrollExtent,
}) {
  return (_clipOffsetToScrollableRange(
              offset, minScrollExtent, maxScrollExtent) /
          itemExtent)
      .round();
}

double _clipOffsetToScrollableRange(
  double offset,
  double minScrollExtent,
  double maxScrollExtent,
) {
  return math.min(math.max(offset, minScrollExtent), maxScrollExtent);
}

/// A snapping physics that always lands directly on items instead of anywhere
/// within the scroll extent.
///
/// Behaves similarly to a slot machine wheel except the ballistics simulation
/// never overshoots and rolls back within a single item if it's to settle on
/// that item.
///
/// Must be used with a scrollable that uses a [FixedExtentScrollController].
///
/// Defers back to the parent beyond the scroll extents.
class FixedExtentInfiniteViewScrollPhysics extends ScrollPhysics {
  /// Creates a scroll physics that always lands on items.
  const FixedExtentInfiniteViewScrollPhysics({super.parent});

  @override
  FixedExtentInfiniteViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return FixedExtentInfiniteViewScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    assert(
      position is FixedExtentInfiniteScrollPosition,
      'FixedSizeInfiniteViewScrollPhysics can only be used with Scrollables that uses '
      'the FixedExtentScrollController',
    );

    final FixedExtentInfiniteScrollPosition metrics =
        position as FixedExtentInfiniteScrollPosition;

    // Scenario 1:
    // If we're out of range and not headed back in range, defer to the parent
    // ballistics, which should put us back in range at the scrollable's boundary.
    if ((velocity <= 0.0 && metrics.pixels <= metrics.minScrollExtent) ||
        (velocity >= 0.0 && metrics.pixels >= metrics.maxScrollExtent)) {
      return super.createBallisticSimulation(metrics, velocity);
    }

    // Create a test simulation to see where it would have ballistically fallen
    // naturally without settling onto items.
    final Simulation? testFrictionSimulation =
        super.createBallisticSimulation(metrics, velocity);

    // Scenario 2:
    // If it was going to end up past the scroll extent, defer back to the
    // parent physics' ballistics again which should put us on the scrollable's
    // boundary.
    if (testFrictionSimulation != null &&
        (testFrictionSimulation.x(double.infinity) == metrics.minScrollExtent ||
            testFrictionSimulation.x(double.infinity) ==
                metrics.maxScrollExtent)) {
      return super.createBallisticSimulation(metrics, velocity);
    }

    // From the natural final position, find the nearest item it should have
    // settled to.
    final int settlingItemIndex = _getItemFromOffset(
      offset: testFrictionSimulation?.x(double.infinity) ?? metrics.pixels,
      itemExtent: metrics.itemExtent,
      minScrollExtent: metrics.minScrollExtent,
      maxScrollExtent: metrics.maxScrollExtent,
    );

    final double settlingPixels = settlingItemIndex * metrics.itemExtent;

    // Scenario 3:
    // If there's no velocity and we're already at where we intend to land,
    // do nothing.
    if (velocity.abs() < toleranceFor(position).velocity &&
        (settlingPixels - metrics.pixels).abs() <
            toleranceFor(position).distance) {
      return null;
    }

    // Scenario 4:
    // If we're going to end back at the same item because initial velocity
    // is too low to break past it, use a spring simulation to get back.
    if (settlingItemIndex == metrics.itemIndex) {
      return SpringSimulation(
        spring,
        metrics.pixels,
        settlingPixels,
        velocity,
        tolerance: toleranceFor(position),
      );
    }

    // Scenario 5:
    // Create a new friction simulation except the drag will be tweaked to land
    // exactly on the item closest to the natural stopping point.
    return FrictionSimulation.through(
      metrics.pixels,
      settlingPixels,
      velocity,
      toleranceFor(position).velocity * velocity.sign,
    );
  }
}
