import 'package:cool_alert/cool_alert.dart';
import 'package:finguin/screens/auth/blocs/change_password_bloc/change_password_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


Future changePassword(BuildContext context) {


  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isFormValid = false;

  bool isLoading = false;
  bool show = false;
  bool show2 = false;

  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmController = TextEditingController();

  return showDialog(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          return BlocListener<ChangePasswordBloc, ChangePasswordState>(
            listener: (context, state) async {
              if (state is ChangePasswordSuccess) {
                await CoolAlert.show(
                  context: context,
                  type: CoolAlertType.success,
                  text: 'Password updated successfully!',
                  autoCloseDuration: const Duration(seconds: 3),
                );
                Navigator.pop(context);
                
              } else if (state is ChangePasswordLoading) {
                setState(() {
                  isLoading = true;
                });

              } else if (state is ChangePasswordFailure) {
                setState(() {
                  isLoading = false;
                });
                CoolAlert.show(
                  context: context,
                  type: CoolAlertType.error,
                  text: state.error,
                );
              }
            },
            child: AlertDialog(
              title: const Center(
                child: Text(
                  'Change Password',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
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
                          controller: passwordController,
                          validator: (value) {
                            RegExp regex = RegExp(r'^.{6,}$');
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
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: passwordConfirmController,
                          validator: (value) {
                            if (passwordController.text != value) {
                              return "Passwords do not match";
                            }
                            return null;
                          },
                          obscureText: show2 ? false : true,
                          keyboardType: TextInputType.visiblePassword,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                              isDense: true,
                              filled: true,
                              fillColor:
                                  const Color.fromARGB(255, 243, 242, 242),
                              hintText: 'Confirm Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(show2
                                    ? CupertinoIcons.eye
                                    : CupertinoIcons.eye_slash),
                                onPressed: () {
                                  setState(() {
                                    show2 = !show2;
                                  });
                                },
                              )),
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
                                setState(() {
                                  isLoading = true;
                                });
                                context.read<ChangePasswordBloc>().add(ChangePassword(passwordController.text));
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
      );
    },
  );
}