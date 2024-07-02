import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:transaction_repository/transaction_repository.dart';
import 'package:uuid/uuid.dart';
import 'package:finguin/screens/add_transaction/blocs/create_transaction_bloc/create_transaction_bloc.dart';
import 'package:finguin/screens/add_transaction/blocs/get_categories_bloc/get_categories_bloc.dart';
import 'package:finguin/screens/add_transaction/views/category_creation.dart';

class AddTransaction extends StatefulWidget {
  final Transaction? transaction;

  const AddTransaction({Key? key, this.transaction}) : super(key: key);

  @override
  State<AddTransaction> createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isFormValid = false;

  TextEditingController amountController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  bool isExpended = false;
  bool isLoading = false;
  String iconSelected = '';
  late Transaction transaction;
  late Transaction originalTransaction;

  @override
  void initState() {
    super.initState();
    transaction = widget.transaction ?? Transaction.empty;
    if (widget.transaction == Transaction.empty) {
      dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
      originalTransaction = Transaction.empty;

    } else {
      originalTransaction = transaction;
      amountController.text = widget.transaction!.amount.toString();
      dateController.text = DateFormat('dd/MM/yyyy').format(widget.transaction!.date);
      descriptionController.text = widget.transaction!.description;
    }
  }

  @override
  void dispose(){
    super.dispose();
    amountController.dispose();
    categoryController.dispose();
    dateController.dispose();
    descriptionController.dispose();
  }

  void _resetForm() {
    amountController.clear();
    categoryController.clear();
    dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    descriptionController.clear();

  
    setState(() {
      iconSelected = '';
      categoryController.text = '';
      isExpended = false;
      _isFormValid = false;
      isLoading = false;
      transaction = Transaction.empty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateTransactionBloc, CreateTransactionState>(
      listener: (context, state) {
        if (state is CreateTransactionSuccess) {
          _formKey.currentState?.reset();
          _resetForm();
          setState(() {
            isLoading = false; // Stop loading on success
          });

          if(originalTransaction != Transaction.empty){
            Navigator.pop(context);
          }

        } else if (state is CreateTransactionLoading) {
          setState(() {
            isLoading = true;
          });
        } else if (state is CreateTransactionFailure) {
          setState(() {
            isLoading = false; // Stop loading on failure
          });
          // Show error message
          CoolAlert.show(
            context: context,
            type: CoolAlertType.error,
            text: 'Category maximum amount exceeded',
          );
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.background,
          ),
          body: BlocBuilder<GetCategoriesBloc, GetCategoriesState>(
            builder: (context, state) {
              if (state is GetCategoriesSuccess) {
                if (widget.transaction != null) {
                  Category category = state.categories.firstWhere(
                      (category) => category.categoryId == widget.transaction!.category,
                      orElse: () => Category.empty);

                  iconSelected = category.icon;
                  categoryController.text = category.name;
                }

                return SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    height: MediaQuery.of(context).size.height,
                    child: Form(
                      key: _formKey,
                      onChanged: () {
                        setState(() {
                          _isFormValid = _formKey.currentState?.validate() ?? false;
                        });
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            "Add Transaction",
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.7,
                            child: TextFormField(
                              controller: amountController,
                              keyboardType: TextInputType.number,
                              textAlignVertical: TextAlignVertical.center,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select an amount.';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  prefixIcon: const Icon(
                                    FontAwesomeIcons.dollarSign,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide.none,
                                  )),
                            ),
                          ),
                          const SizedBox(height: 32),
                          TextFormField(
                            controller: categoryController,
                            textAlignVertical: TextAlignVertical.center,
                            readOnly: true,
                            onTap: () {
                              setState(() {
                                isExpended = !isExpended;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a category.';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                prefixIcon: iconSelected.isEmpty
                                    ? const Icon(FontAwesomeIcons.list, size: 16, color: Colors.grey)
                                    : Image.asset('assets/$iconSelected.png', scale: 1),
                                suffixIcon: IconButton(
                                    onPressed: () async {
                                      var newCategory = await getCategoryCreation(context, Category.empty);
                                      setState(() {
                                        state.categories.insert(0, newCategory);
                                      });
                                    },
                                    icon: const Icon(FontAwesomeIcons.plus, size: 16, color: Colors.grey)),
                                hintText: "Category",
                                border: OutlineInputBorder(
                                    borderRadius: isExpended
                                        ? const BorderRadius.vertical(top: Radius.circular(12))
                                        : BorderRadius.circular(12),
                                    borderSide: BorderSide.none)),
                          ),
                          isExpended
                              ? Container(
                                  height: 200,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: const BoxDecoration(
                                      color: Colors.white, borderRadius: BorderRadius.vertical(bottom: Radius.circular(12))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: state.categories.isNotEmpty
                                        ? ListView.builder(
                                            itemCount: state.categories.length,
                                            itemBuilder: (context, int i) {
                                              return Card(
                                                child: ListTile(
                                                    onTap: () {
                                                      setState(() {
                                                        transaction.category = state.categories[i].categoryId;
                                                        iconSelected = state.categories[i].icon;
                                                        categoryController.text = state.categories[i].name;
                                                        isExpended = false; // Collapse the dropdown after selection
                                                      });
                                                    },
                                                    leading: Stack(
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
                                                      ]),
                                                    title: Text(state.categories[i].name),
                                                    tileColor: Colors.white,
                                                    shape: RoundedRectangleBorder(borderRadius:
                                                        BorderRadius.circular(8))),
                                              );
                                            })
                                        : const Center(
                                            child: Text("No hay categorias creadas"),
                                          ),
                                  ),
                                )
                              : Container(),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: dateController,
                            textAlignVertical: TextAlignVertical.center,
                            readOnly: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a date.';
                              }
                              return null;
                            },
                            onTap: () async {
                              DateTime? newDate = await showDatePicker(
                                  context: context,
                                  initialDate: transaction.date,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 365)));

                              if (newDate != null) {
                                setState(() {
                                  dateController.text = DateFormat('dd/MM/yyyy').format(newDate);
                                  transaction.date = newDate;
                                });
                              }
                            },
                            decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                prefixIcon: const Icon(FontAwesomeIcons.clock, size: 16, color: Colors.grey),
                                hintText: "Date",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                )),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: descriptionController,
                            minLines: 3,
                            maxLines: 3,
                            decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                hintText: "Description",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                )),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: kToolbarHeight,
                            child: isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : TextButton(
                                    onPressed: _isFormValid
                                        ? () {
                                            String id;
                                            transaction.transactionId == ''? id = const Uuid().v1() : id = transaction.transactionId;

                                            setState(() {
                                              transaction = Transaction(
                                                transactionId: id,
                                                amount: double.parse(amountController.text),
                                                category: transaction.category,
                                                date: transaction.date,
                                                description: descriptionController.text,
                                              );
                                            });

                                            context.read<CreateTransactionBloc>().add(CreateTransaction(transaction));
                                          }
                                        : null,
                                    style: TextButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                    child: const Text(
                                      "Save",
                                      style: TextStyle(
                                        fontSize: 22,
                                        color: Colors.white,
                                      ),
                                    )),
                          )
                        ],
                      ),
                    ),
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
      ),
    );
  }
}