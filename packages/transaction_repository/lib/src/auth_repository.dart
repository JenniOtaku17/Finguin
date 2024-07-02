import 'dart:io';

import '../transaction_repository.dart';

abstract class AuthRepository {

  Future<String> register(User user, String password, File? photo);

  Future<String> login(String email, String password);

  Future<bool> logout();

  Future<User> getCurrentUser();

  Future<bool> updatePhotoURL( File? image );

  Future<bool> updateDisplayName( String name );

  Future<String> changePassword( String password );

  Future<String> updateProfile( String? displayName, File? image);
}