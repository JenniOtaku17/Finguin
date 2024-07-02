import 'package:bloc/bloc.dart';
import 'package:finguin/simple_bloc_observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:finguin/app.dart';
import 'package:localstorage/localstorage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Bloc.observer = SimpleBlocObserver();
  await initLocalStorage(); 
  runApp(const MyApp());
}

