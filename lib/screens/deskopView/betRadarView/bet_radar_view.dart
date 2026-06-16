import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/addBloc/add_cg_money_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_current_user_info_bloc.dart';
import '../../../models/cg_model.dart';
import '../../../models/user_details_model.dart';
import '../../../reusables/colors.dart';
import '../../../reusables/open_url.dart';
import '../../../reusables/sized_box_hw.dart';
import '../../../reusables/snack_bar.dart';
import '../../../services/app_config.dart';
import '../../../services/navigators.dart';
import '../sportsReusables/custom_cta_button.dart';
import '../sportsReusables/desktop_alert_dialog.dart';
import 'bet_radar_widgets.dart';

Future<dynamic> betRadarView(
  BuildContext context,
  CGData sports,
) {
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext ctxt) {
      context.read<FetchUserAccountDetailsBloc>().add(FetchUserAccountDetails());
      return BlocBuilder<FetchUserAccountDetailsBloc, FetchUserAccountDetailsState>(
        builder: (context, ucs) {
          UserAccountDetails? userDetails;
          if (ucs is FetchUserAccountDetailsSuccess) {
            userDetails = ucs.userDetails;
          }
          return BetRadarViewBody(
            sports: sports,
            userDetails: userDetails,
          );
        },
      );
    },
  );
}

class BetRadarViewBody extends StatefulWidget {
  const BetRadarViewBody({
    super.key,
    required this.sports,
    this.userDetails,
  });
  final CGData sports;
  final UserAccountDetails? userDetails;
  @override
  State<BetRadarViewBody> createState() => _BetRadarViewBodyState();
}

class _BetRadarViewBodyState extends State<BetRadarViewBody> {
  double mainBalance = 0.0;
  double casinoBalance = 0.0;
  double sliderValue = 0;
  TextEditingController amount = TextEditingController();
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
          // If input is greater than mainBalance, cap it and update text field
          amount.text = mainBalance.toStringAsFixed(0);
          amount.selection = TextSelection.fromPosition(TextPosition(offset: amount.text.length));
          setState(() {
            sliderValue = mainBalance;
          });
        }
      }
    });
  }

  double tfw = 500;
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddCGMoneyBloc, AddCGMoneyState>(
      listener: (context, cgm) {
        if (cgm is AddCGMoneySuccess) {
          openUrl(cgm.url);
          context.read<FetchUserAccountDetailsBloc>().add(FetchUserAccountDetails());
          removeScreen(context);
        }
        if (cgm is AddCGMoneyFailure) {
          showSnackBar(context, "Game ${cgm.error.toString()}", error: true);
        }
      },
      builder: (context, cgm) {
        bool isProcessing = cgm is AddCGMoneyProgress;

        return DesktopAlertDialog(
          title: widget.sports.gameName,
          contentPadding: EdgeInsets.all(0),
          content: SizedBox(
            height: 190,
            width: tfw,
            child: Column(
              children: [
                IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: tfw / 2 - 16,
                          child: BalanceCard(
                            title: "Main Balance",
                            balance: mainBalance.toStringAsFixed(2),
                          ),
                        ),
                        const VerticalDivider(color: darkGreen, width: 1, thickness: 1),
                        SizedBox(
                          width: tfw / 2 - 16,
                          child: BalanceCard(
                            title: "Royal gaming Balance",
                            balance: casinoBalance.toStringAsFixed(2),
                            type: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliderAmount(amount: amount),
                hb10,
                BetRadarSlider(
                  sliderValue: sliderValue,
                  mainBalance: mainBalance,
                  onChanged: (value) {
                    setState(() {
                      sliderValue = value;
                      amount.text = sliderValue.toStringAsFixed(0);
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            Column(
              children: [
                hb12,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CancelCTAButton(
                      isDisabled: isProcessing,
                      width: tfw / 2 - 8,
                    ),
                    CustomCTAButton(
                      isProcessing: isProcessing,
                      color: appYellow,
                      title: 'Transfer and Enter',
                      action: () {
                        Map<String, dynamic> addCGMoneyMap = {
                          "providerName": widget.sports.providerName,
                          "amount": double.tryParse(amount.text) ?? 0,
                          "gameId": widget.sports.gameId,
                          "platformId": appConfig.operatingSystem,
                          "catagory": widget.sports.category,
                        };
                        context.read<AddCGMoneyBloc>().add(AddCGMoney(addCGMoneyMap: addCGMoneyMap));
                      },
                      width: tfw / 2 - 8,
                    ),
                  ],
                ),
                hb12,
              ],
            ),
          ],
        );
      },
    );
  }
}
