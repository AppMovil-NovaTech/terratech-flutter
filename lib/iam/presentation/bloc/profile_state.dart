import 'package:equatable/equatable.dart';

import '../../domain/entities/user_profile.dart';

enum ProfileStatus { initial, loading, loaded, empty, failure }

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
  });

  final ProfileStatus status;
  final UserProfile? profile;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;

  ProfileState copyWith({
    ProfileStatus? status,
    UserProfile? profile,
    bool clearProfile = false,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: clearProfile ? null : (profile ?? this.profile),
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    profile,
    isSaving,
    errorMessage,
    successMessage,
  ];
}
