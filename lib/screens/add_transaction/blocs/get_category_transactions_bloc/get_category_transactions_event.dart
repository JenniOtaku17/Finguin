part of 'get_category_transactions_bloc.dart';

sealed class GetCategoryTransactionsEvent extends Equatable {
  const GetCategoryTransactionsEvent();

  @override
  List<Object?> get props => [];
}

class GetCategoryTransactions extends GetCategoryTransactionsEvent{
  final int? month;
  final int? year;
  final String category;

  const GetCategoryTransactions({ this.month, this.year, required this.category});

  @override
  List<Object?> get props => [month, year, category];
}