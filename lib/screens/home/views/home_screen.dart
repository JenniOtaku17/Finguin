import 'dart:convert';
import 'package:finguin/screens/add_transaction/blocs/create_category_bloc/create_category_bloc.dart';
import 'package:finguin/screens/add_transaction/blocs/create_transaction_bloc/create_transaction_bloc.dart';
import 'package:finguin/screens/add_transaction/blocs/delete_category_bloc/delete_category_bloc.dart';
import 'package:finguin/screens/add_transaction/blocs/delete_transaction_bloc/delete_transaction_bloc.dart';
import 'package:finguin/screens/auth/blocs/get_current_user/get_current_user_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finguin/screens/add_transaction/views/add_transaction.dart';
import 'package:finguin/screens/add_transaction/views/categories.dart';
import 'package:finguin/screens/add_transaction/views/transactions.dart';
import 'package:finguin/screens/home/blocs/get_transactions_bloc/get_transactions_bloc.dart';
import 'package:finguin/screens/home/views/main_screen.dart';
import 'package:finguin/screens/stats/stats.dart';
import 'package:internet_connectivity_checker/internet_connectivity_checker.dart';
import 'package:localstorage/localstorage.dart';
import 'package:transaction_repository/transaction_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;
  late Color selectedItem = Colors.blue;
  Color unselectedItem = Colors.grey;

  @override
  Widget build(BuildContext context) {
    return ConnectivityBuilder(
      interval: const Duration(seconds: 300),
      builder: (ConnectivityStatus status) {
        print('this feels like home');

        if (status == ConnectivityStatus.online) {
          _verifyOfflineData();
        }

        return BlocBuilder<GetTransactionsBloc, GetTransactionsState>(
          builder: (context, state) {
            if (state is GetTransactionsSuccess) {
              return Scaffold(
                bottomNavigationBar: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(30)),
                  child: BottomNavigationBar(
                    currentIndex: index,
                    onTap: (value) {
                      setState(() {
                        index = value;
                      });
                    },
                    showSelectedLabels: false,
                    showUnselectedLabels: false,
                    elevation: 3,
                    items: [
                      BottomNavigationBarItem(
                        icon: Icon(
                          CupertinoIcons.home,
                          color: index == 0 ? selectedItem : unselectedItem,
                        ),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(
                          CupertinoIcons.rectangle_3_offgrid_fill,
                          color: index == 1 ? selectedItem : unselectedItem,
                        ),
                        label: 'Categories',
                      ),
                      BottomNavigationBarItem(
                        
                        icon: GestureDetector(
                          child: Container(),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddTransaction(transaction: Transaction.empty),
                              ),
                            );
                          }
                        ), // Empty space in the middle
                        label: '',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(
                          CupertinoIcons.creditcard_fill,
                          color: index == 3 ? selectedItem : unselectedItem,
                        ),
                        label: 'Transactions',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(
                          CupertinoIcons.graph_square_fill,
                          color: index == 4 ? selectedItem : unselectedItem,
                        ),
                        label: 'Stats',
                      ),
                    ],
                  ),
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerDocked,
                floatingActionButton: FloatingActionButton(
                  onPressed: () async {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            AddTransaction(transaction: Transaction.empty),
                      ),
                    );
                  },
                  shape: const CircleBorder(),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.tertiary,
                          Theme.of(context).colorScheme.secondary,
                          Theme.of(context).colorScheme.primary,
                        ],
                        transform: const GradientRotation(3.16 / 4),
                      ),
                    ),
                    child: const Icon(CupertinoIcons.add),
                  ),
                ),
                body: index == 0
                    ? const MainScreen()
                    : index == 1
                        ?  const CategoriesPage()
                        : index == 3
                            ? const TransactionsPage()
                            : index == 4
                                ? const StatsScreen()
                                : Container(
                                  child: Text('oh oh oh')
                                ),
              );
            } else {
              return Scaffold(
                body: Center(
                  child: Image.asset(
                  'assets/loading.gif',
                    width: 300,
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }

  void _verifyOfflineData() {
    try {
      String? transactionsJson = localStorage.getItem('transactionsAction');
      String? categoriesJson = localStorage.getItem('categoriesAction');

      if (transactionsJson != null && transactionsJson.isNotEmpty) {
        List<dynamic> decodedTransactions = jsonDecode(transactionsJson);
        List<Transaction> transactionsAction =
            decodedTransactions.map((e) => Transaction.fromJson(e)).toList();

        for (Transaction transaction in transactionsAction) {
          if (transaction.category == 'delete') {
            context
                .read<DeleteTransactionBloc>()
                .add(DeleteTransaction(transaction));
          } else {
            context
                .read<CreateTransactionBloc>()
                .add(CreateTransaction(transaction));
          }
        }
        localStorage.removeItem('transactionsAction');
      }

      if (categoriesJson != null && categoriesJson.isNotEmpty) {
        List<dynamic> decodedCategories = jsonDecode(categoriesJson);
        List<Category> categoriesAction =
            decodedCategories.map((e) => Category.fromJson(e)).toList();

        for (Category category in categoriesAction) {
          if (category.name == 'delete') {
            context.read<DeleteCategoryBloc>().add(DeleteCategory(category));
          } else {
            context.read<CreateCategoryBloc>().add(CreateCategory(category));
          }
        }
        localStorage.removeItem('categoriesAction');
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
