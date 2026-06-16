import 'package:flutter/material.dart';

import '../../../reusables/colors.dart';
import '../../../reusables/regexes.dart';
import '../../../reusables/sized_box_hw.dart';
import '../mainTabView/login_text_form_field.dart';

class BetRadarSlider extends StatelessWidget {
  const BetRadarSlider({
    super.key,
    required this.sliderValue,
    required this.mainBalance,
    this.onChanged,
  });
  final double sliderValue;
  final double mainBalance;
  final void Function(double)? onChanged;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFCDE3F0),
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Container(
          decoration: BoxDecoration(
            color: white,
            border: Border.all(color: const Color(0xFFBBBBBB)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                /// 0 BUTTON
                InkWell(
                  onTap: () {
                    if (onChanged != null) {
                      onChanged!(0);
                    }
                  },
                  child: const SliderTitle(title: "0"),
                ),

                const VerticalDivider(color: Color(0xFFBBBBBB), width: 1, thickness: 1),

                /// SLIDER
                Expanded(
                  child: Slider(
                    activeColor: appYellow,
                    inactiveColor: const Color(0xFFCDE3F0),
                    value: sliderValue.clamp(0, mainBalance),
                    min: 0,
                    max: mainBalance == 0 ? 1 : mainBalance,
                    divisions: 100,
                    onChanged: onChanged,
                  ),
                ),

                const VerticalDivider(color: Color(0xFFBBBBBB), width: 1, thickness: 1),

                /// MAX BUTTON
                InkWell(
                  onTap: () {
                    if (onChanged != null) {
                      onChanged!(mainBalance);
                    }
                  },
                  child: const SliderTitle(title: "Max"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SliderAmount extends StatelessWidget {
  const SliderAmount({super.key, required this.amount});
  final TextEditingController amount;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: TextFormField(
        controller: amount,
        keyboardType: TextInputType.number,
        maxLines: 1,
        inputFormatters: [greaterThanOrEqualToZeroWithDecimal],
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(fontSize: 20, color: darkGreen, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          filled: true,
          hintText: "Amount",
          hintStyle: const TextStyle(fontSize: 20, color: black, fontWeight: FontWeight.bold),
          fillColor: white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          focusedBorder: border(color: appYellow),
          disabledBorder: border(color: none),
          enabledBorder: border(color: black),
          border: border(color: black),
        ),
      ),
    );
  }
}

class SliderTitle extends StatelessWidget {
  const SliderTitle({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold, color: darkGreen, fontSize: 20),
      ),
    );
  }
}

class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.title,
    required this.balance,
    this.type = 0,
  });
  final String title, balance;
  final int type;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: type == 0 ? MainAxisAlignment.start : MainAxisAlignment.end,
      crossAxisAlignment: type == 0 ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(title, style: TextStyle(fontSize: 14, color: darkGreen)),
        hb8,
        Text(
          balance,
          style: TextStyle(fontWeight: FontWeight.bold, color: darkGreen, fontSize: 20),
        ),
      ],
    );
  }
}
