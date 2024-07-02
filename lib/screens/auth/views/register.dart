import 'dart:io';

import 'package:cool_alert/cool_alert.dart';
import 'package:finguin/screens/auth/blocs/register_bloc/register_bloc_bloc.dart';
import 'package:finguin/screens/auth/views/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:transaction_repository/transaction_repository.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({Key? key}) : super(key: key);

  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();
  final photoController = TextEditingController();

  bool isLoading = false;
  bool _isFormValid = false;
  bool show = false;
  bool show2 = false;
  CroppedFile? _image;

  User newUser = User.empty;

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterBlocBloc, RegisterBlocState>(
      listener: (context, state) async {
        if (state is RegisterSuccess) {
          _formKey.currentState?.reset();
          setState(() {
            isLoading = false; // Stop loading on success
          });
          await CoolAlert.show(
            context: context,
            type: CoolAlertType.success,
            text: 'User created successfully!',
            autoCloseDuration: const Duration(seconds: 3),
          );
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
          
        } else if (state is RegisterLoading) {
          setState(() {
            isLoading = true;
          });
          
        } else if (state is RegisterFailure) {
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
              width: 200,
            ),
            const SizedBox(height: 20),
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
                      children: <Widget>[
                        const Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w600,
                            color: Color.fromARGB(255, 27, 27, 27),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Form(
                          key: _formKey,
                          onChanged: () {
                            setState(() {
                              _isFormValid = _formKey.currentState?.validate() ?? false;
                            });
                          },
                          child: Column(
                            children: <Widget>[
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: nameController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a name';
                                  } else if (!RegExp(r'^.{3,}$')
                                      .hasMatch(value)) {
                                    return "Invalid name";
                                  }
                                  return null;
                                },
                                textAlignVertical: TextAlignVertical.center,
                                decoration: InputDecoration(
                                  isDense: true,
                                  filled: true,
                                  fillColor: const Color.fromARGB(255, 243, 242, 242),
                                  hintText: 'Name',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
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
                                  fillColor: const Color.fromARGB(255, 243, 242, 242),
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
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: photoController,
                                onTap: () => _showOptions(context),
                                readOnly: true,
                                textAlignVertical: TextAlignVertical.center,
                                decoration: InputDecoration(
                                    isDense: true,
                                    filled: true,
                                    fillColor:
                                        Color.fromARGB(255, 243, 242, 242),
                                    hintText: 'Profile Photo',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    suffixIcon:
                                        const Icon(CupertinoIcons.paperclip)),
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
                                                  newUser.displayName = nameController.text;
                                                  newUser.email = emailController.text;
                                                });
                                                if(_image != null){
                                                  context.read<RegisterBlocBloc>().add(Register(newUser,passwordController.text, File(_image!.path)));
                                                }else{
                                                  context.read<RegisterBlocBloc>().add(Register(newUser,passwordController.text, null));
                                                }
                                                
                                              }
                                            : null,
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
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  const Text('Already registered?'),
                                  TextButton(
                                    child: const Text("Sign In"),
                                    onPressed: () => _showLogin(context),
                                  )
                                ],
                              )
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

  void _showLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void getImage(ImageSource source) async {
    final ImagePicker _picker = ImagePicker();

    XFile? image = await _picker.pickImage(source: source);
    final cropped = await ImageCropper().cropImage(
      sourcePath: image!.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 100,
      maxWidth: 700,
      maxHeight: 700,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Edit your photo',
          toolbarColor: Color.fromARGB(255, 32, 56, 63),
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          minimumAspectRatio: 1.0,
        ),
      ],
    );

    setState(() {
      _image = cropped;
      photoController.text = image.path.split('/').last;
    });
  }

  void _showOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          children: <Widget>[
            ListTile(
              title: const Text("Camera"),
              leading: const Icon(CupertinoIcons.camera),
              onTap: () {
                Navigator.pop(context);
                getImage(ImageSource.camera);
              },
            ),
            ListTile(
              title: const Text("Gallery"),
              leading: const Icon(CupertinoIcons.photo),
              onTap: () {
                Navigator.pop(context);
                getImage(ImageSource.gallery);
              },
            ),
          ],
        );
      },
    );
  }
}
