import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:transaction_repository/transaction_repository.dart';

part 'get_transactions_event.dart';
part 'get_transactions_state.dart';

class GetTransactionsBloc extends Bloc<GetTransactionsEvent, GetTransactionsState> {
  TransactionRepository transactionRepository;

  GetTransactionsBloc(this.transactionRepository) : super(GetTransactionsInitial()) {
    on<GetTransactions>((event, emit) async {
      emit(GetTransactionsLoading());
      try {
        List<Transaction> transactions = await transactionRepository.getTransactions();
        emit(GetTransactionsSuccess(transactions));
      } catch (e) {
        emit(GetTransactionsFailure());
      }
    });
  }
}
