part of 'get_transactions_bloc.dart';

sealed class GetTransactionsState extends Equatable {
  const GetTransactionsState();
  
  @override
  List<Object> get props => [];
}

final class GetTransactionsInitial extends GetTransactionsState {}

final class GetTransactionsFailure extends GetTransactionsState {}
final class GetTransactionsLoading extends GetTransactionsState {}
final class GetTransactionsSuccess extends GetTransactionsState {
  final List<Transaction> transactions;

  const GetTransactionsSuccess(this.transactions);

  @override
  List<Object> get props => [transactions];

  get categories => null;
}
