import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:localstorage/localstorage.dart';
import 'package:transaction_repository/transaction_repository.dart';

part 'delete_category_event.dart';
part 'delete_category_state.dart';

class DeleteCategoryBloc extends Bloc<DeleteCategoryEvent, DeleteCategoryState> {
  TransactionRepository transactionRepository;

  DeleteCategoryBloc(this.transactionRepository) : super(DeleteCategoryInitial()) {
    on<DeleteCategory>((event, emit) async {
      emit(DeleteCategoryLoading());
      try {
        bool isConnected = await _checkInternetConnection();

        if(isConnected){
          bool result = await transactionRepository.deleteCategory(event.category);
          result? emit(DeleteCategorySuccess()): emit(DeleteCategoryFailure());
        }else{
          bool result = await deleteOfflineCategory(event.category);
          result? emit(DeleteCategorySuccess()): emit(DeleteCategoryFailure());
        }
        
      } catch (e) {
        emit(DeleteCategoryFailure());
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

  Future<bool> deleteOfflineCategory(Category newCategory) {
    try {
      newCategory.name = 'delete';

      //categories actions local storage
      String? categoriesActionJson = localStorage.getItem('categoriesAction');
      List<Category> categoriesAction = [];

      if (categoriesActionJson != null && categoriesActionJson.isNotEmpty) {
        List<dynamic> decodedCategories = jsonDecode(categoriesActionJson);
        categoriesAction = decodedCategories.map((e) => Category.fromJson(e)).toList();
      }

      //categories local storage
      String? categoriesJson = localStorage.getItem('categories');
      List<Category> categories = [];

      if (categoriesJson != null && categoriesJson.isNotEmpty) {
        List<dynamic> decodedCategories = jsonDecode(categoriesJson);
        categories = decodedCategories.map((e) => Category.fromJson(e)).toList();
      }


      //transactions
      String? transactionsJson = localStorage.getItem('transactions');
      List<Transaction> transactions = [];

      if (transactionsJson != null && transactionsJson.isNotEmpty) {
        List<dynamic> decodedTransactions = jsonDecode(transactionsJson);
        transactions = decodedTransactions.map((e) => Transaction.fromJson(e)).toList();
      }
      Iterable<Transaction> relatedTransactions = transactions.where(
        (transaction) => transaction.category == newCategory.categoryId
      );
      
      // creation viability
      if(relatedTransactions.isNotEmpty){
        return Future.value(false);

      }else{
        //categories actions local storage
        int index = categoriesAction.indexWhere((category) => category.categoryId == newCategory.categoryId);
        if (index != -1) {
          categoriesAction[index] = newCategory;
        } else {
          categoriesAction.add(newCategory);
        }
        String updatedCategoriesJson = jsonEncode(categoriesAction.map((category) => category.toJson()).toList());
        localStorage.setItem('categoriesAction', updatedCategoriesJson);


        //categories local storage
        int index2 = categories.indexWhere((category) => category.categoryId == newCategory.categoryId);
        if (index2 != -1) {
          categories.removeAt(index2);
        }
        String updatedCategoriesJson2 = jsonEncode(categories.map((category) => category.toJson()).toList());
        localStorage.setItem('categories', updatedCategoriesJson2);


        return Future.value(true);
      }

    } catch (e) {
      print(e.toString());
      return Future.value(false);
    }
  }
}
