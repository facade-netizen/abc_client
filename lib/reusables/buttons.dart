import 'package:flutter/material.dart';

import '../constants/app_asset_constants.dart';
import 'border_radius.dart';
import 'colors.dart';
import 'sized_box_hw.dart';
import 'style.dart';
import 'text_style.dart';

class ColouredElevatedButton extends StatelessWidget {
  const ColouredElevatedButton({super.key, required this.onCLick, required this.child, this.gradientColor, this.height, required this.width, this.color});

  final LinearGradient? gradientColor;
  final Color? color;
  final Function() onCLick;
  final Widget child;
  final double? height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onCLick,
      child: Container(
        height: height,
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
        decoration: BoxDecoration(
          gradient: gradientColor,
          color: color,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Color(0xFF000000), width: 0.6),
          boxShadow: [BoxShadow(color: Color(0xFF000000).withValues(alpha: 0.2), blurRadius: 6, offset: const Offset(0, 3))],
        ),
        child: Center(child: child),
      ),
    );
  }
}

class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton({super.key, required this.onPressed, required this.controller, required this.title});
  final void Function()? onPressed;
  final String title;
  final TextEditingController controller;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: controller.text.length < 10 ? null : onPressed,
      child: Container(
        height: 44,
        width: double.infinity,
        decoration: BoxDecoration(gradient: yellowGradient, borderRadius: borderRadius8()),
        child: Center(child: Text(title, style: customButtonStyle())),
      ),
    );
  }
}

class MultiTextButton extends StatelessWidget {
  final String value;
  final String amnt;
  final Color? color;
  final void Function()? onTap;
  const MultiTextButton({super.key, this.color, required this.value, required this.amnt, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
        color: color,
        child: Column(
          children: [
            Text(value, style: tStyleBold16.copyWith(color: black)),
            hb4,
            Text(amnt, style: tStyle12.copyWith(color: black)),
          ],
        ),
      ),
    );
  }
}

class SmallColoredButton extends StatelessWidget {
  final String title;
  final Color color;
  final Color? titleColor;
  final Color borderColor;
  final double vertical;
  final double? width;
  final void Function()? onTap;
  const SmallColoredButton({super.key, required this.title, this.onTap, required this.color, required this.vertical, this.width, required this.borderColor, this.titleColor});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius4(),
          border: Border.all(color: borderColor),
        ),
        padding: EdgeInsets.symmetric(vertical: vertical),
        child: Center(
          child: Text(title, style: TextStyle(color: titleColor)),
        ),
      ),
    );
  }
}

class CustomSmallSaveButton extends StatelessWidget {
  const CustomSmallSaveButton({
    super.key,
    this.width,
    this.title,
    this.action,
    this.buttonColor,
    this.borderColor,
    this.titleColor,
    this.topPadding = true,
    this.customWidth = true,
    this.bottomLeftAlignment = false,
  });
  final double? width;
  final String? title;
  final bool? topPadding;
  final bool? customWidth;
  final Color? buttonColor;
  final Color? borderColor;
  final Color? titleColor;
  final bool bottomLeftAlignment;
  final void Function()? action;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    double tfw = size.width < 800 ? size.width : size.width * (size.width > 1100 ? 0.36 : 0.5) / 2 - 5;
    return Align(
      alignment: bottomLeftAlignment ? Alignment.bottomLeft : Alignment.bottomRight,
      child: Padding(
        padding: EdgeInsets.only(top: (topPadding == true) ? 30 : 0),
        child: SizedBox(
          width: width ?? (customWidth == true ? (tfw) : (size.width)),
          child: ElevatedButton(
            onPressed: action,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              side: BorderSide(color: borderColor ?? secondaryClr),
              backgroundColor: buttonColor ?? secondaryClr,
              disabledBackgroundColor: grey,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                title ?? 'Save',
                style: TextStyle(fontSize: 16, color: titleColor ?? black, overflow: TextOverflow.ellipsis),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomOutlinedButton extends StatelessWidget {
  const CustomOutlinedButton({super.key, this.action, required this.title});
  final String title;
  final void Function()? action;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton(
        onPressed: action,
        style: OutlinedButton.styleFrom(
          foregroundColor: white,
          side: const BorderSide(color: secondaryClr, style: BorderStyle.solid),
        ),
        child: Text(title, style: const TextStyle(color: secondaryClr)),
      ),
    );
  }
}

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key, this.action});
  final void Function()? action;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: IconButton(onPressed: action, icon: const Icon(Icons.arrow_back_ios, size: 15)),
    );
  }
}

