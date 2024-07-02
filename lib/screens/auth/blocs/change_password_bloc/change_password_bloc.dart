import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:transaction_repository/transaction_repository.dart';

part 'change_password_event.dart';
part 'change_password_state.dart';

class ChangePasswordBloc extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  final AuthRepository authRepository;
  
  ChangePasswordBloc(this.authRepository) : super(ChangePasswordInitial()) {
    on<ChangePassword>((event, emit) async {
      try {
        String result = await authRepository.changePassword(event.password);
        result == 'ok' ? emit(ChangePasswordSuccess()) : emit(ChangePasswordFailure(result));
      } catch (e) {
        emit(ChangePasswordFailure(e.toString()));
      }
    });
  }
}
