import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../reusables/colors.dart';

class LoginTextFormField extends StatelessWidget {
  const LoginTextFormField({
    super.key,
    this.height,
    this.width,
    this.hintText,
    this.suffixIcon,
    this.prefixIcon,
    this.controller,
    this.inputFormatters,
    this.maxLength,
    this.obscureText = false,
    this.readOnly = false,
    this.autofocus = true,
    this.onFieldSubmitted,
    this.onChanged,
  });
  final bool readOnly;
  final bool autofocus;
  final double? height;
  final double? width;
  final String? hintText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final int? maxLength;
  final bool obscureText;
  final void Function(String)? onFieldSubmitted;
  final void Function(String)? onChanged;
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        width: width ?? 180,
        height: height ?? 40,
        decoration: BoxDecoration(color: white, borderRadius: BorderRadius.all(Radius.circular(4))),
        padding: EdgeInsetsDirectional.all(2),
        child: TextFormField(
          readOnly: readOnly,
          focusNode: FocusNode(),
          onFieldSubmitted: onFieldSubmitted,
          onChanged: onChanged,
          controller: controller,
          enabled: !readOnly,
          autofocus: autofocus,
          keyboardType: TextInputType.text,
          maxLines: 1,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          obscuringCharacter: "*",
          obscureText: obscureText,
          textAlignVertical: TextAlignVertical.center,
          textInputAction: TextInputAction.next,
          style: const TextStyle(fontSize: 14, color: black),
          decoration: InputDecoration(
            filled: true,
            hintText: hintText,
            isDense: true,
            hintStyle: const TextStyle(fontSize: 12, color: black),
            fillColor: white,
            suffixIcon: suffixIcon ?? SizedBox(width: 0),
            prefixIcon: prefixIcon,
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            errorBorder: border(color: red),
            focusedBorder: border(),
            disabledBorder: border(color: none),
            enabledBorder: InputBorder.none,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}

InputBorder? border({Color color = black}) {
  return OutlineInputBorder(
    borderSide: BorderSide(color: color),
    borderRadius: BorderRadius.all(Radius.circular(4)),
  );
}
