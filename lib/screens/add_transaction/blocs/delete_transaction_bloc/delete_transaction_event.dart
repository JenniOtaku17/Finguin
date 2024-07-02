part of 'delete_transaction_bloc.dart';

sealed class DeleteTransactionEvent extends Equatable {
  const DeleteTransactionEvent();

  @override
  List<Object> get props => [];
}

class DeleteTransaction extends DeleteTransactionEvent {
  final Transaction transaction;

  const DeleteTransaction(this.transaction);

  @override
  List<Object> get props => [transaction];
}