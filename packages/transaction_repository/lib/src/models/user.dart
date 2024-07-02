

class User {
  String uid;
  String displayName;
  String email;
  String photoURL;

  User({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.photoURL,
  });

  static final empty = User(
    uid: '',
    displayName: '',
    email: '',
    photoURL: '',
  );

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'],
      displayName: json['displayName'],
      email: json['email'],
      photoURL: json['photoURL'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoURL': photoURL,
    };
  }
}