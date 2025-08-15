import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'review_user_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ReviewUserModel extends Equatable {
  final String username;
  final String profilePicture;

  const ReviewUserModel({required this.username, required this.profilePicture});

  factory ReviewUserModel.fromJson(Map<String, dynamic> json) => _$ReviewUserModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewUserModelToJson(this);

  @override
  List<Object?> get props => [
    username, profilePicture
  ];
}