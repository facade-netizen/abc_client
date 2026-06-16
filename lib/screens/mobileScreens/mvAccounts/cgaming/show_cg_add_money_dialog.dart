import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/addBloc/add_cg_money_bloc.dart';
import '../../../../blocs/fetchBlocs/fetch_current_user_info_bloc.dart';
import '../../../../models/cg_model.dart';
import '../../../../models/user_details_model.dart';
import '../../../../reusables/buttons.dart';
import '../../../../reusables/colors.dart';
import '../../../../reusables/loader.dart';
import '../../../../reusables/open_url.dart';
import '../../../../reusables/regexes.dart';
import '../../../../services/app_config.dart';
import '../../../../services/navigators.dart';
import '../../../deskopView/sportsReusables/custom_cta_button.dart';

Future<dynamic> showCgAddMoneyDialog(BuildContext context, CGData sports) {
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext ctxt) {
      return BlocBuilder<FetchUserAccountDetailsBloc, FetchUserAccountDetailsState>(
        builder: (context, ucs) {
          return ucs is FetchUserAccountDetailsSuccess ? ShowCgAddMoneyDialogBody(sports: sports, userDetails: ucs.userDetails) : LoaderContainerWithMessage();
        },
      );
    },
  );
}

class ShowCgAddMoneyDialogBody extends StatefulWidget {
  const ShowCgAddMoneyDialogBody({super.key, required this.sports, required this.userDetails});
  final CGData sports;
  final UserAccountDetails? userDetails;
  @override
  State<ShowCgAddMoneyDialogBody> createState() => _ShowCgAddMoneyDialogBodyState();
}

class _ShowCgAddMoneyDialogBodyState extends State<ShowCgAddMoneyDialogBody> {
  double mainBalance = 0.0;
  double casinoBalance = 0.0;
  double sliderValue = 0;
  TextEditingController amount = TextEditingController();
  dynamic _pendingWindow;
  @override
  void initState() {
    super.initState();
    mainBalance = widget.userDetails?.balancePoint ?? 0.0;
    casinoBalance = widget.userDetails?.casinoAccount.first.currentBalance ?? 0.0;
    amount = TextEditingController(text: sliderValue.toStringAsFixed(0));
    amount.addListener(() {
      final text = amount.text;
      final value = double.tryParse(text);
      if (value != null) {
        if (value <= mainBalance) {
          setState(() {
            sliderValue = value;
          });
        } else {
          amount.text = mainBalance.toStringAsFixed(0);
          amount.selection = TextSelection.fromPosition(TextPosition(offset: amount.text.length));
          setState(() {
            sliderValue = mainBalance;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddCGMoneyBloc, AddCGMoneyState>(
      listener: (context, cgm) {
        if (cgm is AddCGMoneySuccess) {
          context.read<FetchUserAccountDetailsBloc>().add(FetchUserAccountDetails());
          if (kIsWeb && _pendingWindow != null) {
            openUrlInWindow(_pendingWindow, cgm.url);
          } else {
            openUrl(cgm.url);
          }
          removeScreen(context);
        }
      },
      builder: (context, cgm) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          titlePadding: EdgeInsets.all(0),
          contentPadding: EdgeInsets.all(0),
          title: Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
              gradient: bottomBarGradient,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 5, top: 10),
              child: Text(
                widget.sports.gameName,
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
              ),
            ),
          ),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Main Balance", style: TextStyle(color: highlightText)),
                          Text(
                            mainBalance.toStringAsFixed(2),
                            style: TextStyle(color: highlightText, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("Casino Balance", style: TextStyle(color: highlightText)),
                          Text(
                            casinoBalance.toStringAsFixed(2),
                            style: TextStyle(color: highlightText, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 150,
                  height: 35,
                  child: TextFormField(
                    controller: amount,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [greaterThanOrEqualToZeroWithDecimal],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: blncNameBox),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: appBarText),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: appBarText),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  height: 80,
                  width: double.infinity,
                  color: const Color.fromARGB(237, 143, 200, 240),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Container(
                      color: white,
                      height: 70,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 70,
                            width: 60,
                            decoration: BoxDecoration(
                              border: Border(right: BorderSide(color: grey)),
                            ),
                            child: Center(
                              child: Text(
                                "0",
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: blncNameBox),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Slider(
                              value: sliderValue,
                              min: 0,
                              max: mainBalance,
                              activeColor: Colors.orange,
                              onChanged: (v) {
                                setState(() {
                                  sliderValue = v;
                                  amount.text = v.toInt().toString();
                                });
                              },
                            ),
                          ),
                          Container(
                            height: 70,
                            width: 60,
                            decoration: BoxDecoration(
                              border: Border(left: BorderSide(color: grey)),
                            ),
                            child: Center(
                              child: Text(
                                "Max",
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: blncNameBox),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            CancelCTAButton(),
            ColouredElevatedButton(
              height: 35,
              width: 120,
              onCLick: () {
                if (kIsWeb) {
                  _pendingWindow = openUrlInNewTab();
                }
                Map<String, dynamic> addCGMoneyMap = {
                  "providerName": widget.sports.providerName,
                  "amount": double.tryParse(amount.text) ?? 0,
                  "gameId": widget.sports.gameId,
                  "platformId": appConfig.operatingSystem,
                  "catagory": widget.sports.category,
                };
                context.read<AddCGMoneyBloc>().add(AddCGMoney(addCGMoneyMap: addCGMoneyMap));
              },
              gradientColor: blackGrdntButton,
              child: Text(
                "Enter",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: appBarText),
              ),
            ),
          ],
        );
      },
    );
  }
}
