import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:localstorage/localstorage.dart';
import 'package:transaction_repository/transaction_repository.dart';

part 'get_categories_event.dart';
part 'get_categories_state.dart';

class GetCategoriesBloc extends Bloc<GetCategoriesEvent, GetCategoriesState> {
  TransactionRepository transactionRepository;

  GetCategoriesBloc(this.transactionRepository) : super(GetCategoriesInitial()) {
    on<GetCategories>((event, emit) async {
      emit(GetCategoriesLoading());
      try {
        List<Category> categories = [];
        bool isConnected = await _checkInternetConnection();

        if(isConnected){
          print('online');
          categories = await transactionRepository.getCategories();
          
          String categoriesJson = jsonEncode(categories.map((category) => category.toJson()).toList());
          localStorage.setItem('categories', categoriesJson);
        }else{
          print('offline');
          String? categoriesJson = localStorage.getItem('categories');

          if (categoriesJson != null && categoriesJson.isNotEmpty) {
            List<dynamic> decodedCategories = jsonDecode(categoriesJson);
            categories = decodedCategories.map((e) => Category.fromJson(e)).toList();
          }

        }

        emit(GetCategoriesSuccess(categories));
      } catch (e) {
        print(e.toString());
        emit(GetCategoriesFailure());
      }
    });
  }

  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}
