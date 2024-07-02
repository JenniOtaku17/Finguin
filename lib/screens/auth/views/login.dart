import 'package:cool_alert/cool_alert.dart';
import 'package:finguin/screens/auth/blocs/login_bloc/login_bloc.dart';
import 'package:finguin/screens/auth/views/register.dart';
import 'package:finguin/screens/home/views/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transaction_repository/transaction_repository.dart' as repo;

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final emailController = new TextEditingController();
  final passwordController = new TextEditingController();

  bool isLoading = false;
  bool _isFormValid = false;
  bool show = false;

  repo.User currentUser = repo.User.empty;

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          _formKey.currentState?.reset();
          setState(() {
            isLoading = false; // Stop loading on success
          });
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
          
        } else if (state is LoginLoading) {
          setState(() {
            isLoading = true;
          });
          
        } else if (state is LoginFailure) {
          setState(() {
            isLoading = false; // Stop loading on failure
          });
          // Show error message
          CoolAlert.show(
            context: context,
            type: CoolAlertType.error,
            text: state.error,
          );
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            const SizedBox(height: 30),
            Image.asset(
              "assets/logo.png",
              width: 250,
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(36),
                    topRight: Radius.circular(36),
                  ),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 4,
                      color: Color.fromARGB(255, 228, 228, 228),
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 35),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const Text(
                          "Sign In",
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w600,
                            color: Color.fromARGB(255, 29, 29, 29),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Form(
                          key: _formKey,
                          onChanged: () {
                            setState(() {
                              _isFormValid = _formKey.currentState?.validate() ?? false;
                            });
                          },
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                controller: emailController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter an email';
                                  } else if (!RegExp(
                                          "^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                                      .hasMatch(value)) {
                                    return "Invalid email";
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.emailAddress,
                                textAlignVertical: TextAlignVertical.center,
                                decoration: InputDecoration(
                                  isDense: true,
                                  filled: true,
                                  fillColor: Color.fromARGB(255, 243, 242, 242),
                                  hintText: 'Email',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: passwordController,
                                validator: (value) {
                                  RegExp regex = new RegExp(r'^.{6,}$');
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a password';
                                  } else if (!regex.hasMatch(value)) {
                                    return "Invalid password";
                                  }
                                  return null;
                                },
                                obscureText: show ? false : true,
                                keyboardType: TextInputType.visiblePassword,
                                textAlignVertical: TextAlignVertical.center,
                                decoration: InputDecoration(
                                    isDense: true,
                                    filled: true,
                                    fillColor:
                                        Color.fromARGB(255, 243, 242, 242),
                                    hintText: 'Password',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(show
                                          ? CupertinoIcons.eye
                                          : CupertinoIcons.eye_slash),
                                      onPressed: () {
                                        setState(() {
                                          show = !show;
                                        });
                                      },
                                    )),
                                onSaved: (newValue) => passwordController.text =
                                    newValue.toString(),
                              ),
                              const SizedBox(height: 40),
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
                                                setState(() {
                                                  isLoading = true;
                                                });
                                                context.read<LoginBloc>().add(Login(emailController.text,passwordController.text));
                                              }
                                            : () => print('oh oh'+emailController.text+" - "+passwordController.text),
                                        style: TextButton.styleFrom(
                                          backgroundColor: Colors.black,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text(
                                          'Send',
                                          style: TextStyle(
                                              fontSize: 22,
                                              color: Colors.white),
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  const Text("Don't have an account?"),
                                  TextButton(
                                    child: const Text("Sign Up"),
                                    onPressed: () => _showRegister(context),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRegister(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => RegisterPage()));
  }
}
