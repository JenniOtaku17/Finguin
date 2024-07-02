part of 'update_profile_bloc.dart';

sealed class UpdateProfileEvent extends Equatable {
  const UpdateProfileEvent();

  @override
  List<Object?> get props => [];
}

class UpdateProfile extends UpdateProfileEvent{
  final String? displayName;
  final File? image;

  const UpdateProfile(this.displayName, this.image);

  @override
  List<Object?> get props => [displayName, image];
}
