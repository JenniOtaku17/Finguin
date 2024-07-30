import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:transaction_repository/transaction_repository.dart';
import 'package:uuid/uuid.dart';

import '../blocs/create_category_bloc/create_category_bloc.dart';

Future getCategoryCreation(BuildContext context, Category category) {

  final Category originalCategory;
  category != Category.empty ? originalCategory = category : originalCategory = Category.empty;

  // Crear una copia de la categoría para editar
  Category editableCategory = Category(
    categoryId: category.categoryId,
    name: category.name,
    maxAmount: category.maxAmount,
    type: category.type,
    color: category.color,
    icon: category.icon,
  );

  List<String> categoriesTypes = ["+", "-"];

  List<String> categoriesIcons = [
    "cart", 
    "medical-bag", 
    "multimedia", 
    "account-group", 
    "account",
    "airplane", 
    "bank", 
    "car", 
    "cellphone-basic", 
    "church",
    "face-man", 
    "face-woman", 
    "food", 
    "fuel", 
    "handshake",
    "heart", 
    "home", 
    "home-lightning-bolt", 
    "human-male-female-child",
    "pig-variant", 
    "school", 
    "alien", 
    "shape", 
    "shape-plus", 
    "store", 
    "water", 
    "web"
  ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isFormValid = false;

  bool iconIsExpended = false;
  bool typeIsExpended = false;
  bool isLoading = false;

  TextEditingController categoryNameController = TextEditingController();
  TextEditingController categoryTypeController = TextEditingController();
  TextEditingController categoryMaxAmountController = TextEditingController(); 

  categoryNameController.text = editableCategory.name;
  editableCategory.color == 0 ? editableCategory.color = 4294967295 : null;
  editableCategory.maxAmount != 0 ? categoryMaxAmountController.text = editableCategory.maxAmount.toString() : null;
  editableCategory.type == '-' ? categoryTypeController.text = 'Deduction' : editableCategory.type == '+' ? categoryTypeController.text = 'Addition' : null;

  return showDialog(
    context: context,
    builder: (ctx) {
      return BlocProvider.value(
        value: context.read<CreateCategoryBloc>(),
        child: StatefulBuilder(
          builder: (ctx, setState) {
            return BlocListener<CreateCategoryBloc, CreateCategoryState>(
              listener: (context, state) {
                if (state is CreateCategorySuccess) {
                  _formKey.currentState?.reset();
                  categoryNameController.clear();
                  categoryTypeController.clear();
                  categoryMaxAmountController.clear();
                  setState(() {
                    isLoading = false;
                    _isFormValid = false;
                    iconIsExpended = false;
                    typeIsExpended = false;
                    editableCategory = Category.empty;
                  });

                  if(originalCategory != Category.empty){
                    Navigator.pop(context);
                  }
                  
                } else if (state is CreateCategoryLoading) {
                  setState(() {
                    isLoading = true;
                  });
                } else if (state is CreateCategoryFailure) {
                  setState(() {
                    isLoading = false; // Stop loading
                  });
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to save category. Please try again.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: AlertDialog(
                title: const Text('Category Creation'),
                content: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Form(
                    key: _formKey,
                    onChanged: () {
                      setState(() {
                        _isFormValid = _formKey.currentState?.validate() ?? false;
                      });
                    },
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: categoryNameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a name';
                              }
                              return null;
                            },
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              isDense: true,
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: categoryTypeController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a type';
                              }
                              return null;
                            },
                            textAlignVertical: TextAlignVertical.center,
                            readOnly: true,
                            onTap: () {
                              setState(() {
                                typeIsExpended = !typeIsExpended;
                                iconIsExpended = false;
                              });
                            },
                            decoration: InputDecoration(
                              isDense: true,
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Type',
                              prefixIcon: Icon(
                                editableCategory.type == '-' ? FontAwesomeIcons.minus : 
                                editableCategory.type == '+' ? FontAwesomeIcons.plus:
                                FontAwesomeIcons.plusMinus,
                                size: 16,
                              ),
                              suffixIcon: const Icon(CupertinoIcons.chevron_down, size: 12),
                              border: OutlineInputBorder(
                                borderRadius: typeIsExpended
                                    ? const BorderRadius.vertical(top: Radius.circular(12))
                                    : BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          typeIsExpended
                              ? Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 120,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ListView.builder(
                                      itemCount: categoriesTypes.length,
                                      itemBuilder: (context, int i) {
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              editableCategory.type = categoriesTypes[i];
                                              editableCategory.type == '-'
                                                  ? categoryTypeController.text = 'Deduction'
                                                  : categoryTypeController.text = "Addition";
                                              typeIsExpended = false;
                                            });
                                          },
                                          child: ListTile(
                                            leading: Icon(
                                              categoriesTypes[i] == '-'
                                                  ? FontAwesomeIcons.minus
                                                  : FontAwesomeIcons.plus,
                                              size: 16,
                                            ),
                                            title: Text(
                                              categoriesTypes[i] == '-' ? "Deduction" : "Addition",
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                )
                              : Container(),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: categoryMaxAmountController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a max amount';
                              }
                              return null;
                            },
                            textAlignVertical: TextAlignVertical.center,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              isDense: true,
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Maximun amount',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            onTap: () {
                              setState(() {
                                iconIsExpended = !iconIsExpended;
                                typeIsExpended = false;
                              });
                            },
                            textAlignVertical: TextAlignVertical.center,
                            readOnly: true,
                            decoration: InputDecoration(
                              isDense: true,
                              filled: true,
                              suffixIcon: editableCategory.icon != ''?
                              ImageIcon(
                                AssetImage("assets/${editableCategory.icon}.png"),
                                size: 24,
                              )
                              :const Icon(CupertinoIcons.chevron_down, size: 12),
                              fillColor: Colors.white,
                              hintText: 'Icon',
                              border: OutlineInputBorder(
                                borderRadius: iconIsExpended
                                    ? const BorderRadius.vertical(top: Radius.circular(12))
                                    : BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          iconIsExpended
                              ? Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 178,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GridView.builder(
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        mainAxisSpacing: 5,
                                        crossAxisSpacing: 5,
                                      ),
                                      itemCount: categoriesIcons.length,
                                      itemBuilder: (context, int i) {
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              editableCategory.icon = categoriesIcons[i];
                                              iconIsExpended = false;
                                              _isFormValid = _formKey.currentState?.validate() ?? false;
                                            });
                                          },
                                          child: Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                width: 3,
                                                color: editableCategory.icon == categoriesIcons[i]
                                                    ? Colors.green
                                                    : Colors.grey,
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                              image: DecorationImage(
                                                image: AssetImage('assets/${categoriesIcons[i]}.png'),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                )
                              : Container(),
                          const SizedBox(height: 16),
                          TextFormField(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (ctx2) {
                                  return AlertDialog(
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ColorPicker(
                                          pickerColor: Color(editableCategory.color),
                                          onColorChanged: (value) {
                                            setState(() {
                                              editableCategory.color = value.value;
                                              _isFormValid = _formKey.currentState?.validate() ?? false;
                                            });
                                          },
                                        ),
                                        SizedBox(
                                          width: double.infinity,
                                          height: 50,
                                          child: TextButton(
                                            onPressed: () {
                                              Navigator.pop(ctx2);
                                            },
                                            style: TextButton.styleFrom(
                                              backgroundColor: Colors.black,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: const Text(
                                              'Save Color',
                                              style: TextStyle(fontSize: 22, color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            textAlignVertical: TextAlignVertical.center,
                            readOnly: true,
                            decoration: InputDecoration(
                              isDense: true,
                              filled: true,
                              fillColor: Colors.white,
                              suffixIcon: Icon(
                                CupertinoIcons.app_fill,
                                size: 30,
                                color: Color(editableCategory.color),
                              ),
                              hintText: 'Color',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: kToolbarHeight,
                            child: isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : TextButton(
                                    onPressed: _isFormValid
                                    ? () {
                                        String id;
                                        editableCategory.categoryId == '' ? id = const Uuid().v1() : id = editableCategory.categoryId;

                                        editableCategory = Category(
                                          categoryId: id,
                                          name: categoryNameController.text,
                                          maxAmount: double.parse(categoryMaxAmountController.text),
                                          type: editableCategory.type,
                                          color: editableCategory.color,
                                          icon: editableCategory.icon,
                                        );

                                        context.read<CreateCategoryBloc>().add(CreateCategory(editableCategory));
                                      }
                                    : null,
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'Save',
                                      style: TextStyle(fontSize: 22, color: Colors.white),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    },
  );
}