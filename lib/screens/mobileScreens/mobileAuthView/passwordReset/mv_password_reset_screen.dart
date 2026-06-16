import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../blocs/authBlocs/reset_password_bloc.dart';
import '../../../../blocs/authBlocs/user_auth_change_bloc.dart';
import '../../../../blocs/authBlocs/user_login_bloc.dart';
import '../../../../reusables/buttons.dart';
import '../../../../reusables/colors.dart';
import '../../../../reusables/snack_bar.dart';
import '../../../../services/navigators.dart';

class MvPasswordResetScreen extends StatefulWidget {
  const MvPasswordResetScreen({super.key, required this.userName});
  final String userName;
  @override
  State<MvPasswordResetScreen> createState() => _MvPasswordResetScreenState();
}

class _MvPasswordResetScreenState extends State<MvPasswordResetScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController oldPasswordController = TextEditingController();

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    oldPasswordController.dispose();
    super.dispose();
  }

  String? validatePassword(String value) {
    if (value.isEmpty) return "Password is required";
    if (value.length < 6 || value.length > 15) return "Password must be 6-15 characters";
    if (value.contains(" ")) return "No spaces allowed";
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return "Must include upper, lower & number";
    }
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return "No special characters allowed";
    }
    if (value.toLowerCase().contains(widget.userName.toLowerCase())) {
      return "Password cannot contain your username";
    }
    if (value == oldPasswordController.text) return "New & Old password cannot be same";
    return null;
  }

  void onChangePassword() {
    final form = _formKey.currentState!;
    if (form.validate()) {
      Map<String, dynamic> resetPasswordMap = {
        "username": widget.userName,
        "oldPassword": oldPasswordController.text.trim(),
        "newPassword": newPasswordController.text.trim(),
        "confirmPassword": confirmPasswordController.text.trim(),
      };
      context.read<ResetPasswordBloc>().add(ResetPassword(resetPassword: resetPasswordMap));
    } else {
      final newPasswordError = validatePassword(newPasswordController.text);
      if (newPasswordError != null) {
        showSnackBar(context, newPasswordError, error: true);
      } else if (confirmPasswordController.text != newPasswordController.text) {
        showSnackBar(context, "Passwords do not match", error: true);
      } else if (newPasswordController.text.toLowerCase().contains(widget.userName.toLowerCase())) {
        showSnackBar(context, "Password cannot contain your username", error: true);
      } else if (oldPasswordController.text.isEmpty) {
        showSnackBar(context, "Old password required", error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserLoginBloc, UserLoginState>(
      listener: (context, state) {
        if (state is UserLoginSuccess) {
          context.read<UserAuthChangesBloc>().add(StartUserChangeListener());
          removeScreen(context);
        }
      },
      builder: (context, state) {
        return BlocConsumer<ResetPasswordBloc, ResetPasswordState>(
          listener: (context, rps) {
            if (rps is ResetPasswordSuccess) {
              context.read<UserLoginBloc>().add(UserLogin(username: rps.userName, password: rps.password));
              removeScreen(context);
            }
            if (rps is ResetPasswordFailure) {
              showSnackBar(context, rps.error, error: true);
            }
          },
          builder: (context, rps) {
            return Scaffold(
              backgroundColor: white,
              body: SafeArea(
                child: Column(
                  children: [
                    Container(
                      height: 65,
                      width: double.infinity,
                      decoration: const BoxDecoration(gradient: bottomBarGradient),
                      child: Center(
                        child: Text(
                          "Change Password",
                          style: TextStyle(
                            color: appBarText,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Form(
                        key: _formKey,
                        child: Center(
                          child: Container(
                            width: 500,
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: const [
                                          Text("• Password must have 6 to 15 characters", style: TextStyle(color: secondaryTextClr)),
                                          Text("• Alphanumeric without white space", style: TextStyle(color: secondaryTextClr)),
                                          SizedBox(height: 5),
                                          Text("• Password cannot be the same as username", style: TextStyle(color: secondaryTextClr)),
                                          SizedBox(height: 5),
                                          Text("• Must contain at least 1 capital letter, 1 small letter and 1 number", style: TextStyle(color: secondaryTextClr)),
                                          SizedBox(height: 5),
                                          Text("• Password must not contain any special characters (!,@,#,etc..)", style: TextStyle(color: secondaryTextClr)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          _inputField(
                                            "New Password",
                                            controller: newPasswordController,
                                            validator: (val) => validatePassword(val!),
                                          ),
                                          const SizedBox(height: 10),
                                          _inputField(
                                            "Confirm Password",
                                            controller: confirmPasswordController,
                                            validator: (val) {
                                              if (val == null || val.isEmpty) return "Confirm password required";
                                              if (val != newPasswordController.text) return "Passwords do not match";
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 10),
                                          _inputField(
                                            "Old Password",
                                            controller: oldPasswordController,
                                            validator: (val) {
                                              if (val == null || val.isEmpty) return "Old password required";
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 15),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    ColouredElevatedButton(
                      onCLick: onChangePassword,
                      width: double.infinity,
                      height: 50,
                      gradientColor: blackGrdntButton,
                      child: Center(
                        child: Text(
                          "Change",
                          style: TextStyle(
                            color: appBarText,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Widget _inputField(
    String hint, {
    required TextEditingController controller,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      validator: validator,
      style: TextStyle(color: secondaryTextClr),
      decoration: InputDecoration(
        filled: true,
        hintText: hint,
        hintStyle: TextStyle(color: grey),
        fillColor: Colors.grey[200],
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
