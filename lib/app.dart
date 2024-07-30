import 'package:finguin/screens/add_transaction/blocs/get_category_transactions_bloc/get_category_transactions_bloc.dart';
import 'package:finguin/screens/auth/blocs/change_password_bloc/change_password_bloc.dart';
import 'package:finguin/screens/auth/blocs/logout_bloc/logout_bloc.dart';
import 'package:finguin/screens/auth/blocs/update_profile_bloc/update_profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:finguin/app_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finguin/screens/auth/blocs/login_bloc/login_bloc.dart';
import 'package:finguin/screens/auth/blocs/get_current_user/get_current_user_bloc.dart';
import 'package:finguin/screens/auth/blocs/register_bloc/register_bloc_bloc.dart';
import 'package:finguin/blocs/get_filteredtransactions_bloc/get_filteredtransactions_bloc.dart';
import 'package:finguin/screens/add_transaction/blocs/create_category_bloc/create_category_bloc.dart';
import 'package:finguin/screens/add_transaction/blocs/create_transaction_bloc/create_transaction_bloc.dart';
import 'package:finguin/screens/add_transaction/blocs/delete_category_bloc/delete_category_bloc.dart';
import 'package:finguin/screens/add_transaction/blocs/delete_transaction_bloc/delete_transaction_bloc.dart';
import 'package:finguin/screens/add_transaction/blocs/get_categories_bloc/get_categories_bloc.dart';
import 'package:finguin/screens/home/blocs/get_transactions_bloc/get_transactions_bloc.dart';
import 'package:transaction_repository/transaction_repository.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    final transactionRepository = FirebaseTransactionRepository();
    final authRepository = FirebaseAuthRepository();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => RegisterBlocBloc(authRepository),
        ),
        BlocProvider(
          create: (context) => LoginBloc(authRepository),
        ),
        BlocProvider(
          create: (context) => LogoutBloc(authRepository),
        ),
        BlocProvider(
          create: (context) => UpdateProfileBloc(authRepository),
        ),
        BlocProvider(
          create: (context) => ChangePasswordBloc(authRepository),
        ),
        BlocProvider(
          create: (context) => GetCurrentUserBloc(authRepository),
        ),
        BlocProvider(
          create: (context) => GetTransactionsBloc(transactionRepository),
        ),
        BlocProvider(
          create: (context) => GetFilteredTransactionsBloc(transactionRepository),
        ),
        BlocProvider(
          create: (context) => GetCategoryTransactionsBloc(transactionRepository),
        ),
        BlocProvider(
          create: (context) => CreateCategoryBloc(transactionRepository),
        ),
        BlocProvider(
          create: (context) => GetCategoriesBloc(transactionRepository)..add(GetCategories()),
        ),
        BlocProvider(
          create: (context) => CreateTransactionBloc(transactionRepository),
        ),
        BlocProvider(
          create: (context) => DeleteCategoryBloc(transactionRepository),
        ),
        BlocProvider(
          create: (context) => DeleteTransactionBloc(transactionRepository),
        ),
      ],
      child: BlocProvider(
        create: (context) => GetTransactionsBloc(
          FirebaseTransactionRepository()
        )..add(GetTransactions()),
        child: const MyAppView(),
      ),
    );
  }
}