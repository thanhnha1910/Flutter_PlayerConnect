class UnifiedInvitationModel {
  final int id;
  final int? inviterId;
  final String? inviterName;
  final String? inviterAvatarUrl;
  final int? receiverId;
  final String? receiverName;
  final int? openMatchId;
  final String? openMatchTitle;
  final String? sportType;
  final String? fieldName;
  final String? matchDateTime;
  final String type; // 'invitation', 'request', 'draft_match_request'
  final String status; // 'pending', 'accepted', 'rejected'
  final String? message;
  final DateTime createdAt;
  final DateTime? respondedAt;
  
  // Additional fields for different invitation types
  final int? teamId;
  final String? teamName;
  final int? draftMatchId;
  final String? draftMatchDescription;
  final String? skillLevel;
  final int? slotsNeeded;

  const UnifiedInvitationModel({
    required this.id,
    this.inviterId,
    this.inviterName,
    this.inviterAvatarUrl,
    this.receiverId,
    this.receiverName,
    this.openMatchId,
    this.openMatchTitle,
    this.sportType,
    this.fieldName,
    this.matchDateTime,
    required this.type,
    required this.status,
    this.message,
    required this.createdAt,
    this.respondedAt,
    this.teamId,
    this.teamName,
    this.draftMatchId,
    this.draftMatchDescription,
    this.skillLevel,
    this.slotsNeeded,
  });

  factory UnifiedInvitationModel.fromJson(Map<String, dynamic> json) {
    try {
      print('Parsing UnifiedInvitationModel from JSON: $json');
      
      final createdAtStr = json['createdAt'] as String?;
      final updatedAtStr = json['updatedAt'] as String?;
      
      print('createdAt string: $createdAtStr');
      print('updatedAt string: $updatedAtStr');
      
      DateTime createdAt = DateTime.now(); // Default fallback
      DateTime? updatedAt;
      
      if (createdAtStr != null) {
        final parsedCreatedAt = DateTime.tryParse(createdAtStr);
        if (parsedCreatedAt != null) {
          createdAt = parsedCreatedAt;
        }
        print('Parsed createdAt: $createdAt');
      }
      
      if (updatedAtStr != null) {
        updatedAt = DateTime.tryParse(updatedAtStr);
        print('Parsed updatedAt: $updatedAt');
      }
      
      return UnifiedInvitationModel(
        id: json['id'] as int? ?? 0,
        inviterId: json['inviterId'] as int?,
        inviterName: json['inviterName'] as String?,
        inviterAvatarUrl: json['inviterProfilePicture'] as String?,
        receiverId: json['inviteeId'] as int?,
        receiverName: json['inviteeName'] as String?,
        openMatchId: json['openMatchId'] as int?,
        openMatchTitle: json['openMatchTitle'] as String?,
        sportType: json['sportType'] as String?,
        fieldName: json['fieldName'] as String?,
        matchDateTime: json['matchDateTime'] as String?,
        type: json['type'] as String? ?? 'REQUEST',
        status: json['status'] as String? ?? 'PENDING',
        message: json['message'] as String?,
        createdAt: createdAt,
        respondedAt: updatedAt,
        teamId: json['teamId'] as int?,
        teamName: json['teamName'] as String?,
        draftMatchId: json['draftMatchId'] as int?,
        draftMatchDescription: json['draftMatchDescription'] as String?,
        skillLevel: json['skillLevel'] as String?,
        slotsNeeded: json['slotsNeeded'] as int?,
      );
    } catch (e) {
      print('Error parsing UnifiedInvitationModel: $e');
      print('JSON data: $json');
      // Return a safe default
      return UnifiedInvitationModel(
        id: 0,
        type: 'invitation',
        status: 'pending',
        createdAt: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inviterId': inviterId,
      'inviterName': inviterName,
      'inviterAvatarUrl': inviterAvatarUrl,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'openMatchId': openMatchId,
      'openMatchTitle': openMatchTitle,
      'sportType': sportType,
      'fieldName': fieldName,
      'matchDateTime': matchDateTime,
      'type': type,
      'status': status,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'respondedAt': respondedAt?.toIso8601String(),
      'teamId': teamId,
      'teamName': teamName,
      'draftMatchId': draftMatchId,
      'draftMatchDescription': draftMatchDescription,
      'skillLevel': skillLevel,
      'slotsNeeded': slotsNeeded,
    };
  }

  // Convenience getters
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isAccepted => status.toLowerCase() == 'accepted';
  bool get isRejected => status.toLowerCase() == 'rejected';
  
  bool get isInvitation => type.toLowerCase() == 'invitation';
  bool get isRequest => type.toLowerCase() == 'request';
  bool get isDraftMatchRequest => type.toLowerCase() == 'draft_match_request';

  String get displayTitle {
    if (openMatchTitle != null && openMatchTitle!.isNotEmpty) {
      return openMatchTitle!;
    } else if (teamName != null && teamName!.isNotEmpty) {
      return 'Lời mời tham gia đội $teamName';
    } else if (draftMatchDescription != null && draftMatchDescription!.isNotEmpty) {
      return draftMatchDescription!;
    } else if (sportType != null) {
      return 'Trận đấu $sportType';
    }
    return 'Lời mời';
  }

  String get displaySubtitle {
    final parts = <String>[];
    
    if (inviterName != null && inviterName!.isNotEmpty) {
      parts.add('Từ $inviterName');
    }
    
    if (sportType != null && sportType!.isNotEmpty) {
      parts.add(sportType!);
    }
    
    if (fieldName != null && fieldName!.isNotEmpty) {
      parts.add(fieldName!);
    }
    
    if (skillLevel != null && skillLevel!.isNotEmpty) {
      parts.add('Trình độ: $skillLevel');
    }
    
    return parts.join(' • ');
  }

  String get displayDateTime {
    if (matchDateTime != null && matchDateTime!.isNotEmpty) {
      try {
        final dateTime = DateTime.parse(matchDateTime!);
        return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
      } catch (e) {
        return matchDateTime!;
      }
    }
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  String get statusDisplayText {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Chờ phản hồi';
      case 'accepted':
        return 'Đã chấp nhận';
      case 'rejected':
        return 'Đã từ chối';
      default:
        return status;
    }
  }
}


class UnifiedInvitationListResponse {
  final List<UnifiedInvitationModel> invitations;
  final int totalElements;
  final int totalPages;
  final int currentPage;

  const UnifiedInvitationListResponse({
    required this.invitations,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
  });

  factory UnifiedInvitationListResponse.fromJson(dynamic json) {
    print('Parsing UnifiedInvitationListResponse from JSON: $json');
    
    // Handle both direct array and paginated response
    List<dynamic> invitationsList;
    
    if (json is List) {
      // Direct array response
      invitationsList = json;
      print('Processing direct array response with ${invitationsList.length} items');
    } else if (json is Map<String, dynamic>) {
      if (json['invitations'] != null) {
        // Paginated response
        invitationsList = json['invitations'] as List<dynamic>;
        print('Processing paginated response (invitations) with ${invitationsList.length} items');
      } else if (json['content'] != null) {
        // Spring Boot paginated response
        invitationsList = json['content'] as List<dynamic>;
        print('Processing Spring Boot paginated response (content) with ${invitationsList.length} items');
      } else {
        // Fallback: empty list
        invitationsList = [];
        print('No invitations or content found, using empty list');
      }
    } else {
      // Fallback: empty list
      invitationsList = [];
      print('Unknown JSON format, using empty list');
    }
    
    final jsonMap = json is Map<String, dynamic> ? json : <String, dynamic>{};
    
    final invitations = <UnifiedInvitationModel>[];
    
    for (int i = 0; i < invitationsList.length; i++) {
      try {
        print('Processing invitation $i: ${invitationsList[i]}');
        final invitation = UnifiedInvitationModel.fromJson(invitationsList[i] as Map<String, dynamic>);
        invitations.add(invitation);
        print('Successfully parsed invitation $i');
      } catch (e, stackTrace) {
        print('Error parsing invitation $i: $e');
        print('Stack trace: $stackTrace');
        print('Raw data: ${invitationsList[i]}');
        rethrow;
      }
    }

    return UnifiedInvitationListResponse(
        invitations: invitations,
        totalElements: jsonMap['totalElements'] as int? ?? invitationsList.length,
        totalPages: jsonMap['totalPages'] as int? ?? 1,
        currentPage: jsonMap['number'] as int? ?? jsonMap['currentPage'] as int? ?? 0,
      );
  }

  Map<String, dynamic> toJson() {
    return {
      'invitations': invitations.map((e) => e.toJson()).toList(),
      'totalElements': totalElements,
      'totalPages': totalPages,
      'currentPage': currentPage,
    };
  }
}