import 'package:flutter/services.dart';

TextInputFormatter integers = FilteringTextInputFormatter.allow(RegExp("[0-9]"));
TextInputFormatter ibanExp = FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]'));
TextInputFormatter phoneNumberFilter = FilteringTextInputFormatter.allow(RegExp(r'[0-9]'));
TextInputFormatter spaceAndDotFilter = FilteringTextInputFormatter.deny(RegExp('[\\s\\.]'));
TextInputFormatter greaterThanOrEqualToZeroWithDecimal = FilteringTextInputFormatter.allow(RegExp(r'^([1-9][0-9]*|0)(\.[0-9]*)?$'));
TextInputFormatter specialCharacters = FilteringTextInputFormatter.deny(RegExp(r'[!@#%^&*(),£_+/``.•√π?":÷×§∆€{}¥$¢°;\~|<>=\©®™✓-]'));
