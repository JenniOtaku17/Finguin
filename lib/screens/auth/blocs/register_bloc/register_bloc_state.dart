part of 'register_bloc_bloc.dart';

sealed class RegisterBlocState extends Equatable {
  const RegisterBlocState();
  
  @override
  List<Object> get props => [];
}

final class RegisterBlocInitial extends RegisterBlocState {}

final class RegisterFailure extends RegisterBlocState {
  final String error;

  const RegisterFailure(this.error);

  @override
  List<Object> get props => [error];
}

final class RegisterLoading extends RegisterBlocState {}

final class RegisterSuccess extends RegisterBlocState {}
