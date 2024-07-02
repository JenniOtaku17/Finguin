import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:transaction_repository/transaction_repository.dart';

part 'register_bloc_event.dart';
part 'register_bloc_state.dart';

class RegisterBlocBloc extends Bloc<RegisterBlocEvent, RegisterBlocState> {
  final AuthRepository authRepository;
  
  RegisterBlocBloc(this.authRepository) : super(RegisterBlocInitial()) {
    on<Register>((event, emit) async {
      try {
          String result = await authRepository.register(event.user, event.password, event.photo);
          result == 'ok' ? emit(RegisterSuccess()) : emit(RegisterFailure(result));
        } catch (e) {
          emit(RegisterFailure(e.toString()));
        }
    });
  }
}
