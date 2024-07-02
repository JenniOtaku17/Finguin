part of 'get_filteredtransactions_bloc.dart';

sealed class GetFilteredTransactionsState extends Equatable {
  const GetFilteredTransactionsState();
  
  @override
  List<Object> get props => [];
}

final class GetFilteredTransactionsInitial extends GetFilteredTransactionsState {}

final class GetFilteredTransactionsFailure extends GetFilteredTransactionsState {}
final class GetFilteredTransactionsLoading extends GetFilteredTransactionsState {}
final class GetFilteredTransactionsSuccess extends GetFilteredTransactionsState {
  final List<Transaction> transactions;

  const GetFilteredTransactionsSuccess(this.transactions);

  @override
  List<Object> get props => [transactions];

  get categories => null;
}
