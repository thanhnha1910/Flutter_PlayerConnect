import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'review_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ReviewModel extends Equatable {
  final double rating;
  final String comment;

  const ReviewModel({required this.rating, required this.comment});

  factory ReviewModel.fromJson(Map<String, dynamic> json) => _$ReviewModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewModelToJson(this);

  @override
  List<Object?> get props => [
    rating, comment
  ];

}
