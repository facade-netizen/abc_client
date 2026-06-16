import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

import '../../../../../reusables/colors.dart';
import '../../../reusables/sized_box_hw.dart';

class HighlightsFilter extends StatefulWidget {
  const HighlightsFilter({super.key, this.onChanged, required this.selectedItem, required this.dropdownItems, this.title});
  final String? title;
  final String selectedItem;
  final List<String> dropdownItems;
  final void Function(String?)? onChanged;

  @override
  State<HighlightsFilter> createState() => _HighlightsFilterState();
}

class _HighlightsFilterState extends State<HighlightsFilter> {
  late final ValueNotifier<String?> _valueNotifier = ValueNotifier<String?>(widget.selectedItem == '' ? null : widget.selectedItem);

  @override
  void didUpdateWidget(covariant HighlightsFilter oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newValue = widget.selectedItem == '' ? null : widget.selectedItem;
    if (_valueNotifier.value != newValue) {
      _valueNotifier.value = newValue;
    }
  }

  @override
  void dispose() {
    _valueNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Container(
        color: highlightHeader,
        height: 35,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title ?? 'Sports Highlights',
                style: const TextStyle(color: highlightText, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("View By", style: const TextStyle(color: black)),
                    wb30,
                    SizedBox(
                      height: 30,
                      width: 130,
                      child: DropdownButtonFormField2<String>(
                        isDense: false,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                          filled: true,
                          fillColor: bgCktbet,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: black),
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: black),
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: black, width: 2),
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                        ),
                        iconStyleData: const IconStyleData(icon: Icon(Icons.arrow_drop_down, size: 12), iconEnabledColor: black),
                        items: widget.dropdownItems.map<DropdownItem<String>>((String item) {
                          return DropdownItem<String>(
                            value: item,
                            height: 30,
                            child: Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                item,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: black, fontSize: 12),
                              ),
                            ),
                          );
                        }).toList(),
                        hint: const Text("Select", style: TextStyle(color: black, fontSize: 12)),
                        valueListenable: _valueNotifier,
                        isExpanded: true,
                        onChanged: (value) {
                          _valueNotifier.value = value;
                          widget.onChanged?.call(value);
                        },
                        onSaved: widget.onChanged,
                        dropdownStyleData: DropdownStyleData(
                          decoration: BoxDecoration(
                            color: white,
                            border: Border.all(color: black),
                          ),
                          maxHeight: 100,
                        ),
                        menuItemStyleData: const MenuItemStyleData(padding: EdgeInsets.symmetric(horizontal: 8)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
