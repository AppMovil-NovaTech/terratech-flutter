import 'package:equatable/equatable.dart';

/// Agricultural user profile stored at `/api/v1/profiles/me` (US09) and required
/// by the backend before subscribing to US31 preferences or receiving US32 alerts.
class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.emailAddress,
    required this.fundoName,
    required this.contactPhone,
    required this.location,
    required this.sizeM2,
    required this.moistureThreshold,
    required this.tempThreshold,
    this.registeredAt,
  });

  final int id;
  final int userId;
  final String fullName;
  final String emailAddress;
  final String fundoName;
  final String contactPhone;
  final String location;
  final double sizeM2;
  final double moistureThreshold;
  final double tempThreshold;
  final DateTime? registeredAt;

  @override
  List<Object?> get props => <Object?>[
    id,
    userId,
    fullName,
    emailAddress,
    fundoName,
    contactPhone,
    location,
    sizeM2,
    moistureThreshold,
    tempThreshold,
    registeredAt,
  ];
}

/// Command payload for creating or updating the authenticated user's profile.
class UpsertUserProfileInput extends Equatable {
  const UpsertUserProfileInput({
    required this.fullName,
    required this.fundoName,
    required this.contactPhone,
    required this.location,
    required this.sizeM2,
    this.moistureThreshold,
    this.tempThreshold,
  });

  final String fullName;
  final String fundoName;
  final String contactPhone;
  final String location;
  final double sizeM2;
  final double? moistureThreshold;
  final double? tempThreshold;

  @override
  List<Object?> get props => <Object?>[
    fullName,
    fundoName,
    contactPhone,
    location,
    sizeM2,
    moistureThreshold,
    tempThreshold,
  ];
}
