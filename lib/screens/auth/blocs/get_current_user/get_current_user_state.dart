part of 'get_current_user_bloc.dart';

sealed class GetCurrentUserState extends Equatable {
  const GetCurrentUserState();
  
  @override
  List<Object> get props => [];
}

final class GetCurrentUserInitial extends GetCurrentUserState {}

final class GetCurrentUserFailure extends GetCurrentUserState {
  final String error;

  const GetCurrentUserFailure(this.error);

  @override
  List<Object> get props => [error];
}

final class GetCurrentUserLoading extends GetCurrentUserState {}

final class GetCurrentUserSuccess extends GetCurrentUserState {
  final User user;

  const GetCurrentUserSuccess(this.user);

  @override
  List<Object> get props => [user];
}
