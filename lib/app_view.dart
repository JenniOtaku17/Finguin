import 'package:finguin/screens/auth/blocs/get_current_user/get_current_user_bloc.dart';
import 'package:finguin/screens/auth/views/login.dart';
import 'package:finguin/screens/auth/views/register.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:finguin/screens/home/views/home_screen.dart';
import 'package:transaction_repository/transaction_repository.dart';


class MyAppView extends StatefulWidget {
  const MyAppView({Key? key});

  @override
  State<MyAppView> createState() => _MyAppViewState();
}

class _MyAppViewState extends State<MyAppView> {

  @override
  void initState() {
    super.initState();
    context.read<GetCurrentUserBloc>().add(const GetCurrentUser());
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Transaction Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          background: Colors.grey.shade100,
          onBackground: Colors.black,
          primary: const Color.fromARGB(255, 32, 56, 63),
          secondary: const Color.fromARGB(255, 14, 78, 161),
          tertiary: const Color.fromARGB(255, 2, 61, 38),
          outline: Colors.grey,
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // Ajusta la localización según tus necesidades
      ],
      home: BlocBuilder<GetCurrentUserBloc, GetCurrentUserState>(
        builder: (context, state) {

          print('change');
    
          if (state is GetCurrentUserLoading) {
            return Scaffold(
              body: Center(
                child: Image.asset(
                'assets/loading.gif',
                  width: 300,
                ),
              ),
            );
          } else if (state is GetCurrentUserSuccess) {
            if (state.user != User.empty) {
              return const HomeScreen();
            } else {
              return LoginPage();
            }
          } else {
            return RegisterPage(); // Mostrar LoginPage si no está autenticado
          }
        },
      ),
    );
  }
}