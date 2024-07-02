part of 'delete_transaction_bloc.dart';

sealed class DeleteTransactionState extends Equatable {
  const DeleteTransactionState();
  
  @override
  List<Object> get props => [];
}

final class DeleteTransactionInitial extends DeleteTransactionState {}

final class DeleteTransactionFailure extends DeleteTransactionState {}
final class DeleteTransactionLoading extends DeleteTransactionState {}
final class DeleteTransactionSuccess extends DeleteTransactionState {}
