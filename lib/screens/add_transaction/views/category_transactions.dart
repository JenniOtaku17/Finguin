import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:transaction_repository/transaction_repository.dart';

import 'package:finguin/components/month_picker.dart';
import 'package:finguin/screens/add_transaction/blocs/get_category_transactions_bloc/get_category_transactions_bloc.dart';

class CategoryTransactions extends StatefulWidget {
  final Category category;

  const CategoryTransactions({Key? key, required this.category})
      : super(key: key);

  @override
  State<CategoryTransactions> createState() => _CategoryTransactionsState();
}

class _CategoryTransactionsState extends State<CategoryTransactions> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = null;
    _loadTransactionsForCategory();
  }

  void _loadTransactionsForCategory() {
    final bloc = BlocProvider.of<GetCategoryTransactionsBloc>(context);
    bloc.add(GetCategoryTransactions(
      category: widget.category.categoryId,
      month: _selectedDate?.month,
      year: _selectedDate?.year,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Transactions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    await showMonthPicker(context, _selectedDate,
                        (DateTime pickedDate) {
                      setState(() {
                        _selectedDate = pickedDate;
                      });
                      _loadTransactionsForCategory();
                    }, _loadTransactionsForCategory);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _selectedDate != null
                            ? DateFormat('MMMM yyyy').format(_selectedDate!)
                            : 'Filter',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                _selectedDate != null
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            _selectedDate = null;
                          });
                          _loadTransactionsForCategory();
                        },
                        icon: const Icon(Icons.close, size: 24),
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : Container(),
              ],
            ),
          ],
        ),
      ),
      body: BlocBuilder<GetCategoryTransactionsBloc, GetCategoryTransactionsState>(
      builder: (context, transactionsState) {
        if (transactionsState is GetCategoryTransactionsSuccess) {
          if (transactionsState.transactions.isEmpty) {
            return Center(
              child: Image.asset(
                'assets/no-data.png',
                width: 500,
              )
            );
          }

          // Resto del código para mostrar las transacciones
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
            child: Column(
              children: [
                Text(
                  '${widget.category.name} Total: ${NumberFormat.currency(locale: 'en_US', symbol: '\$').format(
                    transactionsState.transactions.isNotEmpty?
                    transactionsState.transactions
                    .where((transaction) => transaction.category == widget.category.categoryId).isNotEmpty?
                    transactionsState.transactions
                    .where((transaction) => transaction.category == widget.category.categoryId)
                    .map((transaction) => transaction.amount)
                    .reduce((value, element) => value + element)
                    : 0
                    : 0
                  )}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: transactionsState.transactions.length,
                    itemBuilder: (context, int i) {
                      Transaction transaction = transactionsState.transactions[i];
                      Category category = widget.category;

                      if (transaction.category == category.categoryId) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: SingleChildScrollView(
                              child: Container(
                                padding: const EdgeInsets.all(16.0),
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  children: [
                                    const SizedBox(width: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
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
                                            Text(
                                              category.name,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Theme.of(context).colorScheme.onBackground,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '${category.type} ${NumberFormat.currency(locale: 'en_US', symbol: '\$').format(transaction.amount)}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: category.type == '-' ? Colors.red : Theme.of(context).colorScheme.onBackground,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            Text(
                                              DateFormat('dd/MM/yyyy').format(transaction.date),
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Theme.of(context).colorScheme.outline,
                                                fontWeight: FontWeight.w400,
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
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        }  else if (transactionsState is GetCategoryTransactionsLoading) {
          return Center(
            child: Image.asset(
              'assets/loading.gif',
              width: 500,
            )
          );
        } else if (transactionsState is GetCategoryTransactionsFailure) {
          return Center(
            child: Text('Failed to load transactions'),
          );
        } else {
          return Center(
            child: Text('Unknown state'),
          );
        }
      },
    ),
    );
  }
}