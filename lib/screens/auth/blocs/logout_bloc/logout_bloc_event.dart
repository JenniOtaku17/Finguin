part of 'logout_bloc.dart';

sealed class LogoutBlocEvent extends Equatable {
  const LogoutBlocEvent();

  @override
  List<Object> get props => [];
}

class Logout extends LogoutBlocEvent{

  const Logout();

  @override
  List<Object> get props => [];
}