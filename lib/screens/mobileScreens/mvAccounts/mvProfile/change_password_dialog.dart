import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/authBlocs/change_password_bloc.dart';
import '../../../../blocs/authBlocs/user_logout_bloc.dart';
import '../../../../reusables/buttons.dart';
import '../../../../reusables/colors.dart';
import '../../../../reusables/custom_alert_dialog.dart';
import '../../../../reusables/loader.dart';
import '../../../../reusables/sized_box_hw.dart';
import '../../../../reusables/snack_bar.dart';
import '../../../../reusables/style.dart';
import '../../../../services/navigators.dart';

Future showPasswordChangeDialog(BuildContext context) {
  return showDialog(context: context, builder: (context) => ChangePasswordDialogBody());
}

class ChangePasswordDialogBody extends StatefulWidget {
  const ChangePasswordDialogBody({super.key});

  @override
  State<ChangePasswordDialogBody> createState() => _ChangePasswordDialogBodyState();
}

class _ChangePasswordDialogBodyState extends State<ChangePasswordDialogBody> {
  final TextEditingController newPassController = TextEditingController();
  final TextEditingController cfmPasswordController = TextEditingController();
  final TextEditingController yourPasswordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChangePasswordBloc, ChangePasswordState>(
      listener: (context, cps) {
        if (cps is ChangePasswordSuccess) {
          context.read<UserLogoutBloc>().add(UserLogoutListener());
          showSnackBar(context, "Password updated successfully");
          removeScreen(context);
        }
        if (cps is ChangePasswordFailure) {
          showSnackBar(context, "Unable update your password. Please try again!", error: true);
          removeScreen(context);
        }
      },
      builder: (context, cps) {
        return CustomAlertDialog(
          title: 'Change Password',
          content: SizedBox(
            height: 130,
            child: cps is ChangePasswordProgress
                ? LoaderContainerWithMessage()
                : Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text("New Password", style: TextStyle(color: black)),
                          ),
                          Expanded(
                            child: SizedBox(
                              height: 30,
                              child: TextFormField(
                                controller: newPassController,
                                obscureText: true,
                                obscuringCharacter: "*",
                                style: TextStyle(color: black),
                                decoration: tfInputDecoration.copyWith(contentPadding: const EdgeInsets.symmetric(horizontal: 10)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      hb12,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text("New Password Confirm", style: TextStyle(color: black)),
                          ),
                          Expanded(
                            child: SizedBox(
                              height: 30,
                              child: TextFormField(
                                controller: cfmPasswordController,
                                obscureText: true,
                                obscuringCharacter: "*",
                                style: TextStyle(color: black),
                                decoration: tfInputDecoration.copyWith(contentPadding: const EdgeInsets.symmetric(horizontal: 10)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      hb12,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text("Your Password", style: TextStyle(color: black)),
                          ),
                          Expanded(
                            child: SizedBox(
                              height: 30,
                              child: TextFormField(
                                controller: yourPasswordController,
                                obscureText: true,
                                obscuringCharacter: "*",
                                style: TextStyle(color: black),
                                decoration: tfInputDecoration.copyWith(contentPadding: const EdgeInsets.symmetric(horizontal: 10)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      hb10,
                    ],
                  ),
          ),
          actions: cps is ChangePasswordProgress
              ? []
              : [
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Divider()),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ColoredTextButton(
                      width: 100,
                      name: 'Change',
                      onTap: () {
                        Map<String, dynamic> changePasswordMap = {
                          "oldPassword": yourPasswordController.text.trim(),
                          "newPassword": newPassController.text.trim(),
                          "confirmPassword": cfmPasswordController.text.trim(),
                        };
                        context.read<ChangePasswordBloc>().add(ChangePassword(changePassword: changePasswordMap));
                      },
                    ),
                  ),
                ],
        );
      },
    );
  }
}
