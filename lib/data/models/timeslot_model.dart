import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'timeslot_model.g.dart';

@JsonSerializable()
class TimeSlot extends Equatable {
  final DateTime startTime;
  final DateTime endTime;

  const TimeSlot({
    required this.startTime,
    required this.endTime,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) =>
      _$TimeSlotFromJson(json);

  Map<String, dynamic> toJson() => _$TimeSlotToJson(this);

  @override
  List<Object?> get props => [startTime, endTime];
}
