import 'package:cool_alert/cool_alert.dart';
import 'package:finguin/screens/add_transaction/blocs/create_category_bloc/create_category_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finguin/screens/add_transaction/blocs/delete_category_bloc/delete_category_bloc.dart';
import 'package:finguin/screens/add_transaction/blocs/get_categories_bloc/get_categories_bloc.dart';
import 'package:finguin/screens/add_transaction/views/category_creation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:transaction_repository/transaction_repository.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({Key? key}) : super(key: key);

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  String isDeleting = '';
  Category? _deletedCategory;
  int? _deletedCategoryIndex;

  void _loadCategories() {
    final categoriesBloc = BlocProvider.of<GetCategoriesBloc>(context);
    categoriesBloc.add(GetCategories());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<DeleteCategoryBloc, DeleteCategoryState>(
          listener: (context, state) {
            if (state is DeleteCategoryFailure) {
              CoolAlert.show(
                context: context,
                type: CoolAlertType.error,
                text: 'This category has transactions',
                autoCloseDuration: const Duration(seconds: 3),
              );
              // Reinsert the category back into the list
              if (_deletedCategory != null && _deletedCategoryIndex != null) {
                setState(() {
                  isDeleting = '';
                  context.read<GetCategoriesBloc>().add(GetCategories());
                  _deletedCategory = null;
                  _deletedCategoryIndex = null;
                });
              }
            } else if (state is DeleteCategorySuccess) {
              // Optionally refresh the categories list
              context.read<GetCategoriesBloc>().add(GetCategories());
            }
          },
        ),
        BlocListener<CreateCategoryBloc, CreateCategoryState>(
          listener: (context, state) {
            if (state is CreateCategorySuccess) {
              _loadCategories();
            }
          },
        ),
      ],
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<GetCategoriesBloc>().add(GetCategories());
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await getCategoryCreation(context, Category.empty);
                      },
                      icon: const Icon(
                        FontAwesomeIcons.plus,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: BlocBuilder<GetCategoriesBloc, GetCategoriesState>(
                    builder: (context, state) {
                      if (state is GetCategoriesSuccess) {
                        return state.categories.isNotEmpty
                          ? ListView.builder(
                            itemCount: state.categories.length,
                            itemBuilder: (context, int i) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Dismissible(
                                  onUpdate: (details) {
                                    if (details.progress == 0.0) {
                                      setState(() {
                                        isDeleting = '';
                                      });
                                    } else {
                                      setState(() {
                                        isDeleting = state.categories[i].categoryId;
                                      });
                                    }
                                  },
                                  key: Key(state.categories[i].categoryId.toString()),
                                  direction: DismissDirection.endToStart,
                                  confirmDismiss: (direction) async {
                                    final result = await _showDeleteDialog(context, state.categories[i]);
                                    if (result == true) {
                                      setState(() {
                                        _deletedCategory = state.categories.removeAt(i);
                                        _deletedCategoryIndex = i;
                                      });
                                    }
                                    return result;
                                  },
                                  onDismissed: (direction) {
                                    // This callback is called when the Dismissible is actually dismissed
                                    // It can be used for additional actions if needed
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
                                        topRight: isDeleting == state.categories[i].categoryId
                                          ? const Radius.circular(0)
                                          : const Radius.circular(12),
                                        bottomRight: isDeleting == state.categories[i].categoryId
                                          ? const Radius.circular(0)
                                          : const Radius.circular(12),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
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
                                                      color: Color(state.categories[i].color),
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  Image.asset(
                                                    'assets/${state.categories[i].icon}.png',
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
                                                    children: [
                                                      Text(
                                                        state.categories[i].name,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Theme.of(context).colorScheme.onBackground,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 2),
                                                      Text(
                                                        state.categories[i].type == '-'
                                                          ? '(Deduction)'
                                                          : '(Addition)',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Theme.of(context).colorScheme.outline,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    state.categories[i].maxAmount != 0
                                                      ? 'Max. amount: ${NumberFormat.currency(locale: 'en_US', symbol: '\$').format(state.categories[i].maxAmount)}'
                                                      : 'Max. amount: None',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Theme.of(context).colorScheme.onBackground,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  getCategoryCreation(context, state.categories[i]);
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
                                    ),
                                  ),
                                ),
                              );
                            })
                          : Center(
                            child: Image.asset(
                              'assets/no-data.png',
                              width: 500,
                            ),
                          );
                      } else {
                        return Center(child: Image.asset(
                        'assets/loading.gif',
                          width: 300,
                        ),);
                      }
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

  Future<bool?> _showDeleteDialog(BuildContext context, Category category) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text("Delete Category"),
          content: Text('Are you sure that you want to delete ${category.name}?'),
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
                BlocProvider.of<DeleteCategoryBloc>(ctx).add(DeleteCategory(category));
                Navigator.of(ctx).pop(true); // Close the dialog and confirm deletion
              },
            ),
          ],
        );
      },
    );
  }
}