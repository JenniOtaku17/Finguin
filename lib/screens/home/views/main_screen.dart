import 'dart:io';

import 'package:finguin/blocs/get_filteredtransactions_bloc/get_filteredtransactions_bloc.dart';
import 'package:finguin/components/month_picker.dart';
import 'package:finguin/screens/add_transaction/blocs/create_category_bloc/create_category_bloc.dart';
import 'package:finguin/screens/add_transaction/blocs/create_transaction_bloc/create_transaction_bloc.dart';
import 'package:finguin/screens/add_transaction/blocs/get_categories_bloc/get_categories_bloc.dart';
import 'package:finguin/screens/auth/blocs/get_current_user/get_current_user_bloc.dart';
import 'package:finguin/screens/auth/views/profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:transaction_repository/transaction_repository.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  DateTime _selectedDate = DateTime.now();
  double totalIncome = 0;
  double totalExpenses = 0;

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
            }
          },
        ),
      ],
      child: BlocBuilder<GetCurrentUserBloc, GetCurrentUserState>(
        builder: (context, stateUser) {

          if(stateUser is GetCurrentUserSuccess){
          return SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      Profile(user: stateUser.user),
                                ),
                              );
                            },
                            child: ClipOval(
                              child:  (stateUser.user.photoURL.isNotEmpty && stateUser.user.photoURL != 'null')?
                              Image.file(
                                File(stateUser.user.photoURL),
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                              :Image.asset(
                                "assets/placeholder.png",
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome!',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                              Text(
                                stateUser.user!.displayName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () async {
                          await showMonthPicker(context, _selectedDate,
                              (DateTime pickedDate) {
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
                    child: BlocBuilder<GetCategoriesBloc, GetCategoriesState>(
                      builder: (context, categoriesState) {
                        if (categoriesState is GetCategoriesSuccess) {
                          return BlocBuilder<GetFilteredTransactionsBloc,
                              GetFilteredTransactionsState>(
                            builder: (context, transactionsState) {
                              if (transactionsState
                                  is GetFilteredTransactionsLoading) {
                                return Center(
                                  child: Image.asset(
                                    'assets/loading.gif',
                                    width: 300,
                                  ),
                                );
                              } else if (transactionsState
                                  is GetFilteredTransactionsSuccess) {
                                totalIncome = 0;
                                totalExpenses = 0;

                                for (var transaction
                                    in transactionsState.transactions) {
                                  var category =
                                      categoriesState.categories.firstWhere(
                                    (category) =>
                                        category.categoryId ==
                                        transaction.category,
                                    orElse: () => Category.empty,
                                  );

                                  if (category != Category.empty) {
                                    if (category.type == '+') {
                                      totalIncome += transaction.amount;
                                    } else {
                                      totalExpenses += transaction.amount;
                                    }
                                  }
                                }

                                return Column(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.width / 2,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            Theme.of(context)
                                                .colorScheme
                                                .tertiary,
                                          ],
                                          transform:
                                              const GradientRotation(3.16 / 4),
                                        ),
                                        borderRadius: BorderRadius.circular(25),
                                        boxShadow: [
                                          BoxShadow(
                                            blurRadius: 4,
                                            color: Colors.grey.shade300,
                                            offset: const Offset(5, 5),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'Total Balance',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            NumberFormat.currency(
                                              locale: 'en_US',
                                              symbol: '\$',
                                            ).format(
                                                totalIncome - totalExpenses),
                                            style: const TextStyle(
                                              fontSize: 40,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                              horizontal: 20,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: 25,
                                                      height: 25,
                                                      decoration:
                                                          const BoxDecoration(
                                                        color: Colors.white30,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: const Center(
                                                        child: Icon(
                                                          CupertinoIcons
                                                              .arrow_up,
                                                          size: 12,
                                                          color: Colors
                                                              .greenAccent,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Text(
                                                          'Income',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                        ),
                                                        Text(
                                                          NumberFormat.currency(
                                                            locale: 'en_US',
                                                            symbol: '\$',
                                                          ).format(totalIncome),
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: 25,
                                                      height: 25,
                                                      decoration:
                                                          const BoxDecoration(
                                                        color: Colors.white30,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: const Center(
                                                        child: Icon(
                                                          CupertinoIcons
                                                              .arrow_down,
                                                          size: 12,
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Text(
                                                          'Expenses',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                        ),
                                                        Text(
                                                          NumberFormat.currency(
                                                            locale: 'en_US',
                                                            symbol: '\$',
                                                          ).format(
                                                              totalExpenses),
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 40),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Transactions',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onBackground,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    transactionsState.transactions.isNotEmpty
                                        ? Expanded(
                                            child: ListView.builder(
                                              itemCount: transactionsState
                                                  .transactions.length,
                                              itemBuilder: (context, i) {
                                                final transaction =
                                                    transactionsState
                                                        .transactions[i];
                                                final category = categoriesState
                                                    .categories
                                                    .firstWhere(
                                                  (category) =>
                                                      category.categoryId ==
                                                      transaction.category,
                                                  orElse: () => Category.empty,
                                                );
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 16.0),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              16.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Stack(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                children: [
                                                                  Container(
                                                                    width: 50,
                                                                    height: 50,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Color(
                                                                          category
                                                                              .color),
                                                                      shape: BoxShape
                                                                          .circle,
                                                                    ),
                                                                  ),
                                                                  Image.asset(
                                                                    'assets/${category.icon}.png',
                                                                    scale: 1,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                  width: 12),
                                                              Text(
                                                                category.name,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 14,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .onBackground,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Text(
                                                                '${category.type} ${NumberFormat.currency(locale: 'en_US', symbol: '\$').format(transaction.amount)}',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 14,
                                                                  color: category.type ==
                                                                          '-'
                                                                      ? Colors
                                                                          .red
                                                                      : Theme.of(
                                                                              context)
                                                                          .colorScheme
                                                                          .onBackground,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                ),
                                                              ),
                                                              Text(
                                                                DateFormat(
                                                                        'dd/MM/yyyy')
                                                                    .format(
                                                                        transaction
                                                                            .date),
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 14,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .outline,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          )
                                        : Image.asset(
                                            'assets/no-data.png',
                                            width: 400,
                                          ),
                                  ],
                                );
                              } else {
                                return const Center(
                                    child: Text('There are any transaction'));
                              }
                            },
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );

          }else{
            return Center(
              child: Image.asset(
              'assets/loading.gif',
                width: 300,
              ),
            );
          }
        },
      ),
    );
  }
}
