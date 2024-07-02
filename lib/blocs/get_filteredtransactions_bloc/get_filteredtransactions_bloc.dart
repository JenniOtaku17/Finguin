import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:localstorage/localstorage.dart';
import 'package:transaction_repository/transaction_repository.dart';

part 'get_filteredtransactions_event.dart';
part 'get_filteredtransactions_state.dart';

class GetFilteredTransactionsBloc extends Bloc<GetFilteredTransactionsEvent, GetFilteredTransactionsState> {
  TransactionRepository transactionRepository;
  late StreamSubscription<bool> connectivitySubscription;

  GetFilteredTransactionsBloc(this.transactionRepository) : super(GetFilteredTransactionsInitial()) {
    on<GetFilteredTransactions>((event, emit) async {
      emit(GetFilteredTransactionsLoading());
      try {
        List<Transaction> transactions = [];
        bool isConnected = await _checkInternetConnection();

        if(isConnected){
          print('online');
          transactions = await transactionRepository.getFilteredTransactions(event.month, event.year);
          
          String transactionsJson = jsonEncode(transactions.map((transaction) => transaction.toJson()).toList());
          localStorage.setItem('transactions', transactionsJson);
        }else{
          print('offline');
          String? transactionsJson = localStorage.getItem('transactions');

          if (transactionsJson != null && transactionsJson.isNotEmpty) {
            List<dynamic> decodedTransactions = jsonDecode(transactionsJson);
            transactions = decodedTransactions.map((e) => Transaction.fromJson(e)).toList();
          }

        }
        
        emit(GetFilteredTransactionsSuccess(transactions));
      } catch (e) {
        print(e.toString());
        emit(GetFilteredTransactionsFailure());
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
