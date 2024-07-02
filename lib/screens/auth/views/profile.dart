import 'dart:io';

import 'package:finguin/components/changePassword.dart';
import 'package:finguin/components/editProfile.dart';
import 'package:finguin/screens/auth/blocs/get_current_user/get_current_user_bloc.dart';
import 'package:finguin/screens/auth/blocs/logout_bloc/logout_bloc.dart';
import 'package:finguin/screens/auth/views/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transaction_repository/transaction_repository.dart';

class Profile extends StatefulWidget {
  final User? user;
  const Profile({Key? key, this.user}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<LogoutBloc, LogoutBlocState>(
          listener: (context, state) {
            if (state is LogoutSuccess) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ),
              );
            }
          },
        ),
        BlocListener<GetCurrentUserBloc, GetCurrentUserState>(
          listener: (context, state) {
            if( state is GetCurrentUserSuccess){
              setState(() {
                widget.user!.displayName = state.user.displayName;
                widget.user!.photoURL = state.user.photoURL;
              });
            }
          },
        ),
      ],
      child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.background,
            title: const Text(
              'Profile',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              PopupMenuButton<String>(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                onSelected: (value) async {
                  switch (value) {
                    case 'update_profile':
                      await editProfile(context, widget.user);
                      context.read<GetCurrentUserBloc>().add(const GetCurrentUser());
                      break;
                    case 'change_password':
                      changePassword(context);
                      break;
                    case 'logout':
                      context.read<LogoutBloc>().add(const Logout());
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'update_profile',
                    child: Text('Update Profile'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'change_password',
                    child: Text('Change Password'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Text('Logout'),
                  ),
                ],
              ),
            ],
          ),
          body: Center(
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),
                      ClipOval(
                        child: (widget.user!.photoURL != '' && widget.user!.photoURL != 'null')? 
                        Image.file(
                          File(widget.user!.photoURL),
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        )
                        :Image.asset(
                          "assets/placeholder.png",
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        widget.user!.displayName,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.user!.email,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ])),
          )),
    );
  }
}
