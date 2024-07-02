part of 'logout_bloc.dart';

sealed class LogoutBlocState extends Equatable {
  const LogoutBlocState();
  
  @override
  List<Object> get props => [];
}

final class LogoutBlocInitial extends LogoutBlocState {}

final class LogoutFailure extends LogoutBlocState {}

final class LogoutLoading extends LogoutBlocState {}

final class LogoutSuccess extends LogoutBlocState {}
