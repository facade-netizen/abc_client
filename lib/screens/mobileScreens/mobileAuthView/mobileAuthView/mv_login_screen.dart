import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../constants/termAndConditions/about_us.dart';
import '../../../../constants/termAndConditions/kyc.dart';
import '../../../../constants/termAndConditions/privacy_policy.dart';
import '../../../../constants/termAndConditions/responsible_gaming.dart';
import '../../../../constants/termAndConditions/self_exclusion_policy.dart';
import '../../../../constants/termAndConditions/term_and_conditions.dart';
import '../../../../constants/termAndConditions/rules_and_regulations.dart';
import '../../../../constants/termAndConditions/underage_policy.dart';

import '../../../../blocs/authBlocs/user_auth_change_bloc.dart';
import '../../../../blocs/authBlocs/user_login_bloc.dart';
import '../../../../constants/app_asset_constants.dart';
import '../../../../constants/app_string_constants.dart';
import '../../../../reusables/buttons.dart';
import '../../../../reusables/colors.dart';
import '../../../../reusables/custom_login_container.dart';
import '../../../../reusables/loading_screen.dart';
import '../../../../reusables/open_url.dart';
import '../../../../reusables/sized_box_hw.dart';
import '../../../../reusables/snack_bar.dart';
import '../../../../reusables/text_forms_field.dart';
import '../../../../services/navigators.dart';
import '../passwordReset/mv_password_reset_screen.dart';
import 'mv_login_screen_widgets.dart';

class MVLogin extends StatefulWidget {
  const MVLogin({super.key});

  @override
  State<MVLogin> createState() => _MVLoginState();
}

class _MVLoginState extends State<MVLogin> with TickerProviderStateMixin {
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController validationCodeController = TextEditingController();

  String validationCode = "";
  Timer? codeTimer;
  String? formErrorMessage;
  bool obscurePassword = true;

