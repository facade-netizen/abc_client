import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

import '../../../reusables/colors.dart';

class ResultSportDropdown extends StatefulWidget {
  const ResultSportDropdown({super.key, required this.selectedSport, required this.sports, required this.onChanged, this.width, this.height});

  final String? selectedSport;
  final List<String> sports;
  final Function(String?) onChanged;
  final double? width, height;

  @override
  State<ResultSportDropdown> createState() => _ResultSportDropdownState();
}

class _ResultSportDropdownState extends State<ResultSportDropdown> {
  late final ValueNotifier<String?> _selectedSportNotifier = ValueNotifier<String?>(widget.selectedSport);

  @override
  void didUpdateWidget(covariant ResultSportDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedSport != widget.selectedSport) {
      _selectedSportNotifier.value = widget.selectedSport;
    }
  }

  @override
  void dispose() {
    _selectedSportNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height ?? 30,
      width: widget.width ?? 200,
      child: DropdownButtonFormField2<String>(
        valueListenable: _selectedSportNotifier,
        isDense: false,
        isExpanded: true,
        iconStyleData: IconStyleData(icon: const Icon(Icons.arrow_drop_down, color: black)),
        dropdownStyleData: DropdownStyleData(
          elevation: 0,
          maxHeight: 300,
          decoration: BoxDecoration(
            color: white,
            border: Border.all(color: black),
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(padding: EdgeInsets.symmetric(horizontal: 10)),
        decoration: InputDecoration(
          filled: true,
          fillColor: white,
          contentPadding: const EdgeInsets.only(left: 10, right: 4),
          hintStyle: TextStyle(color: grey, fontSize: 14),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: bgCktbet, width: 2)),
          border: OutlineInputBorder(borderSide: BorderSide(color: grey)),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: black)),
        ),
        hint: const Text("Select Sport", style: TextStyle(color: black)),
        items: widget.sports
            .map(
              (sport) => DropdownItem<String>(
                value: sport,
                height: 30,
                child: Text(
                  sport,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: black),
                ),
              ),
            )
            .toList(),
        onChanged: (value) {
          _selectedSportNotifier.value = value;
          widget.onChanged(value);
        },
      ),
    );
  }
}
