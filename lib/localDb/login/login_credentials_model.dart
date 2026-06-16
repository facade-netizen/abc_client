import 'package:hive/hive.dart';

part 'login_credentials_model.g.dart';

@HiveType(typeId: 1)
class LoginCredentialsModel {
  LoginCredentialsModel({
    this.username,
    this.password,
    this.savedAt,
  });

  @HiveField(0)
  String? username;

  @HiveField(1)
  String? password;

  @HiveField(2)
  DateTime? savedAt;

  factory LoginCredentialsModel.fromMap(Map<String, dynamic> data) {
    return LoginCredentialsModel(
      password: data['password'],
      savedAt: data['savedAt'],
      username: data['username'],
    );
  }
}