  @override
  void initState() {
    super.initState();
    generateNewCode();

    codeTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom != 0;

    return BlocConsumer<UserLoginBloc, UserLoginState>(
      listener: (context, uls) {
        if (uls is UserLoginFailure) {
          generateNewCode();
          showSnackBar(context, uls.error, error: true);
        }
        if (uls is UserLoginSuccess) {
          context.read<UserAuthChangesBloc>().add(StartUserChangeListener());
          Future.microtask(() {
            if (context.mounted) removeScreen(context);
          });
        }
        if (uls is UserLoginResetPasswordRequiredSuccess) {
          pushSimple(context, MvPasswordResetScreen(userName: uls.userName));
        }
      },
      builder: (context, uls) {
        return Scaffold(
          backgroundColor: white,
          body: uls is UserLoginProgress
              ? LoadingScreen(message: "Login you..")
              : SafeArea(
                  child: SingleChildScrollView(
                    child: Container(
                      decoration: getGradientBoxDecoration(),
                      width: double.infinity,
                      child: Column(
                        children: [
                          SizedBox(height: size.height / (isKeyboardOpen ? 3.5 : 2.6), child: MVLoginLogo()),
                          Transform.translate(
                            offset: Offset(0, -(size.height / (isKeyboardOpen ? 10 : 7))),
                            child: Form(
                              key: loginFormKey,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 30),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    //Heading
                                    SizedBox(height: size.height * 0.15),
                                    //User Id form field
                                    CustomTextFormFieldWithFocus(
                                      controller: userNameController,
                                      hintText: "Username",
                                      onChanged: (value) {
                                        if (formErrorMessage != null) {
                                          setState(() {
                                            formErrorMessage = null;
                                          });
                                        }
                                      },
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Username is empty';
                                        }
                                        return null;
                                      },
                                    ),
                                    hb10,
                                    CustomTextFormFieldWithFocus(
                                      controller: passwordController,
                                      hintText: "Password",
                                      obscureText: true,
                                      onChanged: (value) {
                                        if (formErrorMessage != null) {
                                          setState(() {
                                            formErrorMessage = null;
                                          });
                                        }
                                      },
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Password is empty';
                                        }
                                        return null;
                                      },
                                    ),
                                    hb10,
                                    CustomTextFormFieldWithFocus(
                                      controller: validationCodeController,
                                      textInputAction: TextInputAction.done,
                                      hintText: "Validation Code",
                                      onChanged: (value) {
                                        if (formErrorMessage != null) {
                                          setState(() {
                                            formErrorMessage = null;
                                          });
                                        }
                                      },
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Required';
                                        }
                                        return null;
                                      },
                                      suffixIcon: IntrinsicWidth(
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.only(right: 10),
                                            child: Text(
                                              validationCode,
                                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: black),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    hb10,
                                    ColoredTextButton(
                                      width: double.infinity,
                                      height: 46,
                                      name: 'Login',
                                      fontSize: 16,
                                      onTap: () {
                                        setState(() {
                                          formErrorMessage = null;
                                        });

                                        final bool isValid = loginFormKey.currentState!.validate();
                                        if (!isValid) {
                                          if (userNameController.text.trim().isEmpty) {
                                            setState(() {
                                              formErrorMessage = 'Username is empty';
                                            });
                                          } else if (passwordController.text.isEmpty) {
                                            setState(() {
                                              formErrorMessage = 'Password is empty';
                                            });
                                          } else if (validationCodeController.text.trim().isEmpty) {
                                            setState(() {
                                              formErrorMessage = 'Validation code is empty';
                                            });
                                          }
                                          return;
                                        }

                                        final bool isvalidCode = validationCode == validationCodeController.text.trim();
                                        if (!isvalidCode) {
                                          setState(() {
                                            formErrorMessage = 'Invalid validation code!';
                                          });
                                          generateNewCode();
                                          return;
                                        }
                                        context.read<UserLoginBloc>().add(UserLogin(username: userNameController.text.trim(), password: passwordController.text));
                                      },
                                    ),
                                    hb5,
                                    if (formErrorMessage != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          formErrorMessage!,
                                          style: const TextStyle(color: Color(0xFFD0021b), fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    hb30,
                                    FooterLinks(),
                                    hb50,
                                    MvFooterCard(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class FooterLinks extends StatelessWidget {
  FooterLinks({super.key});
  final List<String> links = [
    "KYC",
    "About Us",
    "Privacy Policy",
    "Responsible Gaming",
    "Terms and Conditions",
    "Underage Gaming Policy",
    "Self-Exclusion Policy",
    "Rules and Regulations",
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: List.generate(links.length * 2 - 1, (index) {
          if (index.isOdd) {
            return const Padding(
              padding: EdgeInsets.symmetric(horizontal: 3, vertical: 5),
              child: Text("|", style: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.6))),
            );
          } else {
            final text = links[index ~/ 2];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
              child: GestureDetector(
                onTap: () {
                  if (text == 'KYC') {
                    KycPolicyPopup.open(context);
                  } else if (text == 'Privacy Policy') {
                    PrivacyPolicyPopup.open(context);
                  } else if (text == 'Terms and Conditions') {
                    TermsAndConditionsPopup.open(context);
                  } else if (text == 'Responsible Gaming') {
                    ResponsibleGamingPopup.open(context);
                  } else if (text == 'About Us') {
                    AboutUsPopup.open(context);
                  } else if (text == 'Rules and Regulations') {
                    RulesAndRegulationsPopup.open(context);
                  } else if (text == 'Self-Exclusion Policy') {
                    SelfExclusionPolicyPopup.open(context);
                  } else if (text == 'Underage Gaming Policy') {
                    UnderagePolicyPopup.open(context);
                  }
                },
                child: Text(
                  text,
                  style: TextStyle(decoration: TextDecoration.underline, color: Color.fromRGBO(0, 0, 0, 0.6), fontWeight: FontWeight.w500, fontSize: 14),
                ),
              ),
            );
          }
        }),
      ),
    );
  }
}

class MvFooterCard extends StatelessWidget {
  const MvFooterCard({super.key});
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    final double smallCardWidth = (size.width / 3) - 40;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 15,
      children: [
        CustomLoginContainer(
          width: size.width,
          height: 50,
          color: Color(0xFFFFE39E),
          borderRadius: 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(AppAssetConstants.whatsapp, height: 30, width: 30, colorFilter: ColorFilter.mode(black, BlendMode.srcIn)),
              wb5,
              InkWell(
                onTap: () async {
                  await openUrl(AppStringConstants.whatsappLink1);
                },
                child: Text(
                  "WhatsApp 3",
                  style: TextStyle(fontSize: 14.2, color: Color.fromRGBO(0, 0, 0, .7), fontWeight: FontWeight.w500),
                ),
              ),
              wb5,
              Text("|", style: TextStyle(color: Color.fromRGBO(0, 0, 0, .7))),
              wb5,
              InkWell(
                onTap: () async {
                  await openUrl(AppStringConstants.whatsappLink1);
                },
                child: Text(
                  "WhatsApp 4",
                  style: TextStyle(fontSize: 14.2, color: Color.fromRGBO(0, 0, 0, .7), fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        CustomLoginContainer(
          width: size.width,
          height: 50,
          borderRadius: 8,
          color: Color(0xFFFFE39E),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(AppAssetConstants.support, height: 30, width: 30, colorFilter: ColorFilter.mode(black, BlendMode.srcIn)),
              wb5,
              InkWell(
                onTap: () async {
                  await openUrl(AppStringConstants.whatsappLink);
                },
                child: Text(
                  "Customer support1",
                  style: TextStyle(fontSize: 14.2, color: Color.fromRGBO(0, 0, 0, .7), fontWeight: FontWeight.w500),
                ),
              ),
              wb5,
              Text("|", style: TextStyle(color: Color.fromRGBO(0, 0, 0, .7))),
              wb5,
              InkWell(
                onTap: () async {
                  await openUrl(AppStringConstants.whatsappLink);
                },
                child: Text(
                  "support2",
                  style: TextStyle(fontSize: 14.2, color: Color.fromRGBO(0, 0, 0, .7), fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        CustomLoginContainer(
          width: size.width,
          height: 50,
          borderRadius: 8,
          color: Color(0xFFFFE39E),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(AppAssetConstants.telegram, height: 30, width: 30, colorFilter: ColorFilter.mode(black, BlendMode.srcIn)),
              wb5,
              InkWell(
                onTap: () async {
                  await openUrl(AppStringConstants.telegram);
                },
                child: Text(
                  "Telegram 1",
                  style: TextStyle(fontSize: 14.2, color: Color.fromRGBO(0, 0, 0, .7), fontWeight: FontWeight.w500),
                ),
              ),
              wb5,
              Text("|", style: TextStyle(color: Color.fromRGBO(0, 0, 0, .7))),
              wb5,
              InkWell(
                onTap: () async {
                  await openUrl(AppStringConstants.telegram);
                },
                child: Text(
                  "Telegram 2",
                  style: TextStyle(fontSize: 14.2, color: Color.fromRGBO(0, 0, 0, .7), fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        CustomLoginContainer(width: size.width, height: 16, borderRadius: 15, color: Color(0xFFFFE39E)),
        SizedBox(
          width: size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 10,
            children: [
              CustomLoginContainer(
                width: smallCardWidth + 10,
                color: Color(0xFFFFE39E),
                height: 44,
                borderRadius: 8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(AppAssetConstants.telegram, height: 26, width: 26, colorFilter: ColorFilter.mode(black, BlendMode.srcIn)),
                    wb5,
                    InkWell(
                      onTap: () async {
                        await openUrl(AppStringConstants.telegram);
                      },
                      child: Text(
                        "Telegram",
                        style: TextStyle(fontSize: 14.2, color: Color.fromRGBO(0, 0, 0, .7), fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              CustomLoginContainer(
                width: smallCardWidth,
                height: 44,
                borderRadius: 8,
                color: Color(0xFFFFE39E),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(AppAssetConstants.email, height: 26, width: 26, colorFilter: ColorFilter.mode(black, BlendMode.srcIn)),
                    wb5,
                    InkWell(
                      onTap: () async {
                        await openUrl(AppStringConstants.email);
                      },
                      child: Text(
                        "Email",
                        style: TextStyle(fontSize: 14.2, color: Color(0xFF4d4d4d), fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              CustomLoginContainer(
                width: smallCardWidth,
                height: 44,
                borderRadius: 8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(AppAssetConstants.insta, height: 26, width: 26, colorFilter: ColorFilter.mode(black, BlendMode.srcIn)),
                    wb5,
                    InkWell(
                      onTap: () async {
                        await openUrl(AppStringConstants.insta);
                      },
                      child: Text(
                        "6Ball",
                        style: TextStyle(fontSize: 14.2, color: Color.fromRGBO(0, 0, 0, .7), fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
