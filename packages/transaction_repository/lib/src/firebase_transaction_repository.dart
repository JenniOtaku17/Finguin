import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../transaction_repository.dart';
import 'package:transaction_repository/src/models/models.dart' as repo;

class FirebaseTransactionRepository implements TransactionRepository {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final usersCollection = FirebaseFirestore.instance.collection('users');

  FirebaseTransactionRepository() {
    _auth.setPersistence(Persistence.LOCAL);
  }

  @override
  Future<void> createCategory(Category category) async {
    try{
      DocumentReference userDoc = usersCollection.doc(_auth.currentUser!.uid.toString());
      CollectionReference categoryCollection = userDoc.collection('categories');

      await categoryCollection
          .doc(category.categoryId)
          .set(category.toEntity().toDocument(), SetOptions(merge: true));
 
    }catch(e){
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<Category>> getCategories() async {
    try{
      DocumentReference userDoc = usersCollection.doc(_auth.currentUser!.uid.toString());
      CollectionReference categoryCollection = userDoc.collection('categories');

      return await categoryCollection
        .orderBy('name')
        .get()
        .then((value) => value.docs.map((e) => 
          Category.fromEntity(CategoryEntity.fromDocument(e.data() as Map<String, dynamic>))
        ).toList());
 
    }catch(e){
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<bool> createTransaction(repo.Transaction transaction) async {
    try{
      List<repo.Transaction> trans = [];
      DocumentReference userDoc = usersCollection.doc(_auth.currentUser!.uid.toString());
      CollectionReference categoryCollection = userDoc.collection('categories');
      CollectionReference transactionCollection = userDoc.collection('transactions');

      
      await transactionCollection
      .where('category', isEqualTo: transaction.category)
      .get()
      .then((value) => value.docs.map((e) => 
        trans.add(repo.Transaction.fromEntity(TransactionEntity.fromDocument(e.data() as Map<String, dynamic>)))
      ).toList());

      double total = 0;
      if(trans.isNotEmpty){
        for(var tran in trans){
            total += tran.amount;
        }
      }

      DocumentSnapshot categorySnapshot = await categoryCollection
        .doc(transaction.category)
        .get();

      Category category = Category.fromEntity(CategoryEntity.fromDocument(categorySnapshot.data() as Map<String, dynamic>));

      print(transaction.transactionId);

      if ((total + transaction.amount <= category.maxAmount) == true) {
        await transactionCollection
        .doc(transaction.transactionId)
        .set(transaction.toEntity().toDocument(), SetOptions(merge: true));

        return true;
      }else{
        return false;
      }
 
    }catch(e){
      print('Error');
      print(e.toString());
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<repo.Transaction>> getTransactions() async {
    try{
      DocumentReference userDoc = usersCollection.doc(_auth.currentUser!.uid.toString());
      CollectionReference transactionCollection = userDoc.collection('transactions');

      return await transactionCollection
        .orderBy('date', descending: true)
        .get()
        .then((value) => value.docs.map((e) => 
          repo.Transaction.fromEntity(TransactionEntity.fromDocument(e.data() as Map<String, dynamic>))
        ).toList());
 
    }catch(e){
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<repo.Transaction>> getFilteredTransactions(int month, int year) async {
    try{
      DocumentReference userDoc = usersCollection.doc(_auth.currentUser!.uid.toString());
      CollectionReference transactionCollection = userDoc.collection('transactions');

      DateTime firstDayOfMonth = DateTime(year, month, 1);
      DateTime lastDayOfMonth = DateTime(year, month + 1, 0);

      return await transactionCollection
         .where('date', isGreaterThanOrEqualTo: firstDayOfMonth, isLessThanOrEqualTo: lastDayOfMonth)
        .orderBy('date', descending: true)
        .get()
        .then((value) => value.docs.map((e) => 
          repo.Transaction.fromEntity(TransactionEntity.fromDocument(e.data() as Map<String, dynamic>))
        ).toList());
 
    }catch(e){
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<bool> deleteCategory(Category category) async {
    try{
      DocumentReference userDoc = usersCollection.doc(_auth.currentUser!.uid.toString());
      CollectionReference transactionCollection = userDoc.collection('transactions');
      CollectionReference categoryCollection = userDoc.collection('categories');

      final transactions = await transactionCollection
      .where('category', isEqualTo: category.categoryId)
      .get()
      .then((value) => value.docs.map((e) => 
        repo.Transaction.fromEntity(TransactionEntity.fromDocument(e.data() as Map<String, dynamic>))
      ).toList());

      if(transactions.isNotEmpty){
        return false;
      }else{
        await categoryCollection
        .doc(category.categoryId)
        .delete();
        return true;
      }
 
    }catch(e){
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> deleteTransaction(repo.Transaction transaction) async {
    try{
      DocumentReference userDoc = usersCollection.doc(_auth.currentUser!.uid.toString());
      CollectionReference transactionCollection = userDoc.collection('transactions');
      
      await transactionCollection
        .doc(transaction.transactionId)
        .delete();
 
    }catch(e){
      log(e.toString());
      rethrow;
    }
  }

}