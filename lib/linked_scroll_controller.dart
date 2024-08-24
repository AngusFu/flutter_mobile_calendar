// Copyright 2018 the Dart project authors.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_application_1/infinite_list_view.dart';

/// Sets up a collection of scroll controllers that mirror their movements to
/// each other.
///
/// Controllers are added and returned via [addAndGet]. The initial offset
/// of the newly created controller is synced to the current offset.
/// Controllers must be `dispose`d when no longer in use to prevent memory
/// leaks and performance degradation.
///
/// If controllers are disposed over the course of the lifetime of this
/// object the corresponding scrollables should be given unique keys.
/// Without the keys, Flutter may reuse a controller after it has been disposed,
/// which can cause the controller offsets to fall out of sync.
class FixedExtentInfiniteListViewLinkedScrollControllerGroup {
  FixedExtentInfiniteListViewLinkedScrollControllerGroup() {
    _offsetNotifier =
        _FixedExtentInfiniteListViewLinkedScrollControllerGroupOffsetNotifier(
            this);
  }

  final _allControllers =
      <_FixedExtentInfiniteListViewLinkedScrollController>[];

  late _FixedExtentInfiniteListViewLinkedScrollControllerGroupOffsetNotifier
      _offsetNotifier;

  /// The current scroll offset of the group.
  double get offset {
    assert(
      _attachedControllers.isNotEmpty,
      'FixedExtentInfiniteListViewLinkedScrollControllerGroup does not have any scroll controllers '
      'attached.',
    );
    return _attachedControllers.first.offset;
  }

  /// Creates a new controller that is linked to any existing ones.
  FixedExtentInfiniteScrollController addAndGet() {
    final initialScrollOffset = _attachedControllers.isEmpty
        ? 0.0
        : _attachedControllers.first.position.pixels;
    final controller = _FixedExtentInfiniteListViewLinkedScrollController(this,
        initialScrollOffset: initialScrollOffset);
    _allControllers.add(controller);
    controller.addListener(_offsetNotifier.notifyListeners);
    return controller;
  }

  /// Adds a callback that will be called when the value of [offset] changes.
  void addOffsetChangedListener(VoidCallback onChanged) {
    _offsetNotifier.addListener(onChanged);
  }

  /// Removes the specified offset changed listener.
  void removeOffsetChangedListener(VoidCallback listener) {
    _offsetNotifier.removeListener(listener);
  }

  Iterable<_FixedExtentInfiniteListViewLinkedScrollController>
      get _attachedControllers =>
          _allControllers.where((controller) => controller.hasClients);

  /// Animates the scroll position of all linked controllers to [offset].
  Future<void> animateTo(
    double offset, {
    required Curve curve,
    required Duration duration,
  }) async {
    final animations = <Future<void>>[];
    for (final controller in _attachedControllers) {
      animations
          .add(controller.animateTo(offset, duration: duration, curve: curve));
    }
    return Future.wait<void>(animations).then<void>((List<void> _) => null);
  }

  /// Jumps the scroll position of all linked controllers to [value].
  void jumpTo(double value) {
    for (final controller in _attachedControllers) {
      controller.jumpTo(value);
    }
  }

  int get selectedItem {
    assert(
      _attachedControllers.isNotEmpty,
      'FixedExtentInfiniteListViewLinkedScrollControllerGroup does not have any scroll controllers '
      'attached.',
    );
    return _attachedControllers.first.selectedItem;
  }

  void animateToItem(
    int itemIndex, {
    required Duration duration,
    required Curve curve,
  }) {
    for (final controller in _attachedControllers) {
      controller.animateToItem(itemIndex, duration: duration, curve: curve);
    }
  }

  void jumpToItem(
    int itemIndex,
  ) {
    for (final controller in _attachedControllers) {
      controller.jumpToItem(itemIndex);
    }
  }

  /// Resets the scroll position of all linked controllers to 0.
  void resetScroll() {
    jumpTo(0.0);
  }

  dispose() {
    for (final controller in _attachedControllers) {
      controller.dispose();
    }
  }
}

/// This class provides change notification for [FixedExtentInfiniteListViewLinkedScrollControllerGroup]'s
/// scroll offset.
///
/// This change notifier de-duplicates change events by only firing listeners
/// when the scroll offset of the group has changed.
class _FixedExtentInfiniteListViewLinkedScrollControllerGroupOffsetNotifier
    extends ChangeNotifier {
  _FixedExtentInfiniteListViewLinkedScrollControllerGroupOffsetNotifier(
      this.controllerGroup);

  final FixedExtentInfiniteListViewLinkedScrollControllerGroup controllerGroup;

  /// The cached offset for the group.
  ///
  /// This value will be used in determining whether to notify listeners.
  double? _cachedOffset;

  @override
  void notifyListeners() {
    final currentOffset = controllerGroup.offset;
    if (currentOffset != _cachedOffset) {
      _cachedOffset = currentOffset;
      super.notifyListeners();
    }
  }
}

