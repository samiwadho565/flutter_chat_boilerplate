class AppUserModel {
  final String email;
  final String? password;
  final String username;

  AppUserModel({
    required this.email,
   this.password,
    required this.username,
  });

  // To create an AppUserModel from Firestore data or API response
  factory AppUserModel.fromJson(Map<String, dynamic> json) {
    return AppUserModel(
      email: json['email'] ?? '',
      password: json['password'] ?? '', // Password should be stored securely
      username: json['userName'] ?? '',
    );
  }

  // To convert AppUserModel to JSON for storing in Firestore or API
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password, // Don't store the password in plain text in production apps
      'userName': username,
    };
  }
}
