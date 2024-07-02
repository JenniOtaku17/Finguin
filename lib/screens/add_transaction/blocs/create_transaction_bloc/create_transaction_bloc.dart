import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:localstorage/localstorage.dart';
import 'package:transaction_repository/transaction_repository.dart';

part 'create_transaction_event.dart';
part 'create_transaction_state.dart';

class CreateTransactionBloc extends Bloc<CreateTransactionEvent, CreateTransactionState> {
  TransactionRepository transactionRepository;

  CreateTransactionBloc(this.transactionRepository) : super(CreateTransactionInitial()) {
    on<CreateTransaction>((event, emit) async {
      emit(CreateTransactionLoading());
      try {
        bool isConnected = await _checkInternetConnection();

        if(isConnected){
          bool result = await transactionRepository.createTransaction(event.transaction);
          print('result '+result.toString());
          result? emit(CreateTransactionSuccess()) : emit(CreateTransactionFailure());
        }else{
          bool result = await createOfflineTransaction(event.transaction);
          result? emit(CreateTransactionSuccess()) : emit(CreateTransactionFailure());
        }
        
      } catch (e) {
        emit(CreateTransactionFailure());
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

  Future<bool> createOfflineTransaction(Transaction newTransaction) {
    try {

      //Transactions actions local storage
      String? transactionsActionJson = localStorage.getItem('transactionsAction');
      List<Transaction> transactionsAction = [];

      if (transactionsActionJson != null && transactionsActionJson.isNotEmpty) {
        List<dynamic> decodedTransactions = jsonDecode(transactionsActionJson);
        transactionsAction = decodedTransactions.map((e) => Transaction.fromJson(e)).toList();
      }

      //Transactions local storage
      String? transactionsJson = localStorage.getItem('transactions');
      List<Transaction> transactions = [];

      if (transactionsJson != null && transactionsJson.isNotEmpty) {
        List<dynamic> decodedTransactions = jsonDecode(transactionsJson);
        transactions = decodedTransactions.map((e) => Transaction.fromJson(e)).toList();
      }

      //category
      String? categoriesJson = localStorage.getItem('categories');
      List<Category> categories = [];

      if (categoriesJson != null && categoriesJson.isNotEmpty) {
        List<dynamic> decodedCategories = jsonDecode(categoriesJson);
        categories = decodedCategories.map((e) => Category.fromJson(e)).toList();
      }
      Category relatedCategory = categories.firstWhere((category) => category.categoryId == newTransaction.category);

      //total of transactions for category
      double total = 0;
      for(var tran in transactions){
        if(tran.category == newTransaction.category){
          total += tran.amount;
        }
      }

      
      // creation viability
      if(total + newTransaction.amount > relatedCategory.maxAmount){
        return Future.value(false);

      }else{
        //Transactions actions local storage
        int index = transactionsAction.indexWhere((transaction) => transaction.transactionId == newTransaction.transactionId);
        if (index != -1) {
          transactionsAction[index] = newTransaction;
        } else {
          transactionsAction.add(newTransaction);
        }
        String updatedTransactionsJson = jsonEncode(transactionsAction.map((transaction) => transaction.toJson()).toList());
        localStorage.setItem('transactionsAction', updatedTransactionsJson);
        

        //Transactions local storage
        int index2 = transactions.indexWhere((transaction) => transaction.transactionId == newTransaction.transactionId);
        if (index2 != -1) {
          transactions[index2] = newTransaction;
        } else {
          transactions.insert(0, newTransaction);
        }
        String updatedTransactionsJson2 = jsonEncode(transactions.map((transaction) => transaction.toJson()).toList());
        localStorage.setItem('transactions', updatedTransactionsJson2);

        return Future.value(true);
      }

    } catch (e) {
      print(e.toString());
      return Future.value(false);
    }
  }
}
