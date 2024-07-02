import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:transaction_repository/transaction_repository.dart';

part 'logout_bloc_event.dart';
part 'logout_bloc_state.dart';

class LogoutBloc extends Bloc<LogoutBlocEvent, LogoutBlocState> {
  final AuthRepository authRepository;

  LogoutBloc(this.authRepository) : super(LogoutBlocInitial()) {
    on<LogoutBlocEvent>((event, emit) async {
      try {
        await authRepository.logout();
        emit(LogoutSuccess());
      } catch (e) {
        emit(LogoutFailure());
      }
    });
  }
}
