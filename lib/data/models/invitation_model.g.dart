// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invitation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InvitationModel _$InvitationModelFromJson(Map<String, dynamic> json) =>
    InvitationModel(
      id: (json['id'] as num).toInt(),
      type: json['type'] as String,
      status: json['status'] as String,
      sender: UserModel.fromJson(json['sender'] as Map<String, dynamic>),
      receiver: json['receiver'] == null
          ? null
          : UserModel.fromJson(json['receiver'] as Map<String, dynamic>),
      team: json['team'] == null
          ? null
          : TeamModel.fromJson(json['team'] as Map<String, dynamic>),
      draftMatch: json['draftMatch'] == null
          ? null
          : DraftMatchModel.fromJson(
              json['draftMatch'] as Map<String, dynamic>,
            ),
      message: json['message'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      respondedAt: json['respondedAt'] == null
          ? null
          : DateTime.parse(json['respondedAt'] as String),
    );

Map<String, dynamic> _$InvitationModelToJson(InvitationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'status': instance.status,
      'sender': instance.sender,
      'receiver': instance.receiver,
      'team': instance.team,
      'draftMatch': instance.draftMatch,
      'message': instance.message,
      'createdAt': instance.createdAt.toIso8601String(),
      'respondedAt': instance.respondedAt?.toIso8601String(),
    };

InvitationListResponse _$InvitationListResponseFromJson(
  Map<String, dynamic> json,
) => InvitationListResponse(
  invitations: (json['invitations'] as List<dynamic>)
      .map((e) => InvitationModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalElements: (json['totalElements'] as num).toInt(),
  totalPages: (json['totalPages'] as num).toInt(),
  currentPage: (json['currentPage'] as num).toInt(),
);

Map<String, dynamic> _$InvitationListResponseToJson(
  InvitationListResponse instance,
) => <String, dynamic>{
  'invitations': instance.invitations,
  'totalElements': instance.totalElements,
  'totalPages': instance.totalPages,
  'currentPage': instance.currentPage,
};

InvitationActionRequest _$InvitationActionRequestFromJson(
  Map<String, dynamic> json,
) => InvitationActionRequest(
  action: json['action'] as String,
  message: json['message'] as String?,
);

Map<String, dynamic> _$InvitationActionRequestToJson(
  InvitationActionRequest instance,
) => <String, dynamic>{'action': instance.action, 'message': instance.message};

DraftMatchRequestModel _$DraftMatchRequestModelFromJson(
  Map<String, dynamic> json,
) => DraftMatchRequestModel(
  id: (json['id'] as num).toInt(),
  user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
  draftMatch: DraftMatchModel.fromJson(
    json['draftMatch'] as Map<String, dynamic>,
  ),
  status: json['status'] as String,
  message: json['message'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  respondedAt: json['respondedAt'] == null
      ? null
      : DateTime.parse(json['respondedAt'] as String),
);

Map<String, dynamic> _$DraftMatchRequestModelToJson(
  DraftMatchRequestModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'user': instance.user,
  'draftMatch': instance.draftMatch,
  'status': instance.status,
  'message': instance.message,
  'createdAt': instance.createdAt.toIso8601String(),
  'respondedAt': instance.respondedAt?.toIso8601String(),
};

DraftMatchRequestListResponse _$DraftMatchRequestListResponseFromJson(
  Map<String, dynamic> json,
) => DraftMatchRequestListResponse(
  requests: (json['requests'] as List<dynamic>)
      .map((e) => DraftMatchRequestModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalElements: (json['totalElements'] as num).toInt(),
  totalPages: (json['totalPages'] as num).toInt(),
  currentPage: (json['currentPage'] as num).toInt(),
);

Map<String, dynamic> _$DraftMatchRequestListResponseToJson(
  DraftMatchRequestListResponse instance,
) => <String, dynamic>{
  'requests': instance.requests,
  'totalElements': instance.totalElements,
  'totalPages': instance.totalPages,
  'currentPage': instance.currentPage,
};