/// A scroll controller that mirrors its movements to a peer, which must also
/// be a [_FixedExtentInfiniteListViewLinkedScrollController].
class _FixedExtentInfiniteListViewLinkedScrollController
    extends FixedExtentInfiniteScrollController {
  final FixedExtentInfiniteListViewLinkedScrollControllerGroup _controllers;

  _FixedExtentInfiniteListViewLinkedScrollController(this._controllers,
      {required super.initialScrollOffset})
      : super(keepScrollOffset: false);

  @override
  void dispose() {
    _controllers._allControllers.remove(this);
    super.dispose();
  }

  @override
  void attach(ScrollPosition position) {
    assert(
        position is _FixedExtentInfiniteListViewLinkedScrollPosition,
        '_FixedExtentInfiniteListViewLinkedScrollControllers can only be used with'
        ' _FixedExtentInfiniteListViewLinkedScrollPositions.');
    final _FixedExtentInfiniteListViewLinkedScrollPosition linkedPosition =
        position as _FixedExtentInfiniteListViewLinkedScrollPosition;
    assert(linkedPosition.owner == this,
        '_FixedExtentInfiniteListViewLinkedScrollPosition cannot change controllers once created.');
    super.attach(position);
  }

  @override
  _FixedExtentInfiniteListViewLinkedScrollPosition createScrollPosition(
      ScrollPhysics physics,
      ScrollContext context,
      ScrollPosition? oldPosition) {
    return _FixedExtentInfiniteListViewLinkedScrollPosition(
      this,
      physics: physics,
      context: context,
      initialPixels: initialScrollOffset,
      oldPosition: oldPosition,
    );
  }

  @override
  double get initialScrollOffset => _controllers._attachedControllers.isEmpty
      ? super.initialScrollOffset
      : _controllers.offset;

  @override
  _FixedExtentInfiniteListViewLinkedScrollPosition get position =>
      super.position as _FixedExtentInfiniteListViewLinkedScrollPosition;

  Iterable<_FixedExtentInfiniteListViewLinkedScrollController>
      get _allPeersWithClients =>
          _controllers._attachedControllers.where((peer) => peer != this);

  bool get canLinkWithPeers => _allPeersWithClients.isNotEmpty;

  Iterable<_FixedExtentInfiniteListViewLinkedScrollActivity> linkWithPeers(
      _FixedExtentInfiniteListViewLinkedScrollPosition driver) {
    assert(canLinkWithPeers);
    return _allPeersWithClients
        .map((peer) => peer.link(driver))
        .expand((e) => e);
  }

  Iterable<_FixedExtentInfiniteListViewLinkedScrollActivity> link(
      _FixedExtentInfiniteListViewLinkedScrollPosition driver) {
    assert(hasClients);
    final activities = <_FixedExtentInfiniteListViewLinkedScrollActivity>[];
    for (final position in positions) {
      final linkedPosition =
          position as _FixedExtentInfiniteListViewLinkedScrollPosition;
      activities.add(linkedPosition.link(driver));
    }
    return activities;
  }
}