class CustomActionButton extends StatelessWidget {
  const CustomActionButton({super.key, this.width, this.height, this.onPressed, this.backgroundColor, required this.buttonTitle, required this.colorBorderSide});
  final double? width;
  final double? height;
  final String buttonTitle;
  final Color colorBorderSide;
  final Color? backgroundColor;
  final void Function()? onPressed;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
            side: BorderSide(color: colorBorderSide),
          ),
          backgroundColor: backgroundColor,
        ),
        onPressed: onPressed,
        child: Text(
          buttonTitle,
          style: const TextStyle(color: white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class CustomOutlinedWithWidthButton extends StatelessWidget {
  const CustomOutlinedWithWidthButton({super.key, this.width, this.color, this.action, required this.title});
  final Color? color;
  final String title;
  final double? width;
  final void Function()? action;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 120,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: OutlinedButton(
          onPressed: action,
          style: OutlinedButton.styleFrom(
            foregroundColor: white,
            side: BorderSide(color: color ?? secondaryClr, style: BorderStyle.solid),
          ),
          child: Text(title, style: TextStyle(color: color ?? secondaryClr)),
        ),
      ),
    );
  }
}

class ColoredTextButton extends StatefulWidget {
  const ColoredTextButton({super.key, required this.name, this.width, this.height, this.onTap, this.fontSize, this.textColor});

  final String name;
  final double? width;
  final double? height;
  final double? fontSize;
  final Color? textColor;
  final void Function()? onTap;

  @override
  State<ColoredTextButton> createState() => _ColoredTextButtonState();
}

class _ColoredTextButtonState extends State<ColoredTextButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        height: widget.height ?? 30,
        width: widget.width ?? 30,
        decoration: BoxDecoration(
          gradient: blackGrdntButton,
          border: Border.all(color: Color(0xFF222222), width: 0.6),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Text(
            widget.name,
            style: TextStyle(letterSpacing: 0.8, color: widget.textColor ?? Color(0xFFffb600), fontSize: widget.fontSize, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class CustomFAB extends StatelessWidget {
  final VoidCallback onPressed;

  const CustomFAB({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: 60,
        width: 60,
        margin: EdgeInsets.only(top: 18, right: 5),
        decoration: BoxDecoration(
          color: appYellow,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(25), bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25), topRight: Radius.circular(5)),
        ),
        child: Center(child: Image.asset(AppAssetConstants.favicon, fit: BoxFit.contain, height: 25, width: 25)),
      ),
    );
  }
}

class FabClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(20)));
    path.addOval(Rect.fromCircle(center: Offset(0, 0), radius: 30));
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class CustomOCTAButton extends StatelessWidget {
  const CustomOCTAButton({super.key, required this.title, this.width, this.height, this.action, this.fontSize, this.textColor, this.borderColor, this.fontWeight, this.icon});
  final IconData? icon;
  final String title;
  final double? width;
  final double? height;
  final double? fontSize;
  final Color? textColor;
  final Color? borderColor;
  final FontWeight? fontWeight;
  final VoidCallback? action;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 120,
      height: height ?? 30,
      child: OutlinedButton(
        onPressed: action,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(white),
          foregroundColor: WidgetStateProperty.all(textColor ?? blue),
          side: WidgetStateProperty.resolveWith<BorderSide>((states) {
            return BorderSide(color: borderColor ?? grey, width: states.contains(WidgetState.hovered) ? 1.2 : 1);
          }),
          overlayColor: WidgetStateProperty.all(blue.withValues(alpha: 0.1)),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
          padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 6)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null) Icon(icon, color: textColor ?? black),
            if (icon != null) wb4,
            Text(
              title,
              style: TextStyle(fontSize: fontSize ?? 14, fontWeight: fontWeight ?? FontWeight.w500, color: textColor ?? black),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomECTAButton extends StatelessWidget {
  const CustomECTAButton({super.key, required this.title, this.width, this.height, this.action, this.fontSize, this.textColor, this.borderColor, this.fontWeight});

  final String title;
  final double? width;
  final double? height;
  final double? fontSize;
  final Color? textColor;
  final Color? borderColor;
  final FontWeight? fontWeight;
  final VoidCallback? action;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = action != null;

    return SizedBox(
      width: width ?? 130,
      height: height ?? 30,
      child: Opacity(
        opacity: isEnabled ? 1 : 0.65,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: action,
            borderRadius: BorderRadius.circular(4),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: borderColor ?? const Color(0xFF0F0F0F), width: 1),
                gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF3A3A3A), Color(0xFF1D1D1D), Color(0xFF0D0D0D)]),
                boxShadow: [BoxShadow(color: black.withValues(alpha: 0.25), offset: const Offset(0, 1), blurRadius: 2)],
              ),
              child: Center(
                child: Text(
                  title,
                  style: TextStyle(fontSize: fontSize ?? 14, fontWeight: fontWeight ?? FontWeight.w700, color: textColor ?? appYellow),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppQRAndDownloadButton extends StatelessWidget {
  const AppQRAndDownloadButton({super.key, required this.image, this.onTap});
  final String image;
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 50,
            width: 200,
            decoration: BoxDecoration(
              gradient: yellowGradient,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: black, width: 0.6),
              image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
            ),
          ),
        ),
        hb5,
        Text(
          "v 0.0.1 (1) 2026-02-25 - 15MB",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: black),
        ),
      ],
    );
  }
}
