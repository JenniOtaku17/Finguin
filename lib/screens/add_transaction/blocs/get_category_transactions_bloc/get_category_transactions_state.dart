part of 'get_category_transactions_bloc.dart';

sealed class GetCategoryTransactionsState extends Equatable {
  const GetCategoryTransactionsState();
  
  @override
  List<Object> get props => [];
}

final class GetCategoryTransactionsInitial extends GetCategoryTransactionsState {}

final class GetCategoryTransactionsFailure extends GetCategoryTransactionsState {}
final class GetCategoryTransactionsLoading extends GetCategoryTransactionsState {}
final class GetCategoryTransactionsSuccess extends GetCategoryTransactionsState {
  final List<Transaction> transactions;

  const GetCategoryTransactionsSuccess(this.transactions);

  @override
  List<Object> get props => [transactions];

  get categories => null;
}
