import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:transaction_repository/transaction_repository.dart';

part 'update_profile_event.dart';
part 'update_profile_state.dart';

class UpdateProfileBloc extends Bloc<UpdateProfileEvent, UpdateProfileState> {
  final AuthRepository authRepository;
  
  UpdateProfileBloc(this.authRepository) : super(UpdateProfileInitial()) {
    on<UpdateProfile>((event, emit) async {
      try {
        String result = await authRepository.updateProfile(event.displayName, event.image);
        result == 'ok' ? emit(UpdateProfileSuccess()) : emit(UpdateProfileFailure(result));
      } catch (e) {
        emit(UpdateProfileFailure(e.toString()));
      }
    });
  }
}
