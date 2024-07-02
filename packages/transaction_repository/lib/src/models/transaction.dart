

import 'package:transaction_repository/transaction_repository.dart';

class Transaction {
  String transactionId;
  String category;
  DateTime date;
  double amount;
  String description;

  Transaction({
    required this.transactionId,
    required this.category,
    required this.date,
    required this.amount,
    required this.description
  });

  static final empty = Transaction(
    transactionId: '',
    category: '',
    date: DateTime.now(),
    amount: 0,
    description: ''
  );

  TransactionEntity toEntity() {
    return TransactionEntity(
      transactionId: transactionId,
      category: category,
      date: date,
      amount: amount,
      description: description
    );
  }

  static Transaction fromEntity(TransactionEntity entity) {
    return Transaction(
      transactionId: entity.transactionId,
      category: entity.category,
      date: entity.date,
      amount: entity.amount,
      description: entity.description
    );
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      transactionId: json['transactionId'],
      category: json['category'],
      date: DateTime.parse(json['date']),
      amount: json['amount'],
      description: json['description']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'category': category,
      'date': date.toIso8601String(),
      'amount': amount,
      'description': description
    };
  }
}