import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:localstorage/localstorage.dart';
import 'package:transaction_repository/transaction_repository.dart';

part 'delete_transaction_event.dart';
part 'delete_transaction_state.dart';

class DeleteTransactionBloc extends Bloc<DeleteTransactionEvent, DeleteTransactionState> {
  TransactionRepository transactionRepository;

  DeleteTransactionBloc(this.transactionRepository) : super(DeleteTransactionInitial()) {
    on<DeleteTransaction>((event, emit) async {
      emit(DeleteTransactionLoading());
      try {
        bool isConnected = await _checkInternetConnection();

        if(isConnected){
          await transactionRepository.deleteTransaction(event.transaction);
        }else{
          await deleteOfflineTransaction(event.transaction);
        }

        emit(DeleteTransactionSuccess());
      } catch (e) {
        emit(DeleteTransactionFailure());
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

  Future<bool> deleteOfflineTransaction(Transaction newTransaction) {
    try {
      newTransaction.category = 'delete';

      //Transactions actions local storage
      String? transactionsActionJson = localStorage.getItem('transactionsAction');
      List<Transaction> transactionsAction = [];

      if (transactionsActionJson != null && transactionsActionJson.isNotEmpty) {
        List<dynamic> decodedTransactions = jsonDecode(transactionsActionJson);
        transactionsAction = decodedTransactions.map((e) => Transaction.fromJson(e)).toList();
      }

      int index = transactionsAction.indexWhere((transaction) => transaction.transactionId == newTransaction.transactionId);
      if (index != -1) {
        transactionsAction[index] = newTransaction;
      } else {
        transactionsAction.add(newTransaction);
      }

      String updatedTransactionsJson = jsonEncode(transactionsAction.map((transaction) => transaction.toJson()).toList());
      localStorage.setItem('transactionsAction', updatedTransactionsJson);

      //Transactions local storage
      String? transactionsJson = localStorage.getItem('transactions');
      List<Transaction> transactions = [];

      if (transactionsJson != null && transactionsJson.isNotEmpty) {
        List<dynamic> decodedTransactions = jsonDecode(transactionsJson);
        transactions = decodedTransactions.map((e) => Transaction.fromJson(e)).toList();
      }

      int index2 = transactions.indexWhere((transaction) => transaction.transactionId == newTransaction.transactionId);
      if (index2 != -1) {
        transactions.removeAt(index2);
      }

      String updatedTransactionsJson2 = jsonEncode(transactions.map((transaction) => transaction.toJson()).toList());
      localStorage.setItem('transactions', updatedTransactionsJson2);

      return Future.value(true);

    } catch (e) {
      print(e.toString());
      return Future.value(false);

    }
  }
}
