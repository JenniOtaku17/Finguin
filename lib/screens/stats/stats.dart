import 'package:finguin/blocs/get_filteredtransactions_bloc/get_filteredtransactions_bloc.dart';
import 'package:finguin/components/month_picker.dart';
import 'package:finguin/screens/add_transaction/blocs/create_category_bloc/create_category_bloc.dart';
import 'package:finguin/screens/add_transaction/blocs/create_transaction_bloc/create_transaction_bloc.dart';
import 'package:finguin/screens/add_transaction/blocs/get_categories_bloc/get_categories_bloc.dart';
import 'package:finguin/screens/stats/chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadTransactionsForCurrentMonth();
  }

  void _loadTransactionsForCurrentMonth() {
    final transactionsBloc = BlocProvider.of<GetFilteredTransactionsBloc>(context);
    transactionsBloc.add(GetFilteredTransactions(month: _selectedDate.month, year: _selectedDate.year));
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
              }
            },
          ),
        ],
              child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
                child: Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Stats',
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
                                    color: Theme.of(context).colorScheme.primary,
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
                                if (transactionsState is GetFilteredTransactionsLoading ||
                                    categoriesState is GetCategoriesLoading) {
                                  return  Center(
                                    child: Image.asset(
                                      'assets/loading.gif',
                                        width: 300,
                                    ),
                                  );
                                } else if (transactionsState is GetFilteredTransactionsSuccess &&
                                           categoriesState is GetCategoriesSuccess) {
                                  return Column(
                                    children: [
                                      Container(
                                        width: MediaQuery.of(context).size.width,
                                        height: MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: MyChart(
                                            transactions: transactionsState.transactions,
                                            categories: categoriesState.categories),
                                      ),
                                      const SizedBox(height: 20),
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount: categoriesState.categories.length,
                                          itemBuilder: (context, int i) {
                                            double total = 0;
                                            for (var transaction in transactionsState.transactions) {
                                              if (transaction.category == categoriesState.categories[i].categoryId) {
                                                total += transaction.amount;
                                              }
                                            }
                                            return Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Image.asset(
                                                          'assets/${categoriesState.categories[i].icon}.png',
                                                          scale: 1,
                                                          color: Color(categoriesState.categories[i].color),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Column(
                                                          children: [
                                                            Text(
                                                              categoriesState.categories[i].name,
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: Theme.of(context).colorScheme.onBackground,
                                                                fontWeight: FontWeight.w500,
                                                              ),
                                                            ),
                                                            const SizedBox(height: 2),
                                                            Text(
                                                              categoriesState.categories[i].type == '-'
                                                                ? 'Deduction'
                                                                : 'Addition',
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: Theme.of(context).colorScheme.outline,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.end, // Alinea a la izquierda
                                                      children: [
                                                        Text(
                                                          'Max amount: ${NumberFormat.currency(locale: 'en_US', symbol: '\$').format(categoriesState.categories[i].maxAmount)}',
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            color: Theme.of(context).colorScheme.onBackground,
                                                            fontWeight: FontWeight.w300,
                                                          ),
                                                        ),
                                                        Text(
                                                          'Transactions total: ${NumberFormat.currency(locale: 'en_US', symbol: '\$').format(total)}',
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            color: Theme.of(context).colorScheme.onBackground,
                                                            fontWeight: FontWeight.w300,
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                                i == (categoriesState.categories.length - 1)? Container() :
                                                const Divider(
                                                  color:  Colors.white,
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      )
                                    ],
                                  );
                                } else {
                                  return Container();
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
}
