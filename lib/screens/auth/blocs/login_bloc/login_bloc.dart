import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:transaction_repository/transaction_repository.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository authRepository;

  LoginBloc(this.authRepository) : super(LoginInitial()) {
    on<Login>((event, emit) async {
      try {
        String result = await authRepository.login(event.email, event.password);
        result == 'ok' ? emit(LoginSuccess()) : emit(LoginFailure(result));
      } catch (e) {
        emit(LoginFailure(e.toString()));
      }
    });
  }
}