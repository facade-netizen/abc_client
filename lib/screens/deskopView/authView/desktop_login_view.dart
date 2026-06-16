import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/authBlocs/user_auth_change_bloc.dart';
import '../../../blocs/authBlocs/user_login_bloc.dart';
import '../../../reusables/colors.dart';
import '../../../reusables/regexes.dart';
import '../../../reusables/sized_box_hw.dart';
import '../../../reusables/snack_bar.dart';
import '../../../routing/app_routes_constants.dart';
import '../../../services/navigators.dart';
import '../sportsReusables/custom_cta_button.dart';
import '../mainTabView/login_text_form_field.dart';
import 'desktop_login_view_widget.dart';
import 'desktop_password_reset_screen.dart';

Future<dynamic> desktopLoginView(BuildContext context) {
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext ctxt) {
      return const DesktopLoginViewBody();
    },
  );
}

class DesktopLoginViewBody extends StatefulWidget {
  const DesktopLoginViewBody({super.key});

  @override
  State<DesktopLoginViewBody> createState() => _DesktopLoginViewBodyState();
}

class _DesktopLoginViewBodyState extends State<DesktopLoginViewBody> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController validationCodeController = TextEditingController();

  final FocusNode focusNode = FocusNode();

  Timer? codeTimer;
  String validationCode = "";
  String? formError;
  bool obscurePassword = true;

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      setState(() {});
    });

    generateNewCode();
    codeTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      generateNewCode();
    });
  }

  void generateNewCode() {
    final random = Random();
    setState(() {
      validationCode = (1000 + random.nextInt(9000)).toString();
    });
  }

  @override
  void dispose() {
    codeTimer?.cancel();
    userNameController.dispose();
    passwordController.dispose();
    validationCodeController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void handleLogin(BuildContext context) {
    setState(() {
      formError = null;
    });

    if (userNameController.text.trim().isEmpty) {
      setState(() => formError = "Username is required");
      generateNewCode();
      return;
    }

    if (passwordController.text.isEmpty) {
      setState(() => formError = "Password is required");
      generateNewCode();
      return;
    }

    if (validationCodeController.text.isEmpty) {
      setState(() => formError = "Validation code is required");
      generateNewCode();
      return;
    }

    if (validationCodeController.text != validationCode) {
      setState(() => formError = "Invalid validation code");
      generateNewCode();
      return;
    }

    context.read<UserLoginBloc>().add(UserLogin(username: userNameController.text.trim(), password: passwordController.text));
  }

  @override
  Widget build(BuildContext context) {
    double tfw = 250;
    return BlocConsumer<UserLoginBloc, UserLoginState>(
      listener: (context, uls) {
        if (uls is UserLoginFailure) {
          setState(() {
            formError = uls.error;
          });
          generateNewCode();
          showSnackBar(context, uls.error, error: true);
        }
        if (uls is UserLoginSuccess) {
          context.read<UserAuthChangesBloc>().add(StartUserChangeListener());
          context.go(AppRoutes.home);
          removeScreen(context);
        }
        if (uls is UserLoginResetPasswordRequiredSuccess) {
          pushSimple(context, DesktopPasswordResetScreen(userName: uls.userName));
        }
      },
      builder: (context, uls) {
        bool isLoading = uls is UserLoginProgress;
        return DesktopLoginViewWidget(
          height: 400,
          width: 600,
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              hb20,
              Text(
                "Please login to continue",
                style: TextStyle(color: black, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              hb20,
              LoginTextFormField(
                hintText: "Username",
                width: tfw,
                controller: userNameController,
                readOnly: isLoading,
              ),
              hb10,
              LoginTextFormField(
                hintText: "Password",
                width: tfw,
                readOnly: isLoading,
                obscureText: obscurePassword,
                controller: passwordController,
                suffixIcon: IconButton(
                  icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility, size: 18, color: black),
                  onPressed: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                ),
              ),
              hb10,
              LoginTextFormField(
                width: tfw,
                readOnly: isLoading,
                hintText: "Validation Code",
                controller: validationCodeController,
                inputFormatters: [integers, LengthLimitingTextInputFormatter(4)],
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(top: 4, right: 4),
                  child: Text(
                    validationCode,
                    style: TextStyle(color: black, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                onFieldSubmitted: (p0) {
                  handleLogin(context);
                },
              ),
              hb20,
              CustomCTAButton(
                width: tfw,
                title: "Login",
                isProcessing: isLoading,
                action: () => handleLogin(context),
                gradientColor: blackGrdntButton,
                icon: Icons.logout,
                color: appYellow,
              ),
              if (formError != null)
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    formError!,
                    style: const TextStyle(color: red, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
