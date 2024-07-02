part of 'change_password_bloc.dart';

sealed class ChangePasswordState extends Equatable {
  const ChangePasswordState();
  
  @override
  List<Object> get props => [];
}

final class ChangePasswordInitial extends ChangePasswordState {}

final class ChangePasswordFailure extends ChangePasswordState {
  final String error;

  const ChangePasswordFailure(this.error);

  @override
  List<Object> get props => [error];
}

final class ChangePasswordLoading extends ChangePasswordState {}

final class ChangePasswordSuccess extends ChangePasswordState {}
