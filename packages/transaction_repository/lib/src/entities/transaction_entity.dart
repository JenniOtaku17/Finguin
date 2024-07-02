import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionEntity {
  String transactionId;
  String category;
  DateTime date;
  double amount;
  String description;

  TransactionEntity({
    required this.transactionId,
    required this.category,
    required this.date,
    required this.amount,
    required this.description
  });

  Map<String, Object?> toDocument() {
    return {
      'transactionId': transactionId,
      'category': category,
      'date': date,
      'amount': amount,
      'description': description
    };
  }

  static TransactionEntity fromDocument(Map<String, dynamic> doc) {
    return TransactionEntity(
      transactionId: doc['transactionId'],
      category: doc['category'],
      date: (doc['date'] as Timestamp).toDate(),
      amount: doc['amount'],
      description: doc['description']
    );
  }
}