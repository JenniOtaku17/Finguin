part of 'get_filteredtransactions_bloc.dart';

sealed class GetFilteredTransactionsEvent extends Equatable {
  const GetFilteredTransactionsEvent();

  @override
  List<Object> get props => [];
}

class GetFilteredTransactions extends GetFilteredTransactionsEvent{
  final int month;
  final int year;

  const GetFilteredTransactions({required this.month, required this.year});

  @override
  List<Object> get props => [month, year];
}