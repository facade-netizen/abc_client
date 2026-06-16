import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../constants/app_asset_constants.dart';

class CustomTextFormFieldWithFocus extends StatefulWidget {
  const CustomTextFormFieldWithFocus({
    super.key,
    required this.controller,
    this.hintText,
    this.width,
    this.obscureText = false,
    this.suffixIcon,
    this.textInputAction,
    this.validator,
    this.errorText,
    this.onChanged,
  });

  final TextEditingController controller;
  final String? hintText;
  final double? width;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  @override
  State<CustomTextFormFieldWithFocus> createState() => _CustomTextFormFieldWithFocusState();
}

class _CustomTextFormFieldWithFocusState extends State<CustomTextFormFieldWithFocus> {
  final FocusNode focusNode = FocusNode();
  final GlobalKey<FormFieldState<String>> _fieldKey = GlobalKey<FormFieldState<String>>();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasValidationError = _fieldKey.currentState?.hasError ?? false;
    final bool hasError = widget.errorText != null || hasValidationError;
    final Widget? errorIcon = hasError
        ? SizedBox(
            width: 28,
            height: 28,
            child: Center(
              child: SvgPicture.asset(
                AppAssetConstants.errorArt,
                width: 18,
                height: 18,
              ),
            ),
          )
        : null;

    Widget? suffixIcon = widget.suffixIcon;
    if (hasError) {
      suffixIcon = widget.suffixIcon == null
          ? errorIcon
          : Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                widget.suffixIcon!,
                errorIcon!,
              ],
            );
    }

    return SizedBox(
      width: widget.width ?? 360,
      child: TextFormField(
        key: _fieldKey,
        focusNode: focusNode,
        controller: widget.controller,
        keyboardType: TextInputType.text,
        obscureText: widget.obscureText,
        obscuringCharacter: '•',
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: (value) {
          widget.onChanged?.call(value);
          setState(() {});
        },
        textInputAction: widget.textInputAction ?? TextInputAction.next,
        validator: widget.validator ??
            (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Required';
              }
              return null;
            },
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF1e1e1e),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          filled: true,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          hintStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: hasError ? Color(0xFFD0021b) : Color(0xFF575757)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: hasError ? Color(0xFFD0021b) : Color(0xFFFFF0CA), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: hasError ? Color(0xFFD0021b) : Color(0xFFFFF0CA), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: hasError ? Color(0xFFD0021b) : Color(0xFFFFF0CA), width: 1),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Color(0xFFD0021b), width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Color(0xFFD0021b), width: 1),
          ),
          suffixIcon: suffixIcon,
          suffixIconConstraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          errorText: widget.errorText,
          errorStyle: const TextStyle(fontSize: 0, height: 0),
          fillColor: hasError
              ? const Color(0xFFFBD7D3)
              : focusNode.hasFocus
                  ? const Color(0xFFFFF0CA)
                  : const Color.fromRGBO(255, 255, 255, 1),
        ),
      ),
    );
  }
}
