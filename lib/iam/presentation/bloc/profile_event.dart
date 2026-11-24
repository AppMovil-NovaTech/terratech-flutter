import 'package:equatable/equatable.dart';

import '../../domain/entities/user_profile.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class LoadMyProfileRequested extends ProfileEvent {
  const LoadMyProfileRequested();
}

final class SaveMyProfileRequested extends ProfileEvent {
  const SaveMyProfileRequested(this.input);

  final UpsertUserProfileInput input;

  @override
  List<Object?> get props => <Object?>[input];
}
