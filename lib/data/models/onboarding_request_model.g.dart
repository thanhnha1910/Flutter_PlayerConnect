// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OnboardingRequestModel _$OnboardingRequestModelFromJson(
  Map<String, dynamic> json,
) => OnboardingRequestModel(
  sportProfiles: (json['sportProfiles'] as List<dynamic>)
      .map((e) => SportProfileRequest.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$OnboardingRequestModelToJson(
  OnboardingRequestModel instance,
) => <String, dynamic>{
  'sportProfiles': instance.sportProfiles.map((e) => e.toJson()).toList(),
};
