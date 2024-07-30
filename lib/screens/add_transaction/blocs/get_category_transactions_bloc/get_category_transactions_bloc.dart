import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:localstorage/localstorage.dart';
import 'package:transaction_repository/transaction_repository.dart';

part 'get_category_transactions_event.dart';
part 'get_category_transactions_state.dart';

class GetCategoryTransactionsBloc extends Bloc<GetCategoryTransactionsEvent, GetCategoryTransactionsState> {
  TransactionRepository transactionRepository;
  late StreamSubscription<bool> connectivitySubscription;

  GetCategoryTransactionsBloc(this.transactionRepository) : super(GetCategoryTransactionsInitial()) {
    on<GetCategoryTransactions>((event, emit) async {
      emit(GetCategoryTransactionsLoading());
      try {
        List<Transaction> transactions = [];
        bool isConnected = await _checkInternetConnection();

        if(isConnected){
          print('online');
          transactions = await transactionRepository.getCategoryTransactionsFiltered(event.category, event.month, event.year);

        }else{
          print('offline');
          String? transactionsJson = localStorage.getItem('transactions');

          if (transactionsJson != null && transactionsJson.isNotEmpty) {
            List<dynamic> decodedTransactions = jsonDecode(transactionsJson);
            transactions = decodedTransactions.map((e) => Transaction.fromJson(e)).toList();
          }

        }
        
        emit(GetCategoryTransactionsSuccess(transactions));
      } catch (e) {
        print(e.toString());
        emit(GetCategoryTransactionsFailure());
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
