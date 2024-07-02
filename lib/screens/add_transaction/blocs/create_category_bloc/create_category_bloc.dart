import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:localstorage/localstorage.dart';
import 'package:transaction_repository/transaction_repository.dart';

part 'create_category_event.dart';
part 'create_category_state.dart';

class CreateCategoryBloc extends Bloc<CreateCategoryEvent, CreateCategoryState> {
  final TransactionRepository transactionRepository;

  CreateCategoryBloc(this.transactionRepository) : super(CreateCategoryInitial()) {
    on<CreateCategory>((event, emit) async {
      emit(CreateCategoryLoading());
      try {
        bool isConnected = await _checkInternetConnection();

        if(isConnected){
          await transactionRepository.createCategory(event.category);
        }else{
          await createOfflineCategory(event.category);
        }

        emit(CreateCategorySuccess());
      } catch (e) {
        emit(CreateCategoryFailure());
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

  Future<bool> createOfflineCategory(Category newCategory) {
    try {

        //categories actions local storage
        String? categoriesActionJson = localStorage.getItem('categoriesAction');
        List<Category> categoriesAction = [];

        if (categoriesActionJson != null && categoriesActionJson.isNotEmpty) {
          List<dynamic> decodedCategories = jsonDecode(categoriesActionJson);
          categoriesAction = decodedCategories.map((e) => Category.fromJson(e)).toList();
        }

        int index = categoriesAction.indexWhere((category) => category.categoryId == newCategory.categoryId);
        if (index != -1) {
          categoriesAction[index] = newCategory;
        } else {
          categoriesAction.add(newCategory);
        }

        String updatedCategoriesJson = jsonEncode(categoriesAction.map((category) => category.toJson()).toList());
        localStorage.setItem('categoriesAction', updatedCategoriesJson);

        //categories local storage
        String? categoriesJson = localStorage.getItem('categories');
        List<Category> categories = [];

        if (categoriesJson != null && categoriesJson.isNotEmpty) {
          List<dynamic> decodedCategories = jsonDecode(categoriesJson);
          categories = decodedCategories.map((e) => Category.fromJson(e)).toList();
        }

        int index2 = categories.indexWhere((category) => category.categoryId == newCategory.categoryId);
        if (index2 != -1) {
          categories[index2] = newCategory;
        } else {
          categories.insert(0, newCategory);
        }

        String updatedCategoriesJson2 = jsonEncode(categories.map((category) => category.toJson()).toList());
        localStorage.setItem('categories', updatedCategoriesJson2);

        return Future.value(true);

    } catch (e) {
      print(e.toString());
      return Future.value(false);
    }
  }
  
}
