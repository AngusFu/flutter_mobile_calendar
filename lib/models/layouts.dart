import 'package:json_annotation/json_annotation.dart';

part 'layouts.g.dart';

@JsonSerializable()
class LayoutGroup {
  LayoutGroup({
    required this.items,
    required this.columnCount,
    required this.start,
    required this.end,
  });

  final List<Item>? items;
  final num? columnCount;
  final num? start;
  final num? end;

  factory LayoutGroup.fromJson(Map<String, dynamic> json) =>
      _$LayoutGroupFromJson(json);

  Map<String, dynamic> toJson() => _$LayoutGroupToJson(this);
}

@JsonSerializable()
class Item {
  Item({
    required this.event,
    required this.column,
    required this.top,
    required this.height,
    required this.bottom,
  });

  final Event? event;
  final num? column;
  final num? top;
  final num? height;
  final num? bottom;

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);

  Map<String, dynamic> toJson() => _$ItemToJson(this);
}

@JsonSerializable()
class Event {
  Event({
    required this.id,
    required this.start,
    required this.end,
  });

  final String? id;
  final num? start;
  final num? end;

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

  Map<String, dynamic> toJson() => _$EventToJson(this);
}
