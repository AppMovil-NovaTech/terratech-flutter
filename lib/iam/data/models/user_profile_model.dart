import '../../domain/entities/user_profile.dart';

/// Data transfer model mapped to `MyProfileResource` at `/api/v1/profiles/me`.
class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.userId,
    required super.fullName,
    required super.emailAddress,
    required super.fundoName,
    required super.contactPhone,
    required super.location,
    required super.sizeM2,
    required super.moistureThreshold,
    required super.tempThreshold,
    super.registeredAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final registeredRaw = json['registeredAt'];
    return UserProfileModel(
      id: _asInt(json['id']) ?? 0,
      userId: _asInt(json['userId']) ?? 0,
      fullName: (json['fullName'] as String?)?.trim() ?? '',
      emailAddress: (json['emailAddress'] as String?)?.trim() ?? '',
      fundoName: (json['fundoName'] as String?)?.trim() ?? '',
      contactPhone: (json['contactPhone'] as String?)?.trim() ?? '',
      location: (json['location'] as String?)?.trim() ?? '',
      sizeM2: _asDouble(json['sizeM2']) ?? 0.0,
      moistureThreshold: _asDouble(json['moistureThreshold']) ?? 0.0,
      tempThreshold: _asDouble(json['tempThreshold']) ?? 0.0,
      registeredAt: registeredRaw is String
          ? DateTime.tryParse(registeredRaw)
          : null,
    );
  }

  static Map<String, dynamic> toUpsertJson(UpsertUserProfileInput input) {
    return <String, dynamic>{
      'fullName': input.fullName.trim(),
      'fundoName': input.fundoName.trim(),
      'contactPhone': input.contactPhone.trim(),
      'location': input.location.trim(),
      'sizeM2': input.sizeM2,
      if (input.moistureThreshold != null)
        'moistureThreshold': input.moistureThreshold,
      if (input.tempThreshold != null) 'tempThreshold': input.tempThreshold,
    };
  }

  static int? _asInt(Object? value) {
    return switch (value) {
      final int v => v,
      final num v => v.toInt(),
      final String v => int.tryParse(v),
      _ => null,
    };
  }

  static double? _asDouble(Object? value) {
    return switch (value) {
      final double v => v,
      final num v => v.toDouble(),
      final String v => double.tryParse(v),
      _ => null,
    };
  }
}
