import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:localstorage/localstorage.dart';
import 'package:transaction_repository/transaction_repository.dart';

part 'get_current_user_event.dart';
part 'get_current_user_state.dart';

class GetCurrentUserBloc extends Bloc<GetCurrentUserEvent, GetCurrentUserState> {
  final AuthRepository authRepository;

  GetCurrentUserBloc(this.authRepository) : super(GetCurrentUserInitial()) {
    on<GetCurrentUser>(_onGetCurrentUser);
  }

  Future<void> _onGetCurrentUser(GetCurrentUser event, Emitter<GetCurrentUserState> emit) async {
    try {
        User result = await authRepository.getCurrentUser();
        
        if (result != User.empty){
          emit(GetCurrentUserSuccess(result));
        }
        else {
          final user = localStorage.getItem('user');
          if (user != null && user.isNotEmpty) {
            final Map<String, dynamic> userMap = json.decode(user);
            User currentUser = User.fromJson(userMap);
            emit(GetCurrentUserSuccess(currentUser));
          } else {
            emit(GetCurrentUserSuccess(User.empty));
          }
        }

    } catch (e) {
      emit(GetCurrentUserFailure(e.toString()));
    }
  }

}