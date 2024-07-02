part of 'register_bloc_bloc.dart';

sealed class RegisterBlocEvent extends Equatable {
  const RegisterBlocEvent();

  @override
  List<Object?> get props => [];
}

class Register extends RegisterBlocEvent{
  final User user;
  final String password;
  final File? photo;

  const Register(this.user, this.password, this.photo);

  @override
  List<Object?> get props => [user, password, photo];
}
