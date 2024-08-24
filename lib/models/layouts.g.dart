// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'layouts.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LayoutGroup _$LayoutGroupFromJson(Map<String, dynamic> json) => LayoutGroup(
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => Item.fromJson(e as Map<String, dynamic>))
          .toList(),
      columnCount: json['columnCount'] as num?,
      start: json['start'] as num?,
      end: json['end'] as num?,
    );

Map<String, dynamic> _$LayoutGroupToJson(LayoutGroup instance) =>
    <String, dynamic>{
      'items': instance.items,
      'columnCount': instance.columnCount,
      'start': instance.start,
      'end': instance.end,
    };

Item _$ItemFromJson(Map<String, dynamic> json) => Item(
      event: json['event'] == null
          ? null
          : Event.fromJson(json['event'] as Map<String, dynamic>),
      column: json['column'] as num?,
      top: json['top'] as num?,
      height: json['height'] as num?,
      bottom: json['bottom'] as num?,
    );

Map<String, dynamic> _$ItemToJson(Item instance) => <String, dynamic>{
      'event': instance.event,
      'column': instance.column,
      'top': instance.top,
      'height': instance.height,
      'bottom': instance.bottom,
    };

Event _$EventFromJson(Map<String, dynamic> json) => Event(
      id: json['id'] as String?,
      start: json['start'] as num?,
      end: json['end'] as num?,
    );

Map<String, dynamic> _$EventToJson(Event instance) => <String, dynamic>{
      'id': instance.id,
      'start': instance.start,
      'end': instance.end,
    };
