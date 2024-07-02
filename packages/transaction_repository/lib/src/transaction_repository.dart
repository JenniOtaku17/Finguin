import '../transaction_repository.dart';

abstract class TransactionRepository {

  Future<void> createCategory(Category category);

  Future<List<Category>> getCategories();

  Future<bool> deleteCategory(Category category);

  Future<bool> createTransaction(Transaction transaction);

  Future<List<Transaction>> getTransactions();

  Future<List<Transaction>> getFilteredTransactions(int month, int year);

  Future<void> deleteTransaction(Transaction transaction);
}