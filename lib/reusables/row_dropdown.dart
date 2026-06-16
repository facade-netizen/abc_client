import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

import 'colors.dart';
import 'highlighted_text_widget.dart';

class RowDropdown<T> extends StatefulWidget {
  final T value;
  final List<T> items;
  final double? width;
  final double? height;
  final Function(T?) onChanged;
  final String? hintText;

  final String? title;
  const RowDropdown({super.key, required this.value, required this.items, this.width, this.height, required this.onChanged, this.hintText, this.title});

  @override
  State<RowDropdown<T>> createState() => _RowDropdownState<T>();
}

class _RowDropdownState<T> extends State<RowDropdown<T>> {
  late final ValueNotifier<T?> _valueNotifier = ValueNotifier<T?>(widget.value);

  @override
  void didUpdateWidget(covariant RowDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_valueNotifier.value != widget.value) {
      _valueNotifier.value = widget.value;
    }
  }

  @override
  void dispose() {
    _valueNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (widget.title != null)
          HighlightText(
            '${widget.title} :',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: black),
          ),
        SizedBox(
          height: widget.height ?? 30,
          width: widget.width ?? 150,
          child: DropdownButtonFormField2<T>(
            valueListenable: _valueNotifier,
            isDense: false,
            isExpanded: true,
            iconStyleData: IconStyleData(icon: const Icon(Icons.arrow_drop_down, color: black)),
            dropdownStyleData: DropdownStyleData(
              elevation: 0,
              width: widget.width ?? 150,
              maxHeight: ((widget.items.isNotEmpty ? widget.items.length : 1) * 30) + 20,
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
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: blue, width: 2)),
              border: OutlineInputBorder(borderSide: BorderSide(color: grey)),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: grey)),
            ),
            items: widget.items.map((item) {
              return DropdownItem<T>(
                value: item,
                height: 30,
                child: Text(
                  item.toString(),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: black),
                ),
              );
            }).toList(),
            onChanged: (value) {
              _valueNotifier.value = value;
              widget.onChanged(value);
            },
            hint: widget.hintText != null ? Text(widget.hintText!, style: TextStyle(fontSize: 12, color: Colors.grey)) : null,
          ),
        ),
      ],
    );
  }
}
