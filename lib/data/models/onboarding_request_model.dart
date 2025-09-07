import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'sport_profile_model.dart';

part 'onboarding_request_model.g.dart';

@JsonSerializable(explicitToJson: true)
class OnboardingRequestModel extends Equatable {
  final List<SportProfileRequest> sportProfiles;

  const OnboardingRequestModel({
    required this.sportProfiles,
  });

  factory OnboardingRequestModel.fromJson(Map<String, dynamic> json) =>
      _$OnboardingRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$OnboardingRequestModelToJson(this);

  OnboardingRequestModel copyWith({
    List<SportProfileRequest>? sportProfiles,
  }) {
    return OnboardingRequestModel(
      sportProfiles: sportProfiles ?? this.sportProfiles,
    );
  }

  @override
  List<Object?> get props => [
        sportProfiles,
      ];
}