// Implementation details: Whenever position.setPixels or position.forcePixels
// is called on a _FixedExtentInfiniteListViewLinkedScrollPosition (which may happen programmatically, or
// as a result of a user action),  the _FixedExtentInfiniteListViewLinkedScrollPosition creates a
// _FixedExtentInfiniteListViewLinkedScrollActivity for each linked position and uses it to move to or jump
// to the appropriate offset.
//
// When a new activity begins, the set of peer activities is cleared.
class _FixedExtentInfiniteListViewLinkedScrollPosition
    extends FixedExtentInfiniteScrollPosition {
  _FixedExtentInfiniteListViewLinkedScrollPosition(
    this.owner, {
    required super.physics,
    required super.context,
    super.initialPixels = null,
    super.oldPosition,
  });

  final _FixedExtentInfiniteListViewLinkedScrollController owner;

  final Set<_FixedExtentInfiniteListViewLinkedScrollActivity> _peerActivities =
      <_FixedExtentInfiniteListViewLinkedScrollActivity>{};

  // We override hold to propagate it to all peer controllers.
  @override
  ScrollHoldController hold(VoidCallback holdCancelCallback) {
    for (final controller in owner._allPeersWithClients) {
      controller.position._holdInternal();
    }
    return super.hold(holdCancelCallback);
  }

  // Calls hold without propagating to peers.
  void _holdInternal() {
    super.hold(() {});
  }

  @override
  void beginActivity(ScrollActivity? newActivity) {
    if (newActivity == null) {
      return;
    }
    for (var activity in _peerActivities) {
      activity.unlink(this);
    }

    _peerActivities.clear();

    super.beginActivity(newActivity);
  }

  @override
  double setPixels(double newPixels) {
    if (newPixels == pixels) {
      return 0.0;
    }
    updateUserScrollDirection(newPixels - pixels > 0.0
        ? ScrollDirection.forward
        : ScrollDirection.reverse);

    if (owner.canLinkWithPeers) {
      _peerActivities.addAll(owner.linkWithPeers(this));
      for (var activity in _peerActivities) {
        activity.moveTo(newPixels);
      }
    }

    return setPixelsInternal(newPixels);
  }

  double setPixelsInternal(double newPixels) {
    return super.setPixels(newPixels);
  }

  @override
  void forcePixels(double value) {
    if (value == pixels) {
      return;
    }
    updateUserScrollDirection(value - pixels > 0.0
        ? ScrollDirection.forward
        : ScrollDirection.reverse);

    if (owner.canLinkWithPeers) {
      _peerActivities.addAll(owner.linkWithPeers(this));
      for (var activity in _peerActivities) {
        activity.jumpTo(value);
      }
    }

    forcePixelsInternal(value);
  }

  void forcePixelsInternal(double value) {
    super.forcePixels(value);
  }

  _FixedExtentInfiniteListViewLinkedScrollActivity link(
      _FixedExtentInfiniteListViewLinkedScrollPosition driver) {
    if (this.activity is! _FixedExtentInfiniteListViewLinkedScrollActivity) {
      beginActivity(_FixedExtentInfiniteListViewLinkedScrollActivity(this));
    }
    final _FixedExtentInfiniteListViewLinkedScrollActivity activity =
        this.activity as _FixedExtentInfiniteListViewLinkedScrollActivity;
    activity.link(driver);
    return activity;
  }

  void unlink(_FixedExtentInfiniteListViewLinkedScrollActivity activity) {
    _peerActivities.remove(activity);
  }

  // We override this method to make it public (overridden method is protected)
  @override
  void updateUserScrollDirection(ScrollDirection value) {
    super.updateUserScrollDirection(value);
  }

  @override
  void debugFillDescription(List<String> description) {
    super.debugFillDescription(description);
    description.add('owner: $owner');
  }
}

class _FixedExtentInfiniteListViewLinkedScrollActivity extends ScrollActivity {
  _FixedExtentInfiniteListViewLinkedScrollActivity(
      _FixedExtentInfiniteListViewLinkedScrollPosition super.delegate);

  @override
  _FixedExtentInfiniteListViewLinkedScrollPosition get delegate =>
      super.delegate as _FixedExtentInfiniteListViewLinkedScrollPosition;

  final Set<_FixedExtentInfiniteListViewLinkedScrollPosition> drivers =
      <_FixedExtentInfiniteListViewLinkedScrollPosition>{};

  void link(_FixedExtentInfiniteListViewLinkedScrollPosition driver) {
    drivers.add(driver);
  }

  void unlink(_FixedExtentInfiniteListViewLinkedScrollPosition driver) {
    drivers.remove(driver);
    if (drivers.isEmpty) {
      delegate.goIdle();
    }
  }

  @override
  bool get shouldIgnorePointer => true;

  @override
  bool get isScrolling => true;

  // _FixedExtentInfiniteListViewLinkedScrollActivity is not self-driven but moved by calls to the [moveTo]
  // method.
  @override
  double get velocity => 0.0;

  void moveTo(double newPixels) {
    _updateUserScrollDirection();
    delegate.setPixelsInternal(newPixels);
  }

  void jumpTo(double newPixels) {
    _updateUserScrollDirection();
    delegate.forcePixelsInternal(newPixels);
  }

  void _updateUserScrollDirection() {
    assert(drivers.isNotEmpty);
    ScrollDirection commonDirection = drivers.first.userScrollDirection;
    for (var driver in drivers) {
      if (driver.userScrollDirection != commonDirection) {
        commonDirection = ScrollDirection.idle;
      }
    }
    delegate.updateUserScrollDirection(commonDirection);
  }

  @override
  void dispose() {
    for (var driver in drivers) {
      driver.unlink(this);
    }
    super.dispose();
  }
}
