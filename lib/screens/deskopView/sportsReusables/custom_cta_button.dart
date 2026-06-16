import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/fetchBlocs/fetch_fav_stake_bloc.dart';
import '../../../reusables/colors.dart';
import '../../../reusables/sized_box_hw.dart';
import '../../../reusables/style.dart';
import '../../../services/navigators.dart';
import '../sportsView/matchOddsView/match_odds_header.dart';

class CustomCTAButton extends StatelessWidget {
  const CustomCTAButton({
    super.key,
    this.icon,
    this.color,
    this.width,
    this.action,
    this.height,
    this.gradientColor,
    required this.title,
    this.leading,
    this.msg,
    this.isDisabled = false,
    this.isProcessing = false,
  });

  final Widget? leading;
  final Color? color;
  final String title;
  final double? height;
  final double? width;
  final IconData? icon;
  final Function()? action;
  final LinearGradient? gradientColor;
  final bool isDisabled;
  final bool isProcessing;
  final String? msg;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isDisabled || isProcessing ? null : action,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Container(
          height: height ?? 35,
          width: width ?? 120,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(gradient: isDisabled ? disabledGradient : gradientColor ?? bottomBarGradient, borderRadius: BorderRadius.circular(4)),
          child: Center(
            child: isProcessing
                ? Text(
                    msg ?? "Please wait..",
                    style: TextStyle(color: white),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(child: leading),
                      leading == null ? wb0 : wb5,
                      Text(
                        title,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDisabled ? black : color ?? white),
                      ),
                      icon == null ? wb0 : wb5,
                      Visibility(
                        visible: icon != null,
                        child: Icon(icon, size: 20, color: color ?? white),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class CancelCTAButton extends StatelessWidget {
  const CancelCTAButton({
    super.key,
    this.height,
    this.width,
    this.action,
    this.title,
    this.isDisabled = false,
  });
  final double? height, width;
  final String? title;
  final void Function()? action;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isDisabled
          ? null
          : action ??
              () {
                removeScreen(context);
              },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Container(
          height: height ?? 35,
          width: width ?? 120,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: isDisabled ? grey : white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: grey),
          ),
          child: Center(
            child: Text(title ?? "Cancel", style: n15ts),
          ),
        ),
      ),
    );
  }
}

class LayBackCTA extends StatelessWidget {
  const LayBackCTA({
    super.key,
    required this.price,
    required this.isBack,
    this.isSelected = false,
    this.action,
    this.width,
    required this.isFlash,
    this.flashColor,
    this.disabled = false,
  });
  final double? width;
  final String? price;
  final bool isBack;
  final bool isSelected;
  final bool isFlash;
  final bool disabled;
  final Color? flashColor;
  final void Function()? action;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);

    // Determine background color
    Color bgColor;
    if (isSelected) {
      bgColor = isFlash && flashColor != null
          ? flashColor!
          : isBack
              ? oddsBackBtn
              : pinkButtonClr;
    } else {
      bgColor = isFlash && flashColor != null
          ? flashColor!
          : isBack
              ? backBtn
              : layBtn;
    }
    Color textColor = isSelected ? white : black;

    return InkWell(
      onTap: disabled ? null : action,
      borderRadius: BorderRadius.circular(3),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Container(
          height: 45,
          width: size.width * 0.04,
          decoration: BoxDecoration(
            color: (disabled && isBack)
                ? disabledBack
                : (disabled && !isBack)
                    ? disabledLay
                    : bgColor,
            border: Border.all(color: white),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            fit: StackFit.expand,
            children: [
              if (disabled)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                  child: CustomPaint(painter: DisabledStripePainter()),
                ),
              Center(
                child: Text(
                  price ?? "-",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: disabled ? black : textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// double ysb = 110;

class YesNoCTAButton extends StatelessWidget {
  const YesNoCTAButton({
    super.key,
    this.price,
    this.line,
    this.active = false,
    this.action,
    this.color,
    this.type = 1,
    this.isFlash = false,
    this.flashColor,
  });
  final int type;
  final Color? color;
  final bool active;
  final bool isFlash;
  final Color? flashColor;
  final String? price, line;
  final void Function()? action;

  @override
  Widget build(BuildContext context) {
    // Use flash color if flashing, otherwise use provided color or default
    final displayColor = isFlash && flashColor != null ? flashColor! : (color ?? (type == 1 ? (active ? oddsBackBtn : backBtn) : (active ? pinkButtonClr : layBtn)));
    return InkWell(
      onTap: action,
      child: Container(
        height: 45,
        width: blw(context),
        decoration: BoxDecoration(
          color: displayColor,
          border: Border.all(color: white),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                line ?? "-",
                style: b13ts(color: active ? white : black),
              ),
              Text(
                price ?? "-",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.normal,
                  color: active ? white : black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuickUnitButton extends StatefulWidget {
  const QuickUnitButton({
    super.key,
    required this.unit,
    this.color,
  });
  final Color? color;
  final TextEditingController unit;

  @override
  State<QuickUnitButton> createState() => _QuickUnitButtonState();
}

class _QuickUnitButtonState extends State<QuickUnitButton> {
  List<double> favStakesList = [];
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchFavStakeBloc, FetchFavStakeState>(
      builder: (context, state) {
        // Update favStakesList when data is loaded
        if (state is FetchFavStakeSuccess) {
          final favStakes = state.favStakeData.favStakes;
          if (favStakes.isNotEmpty) {
            favStakesList = favStakes.split(',').map((e) => double.tryParse(e.trim())).where((e) => e != null && e > 0).cast<double>().toList()..sort((a, b) => a.compareTo(b));
          }
        }

        // Default values if no data is available
        if (favStakesList.isEmpty) {
          favStakesList = [100, 300, 500, 1000, 1500, 2000, 2500, 3000];
        }

        return Container(
          color: widget.color == null ? white : applyOpacity(widget.color ?? white, 0.2),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 6,
              children: favStakesList.map((amount) {
                // Convert double to string (remove .0 if integer)
                final amountStr = amount == amount.toInt() ? amount.toInt().toString() : amount.toString();

                return OutlinedButton(
                  onPressed: () {
                    setState(() {
                      widget.unit.text = amountStr;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: white,
                    side: BorderSide(color: greyShade),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text(amountStr, style: n12ts),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class PremiumCTAButton extends StatelessWidget {
  const PremiumCTAButton({
    super.key,
    this.price,
    this.active = false,
    this.action,
    this.isFlash = false,
    this.flashColor,
  });
  final bool active;
  final bool isFlash;
  final Color? flashColor;
  final String? price;
  final void Function()? action;

  @override
  Widget build(BuildContext context) {
    // Use flash color if flashing, otherwise use provided color or default
    final displayColor = isFlash && flashColor != null
        ? flashColor!
        : active
            ? Color(0xff16A660)
            : Color(0xff72E3A0);
    return Row(
      children: [
        InkWell(
          onTap: action,
          child: Container(
            height: 45,
            width: blw(context) * 2,
            decoration: BoxDecoration(color: displayColor),
            child: Center(
              child: Text(
                price ?? "-",
                style: b13ts(color: active ? white : black),
              ),
            ),
          ),
        ),
        SizedBox(width: blw(context) * 2),
      ],
    );
  }
}
