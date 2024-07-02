import 'dart:io';

import 'package:cool_alert/cool_alert.dart';
import 'package:finguin/screens/auth/blocs/update_profile_bloc/update_profile_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:transaction_repository/transaction_repository.dart';


Future editProfile(BuildContext context, User? user) {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  TextEditingController nameController = TextEditingController();
  nameController.text = user!.displayName;

  CroppedFile? _image;

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

    _image = cropped;
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

  return showDialog(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          return BlocListener<UpdateProfileBloc, UpdateProfileState>(
            listener: (context, state) async {
              if (state is UpdateProfileSuccess) {
                setState(() {
                  isLoading = false;
                });
                await CoolAlert.show(
                  context: context,
                  type: CoolAlertType.success,
                  text: 'Profile updated successfully!',
                  autoCloseDuration: const Duration(seconds: 3),
                );
                Navigator.pop(context, true);
                
              } else if (state is UpdateProfileLoading) {
                setState(() {
                  isLoading = true;
                });
              } else if (state is UpdateProfileFailure) {
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
                  'Update Profile',
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
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 20),
                        Stack(
                          children: [
                            ClipOval(
                              child: (_image == null && user.photoURL != '' && user.photoURL != 'null' )
                              ? Image.file(
                                File(user.photoURL),
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              )
                              : (_image != null) ? Image.file(
                                File(_image!.path),
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              )
                              :Image.asset(
                                "assets/placeholder.png",
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(
                                    CupertinoIcons.pencil_circle_fill, 
                                    color: Colors.black,
                                    size: 36,
                                  ),
                                  onPressed: () {
                                    _showOptions(context);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: nameController,
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
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: kToolbarHeight,
                          child: isLoading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : TextButton(
                              onPressed: () {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  if(_image != null){
                                    context.read<UpdateProfileBloc>().add(UpdateProfile(nameController.text, File(_image!.path)));
                                  }else{
                                    context.read<UpdateProfileBloc>().add(UpdateProfile(nameController.text, null));
                                  }
                                }
                              ,
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