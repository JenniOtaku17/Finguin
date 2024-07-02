import 'package:finguin/blocs/get_filteredtransactions_bloc/get_filteredtransactions_bloc.dart';
import 'package:finguin/components/month_picker.dart';
import 'package:finguin/screens/add_transaction/blocs/delete_transaction_bloc/delete_transaction_bloc.dart';
import 'package:finguin/screens/add_transaction/views/add_transaction.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:transaction_repository/transaction_repository.dart';
import 'package:finguin/screens/add_transaction/blocs/get_categories_bloc/get_categories_bloc.dart';
import 'package:finguin/screens/add_transaction/blocs/create_category_bloc/create_category_bloc.dart';
import 'package:finguin/screens/add_transaction/blocs/create_transaction_bloc/create_transaction_bloc.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({Key? key}) : super(key: key);

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  String isDeleting = '';
  Transaction? _deletedTransaction;
  int? _deletedTransactionIndex;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadTransactionsForCurrentMonth();
  }

  void _loadTransactionsForCurrentMonth() {
    final bloc = BlocProvider.of<GetFilteredTransactionsBloc>(context);
    bloc.add(GetFilteredTransactions(
        month: _selectedDate.month, year: _selectedDate.year));
  }

  void _loadCategories() {
    final categoriesBloc = BlocProvider.of<GetCategoriesBloc>(context);
    categoriesBloc.add(GetCategories());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CreateCategoryBloc, CreateCategoryState>(
          listener: (context, state) {
            if (state is CreateCategorySuccess) {
              _loadCategories();
            }
          },
        ),
        BlocListener<CreateTransactionBloc, CreateTransactionState>(
          listener: (context, state) {
            if (state is CreateTransactionSuccess) {
              _loadTransactionsForCurrentMonth();
            }else if( state is CreateTransactionFailure){

              if (_deletedTransaction != null && _deletedTransactionIndex != null) {
                setState(() {
                    isDeleting = '';
                    context.read<GetCategoriesBloc>().add(GetCategories());
                    _deletedTransaction = null;
                    _deletedTransactionIndex = null;
                });
              }
            }
          },
        ),
      ],
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _loadTransactionsForCurrentMonth();
            _loadCategories();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Transactions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await showMonthPicker(context, _selectedDate, (DateTime pickedDate) {
                          setState(() {
                            _selectedDate = pickedDate;
                          });
                        }, _loadTransactionsForCurrentMonth);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('MMMM yyyy').format(_selectedDate),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color:
                                  Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: BlocBuilder<GetFilteredTransactionsBloc, GetFilteredTransactionsState>(
                    builder: (context, transactionsState) {
                      return BlocBuilder<GetCategoriesBloc, GetCategoriesState>(
                        builder: (context, categoriesState) {
                          if (transactionsState is GetFilteredTransactionsSuccess && categoriesState is GetCategoriesSuccess) {
                            return transactionsState.transactions.isNotEmpty
                                ? ListView.builder(
                                    itemCount: transactionsState.transactions.length,
                                    itemBuilder: (context, int i) {
                                      Transaction transaction = transactionsState.transactions[i];
                                      Category category = categoriesState.categories.firstWhere(
                                          (category) => category.categoryId == transaction.category,
                                          orElse: () => Category.empty);
                                      
                                      return Padding(
                                          padding: const EdgeInsets.only(bottom: 16.0),
                                          child: Dismissible(
                                            key: Key(transactionsState.transactions[i].transactionId.toString()),
                                            onUpdate: (details) {
                                              if (details.progress == 0.0) {
                                                setState(() {
                                                  isDeleting = '';
                                                });
                                              } else {
                                                setState(() {
                                                  isDeleting = transactionsState.transactions[i].transactionId;
                                                });
                                              }
                                            },
                                            direction: DismissDirection.endToStart,
                                            confirmDismiss: (direction) async {
                                              final result = await _showDeleteDialog(context, transactionsState.transactions[i]);
                                              if (result == true) {
                                                setState(() {
                                                  _deletedTransaction = transactionsState.transactions.removeAt(i);
                                                  _deletedTransactionIndex = i;
                                                });
                                              }
                                              return result;
                                            },
                                            background: Container(
                                              padding: const EdgeInsets.only(right: 20.0),
                                              alignment: Alignment.centerRight,
                                              decoration: const BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(0),
                                                  topRight: Radius.circular(12),
                                                  bottomLeft: Radius.circular(0),
                                                  bottomRight: Radius.circular(12),
                                                ),
                                                color: Color.fromARGB(255, 146, 31, 23),
                                              ),
                                              child: const Icon(
                                                CupertinoIcons.trash,
                                                color: Colors.white,
                                              ),
                                            ),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.only(
                                                  topLeft: const Radius.circular(12),
                                                  bottomLeft: const Radius.circular(12),
                                                  topRight: isDeleting == transactionsState.transactions[i].transactionId ? const Radius.circular(0) : const Radius.circular(12),
                                                  bottomRight: isDeleting == transactionsState.transactions[i].transactionId ? const Radius.circular(0) : const Radius.circular(12),
                                                ),
                                              ),
                                              child: SingleChildScrollView(
                                                child: Container(
                                                  padding: const EdgeInsets.all(16.0),
                                                  width: MediaQuery.of(context).size.width,
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Stack(
                                                                alignment: Alignment.center,
                                                                children: [
                                                                  Container(
                                                                    width: 50,
                                                                    height: 50,
                                                                    decoration: BoxDecoration(
                                                                      color: Color(category.color),
                                                                      shape: BoxShape.circle,
                                                                    ),
                                                                  ),
                                                                  Image.asset(
                                                                    'assets/${category.icon}.png',
                                                                    scale: 1,
                                                                    color: Colors.white,
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(width: 12),
                                                              Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Row(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Text(
                                                                        category.name,
                                                                        style: TextStyle(
                                                                          fontSize: 14,
                                                                          color: Theme.of(context).colorScheme.onBackground,
                                                                          fontWeight: FontWeight.w400,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(width: 5),
                                                                      Text(
                                                                        '${category.type} ${NumberFormat.currency(locale: 'en_US', symbol: '\$').format(transaction.amount)}',
                                                                        style: TextStyle(
                                                                          fontSize: 14,
                                                                          color: category.type == '-' ? Colors.red : Colors.green,
                                                                          fontWeight: FontWeight.w500,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Text(
                                                                        DateFormat('dd/MM/yyyy').format(transaction.date),
                                                                        style: TextStyle(
                                                                          fontSize: 12,
                                                                          color: Theme.of(context).colorScheme.outline,
                                                                          fontWeight: FontWeight.w400,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                          Column(
                                                            crossAxisAlignment: CrossAxisAlignment.end,
                                                            children: [
                                                              IconButton(
                                                                onPressed: () {
                                                                  Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder: (context) => AddTransaction(transaction: transaction),
                                                                    ),
                                                                  );
                                                                },
                                                                icon: const Icon(
                                                                  CupertinoIcons.pencil_circle_fill,
                                                                  color: Color.fromARGB(255, 90, 90, 90),
                                                                  size: 26,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 10),
                                                      transaction.description.isNotEmpty
                                                          ? Row(
                                                              children: [
                                                                Flexible(
                                                                  child: Text(
                                                                    'Comment: ${transaction.description}',
                                                                    style: TextStyle(
                                                                      fontSize: 12,
                                                                      color: Theme.of(context).colorScheme.outline,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                          : Container(),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ));
                                    })
                                : Center(
                                  child: Image.asset(
                                    'assets/no-data.png',
                                    scale: 1,
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
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showDeleteDialog(BuildContext context, Transaction transaction) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text("Delete Transaction"),
          content: Text('Are you sure that you want to delete transaction for \$${transaction.amount}?'),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(ctx).pop(false);
              },
            ),
            TextButton(
              child: const Text("Continue"),
              onPressed: () {
                BlocProvider.of<DeleteTransactionBloc>(ctx).add(DeleteTransaction(transaction));
                Navigator.of(ctx).pop(true); // Cerrar el diálogo y confirmar la eliminación
              },
            ),
          ],
        );
      },
    );
  }
}