import 'dart:developer';
import 'package:flutter/material.dart';
import '../../../models/fav_stake_model.dart';
import '../../../reusables/colors.dart';
import '../../../reusables/sized_box_hw.dart';

final ValueNotifier<String?> activeBetSlipId = ValueNotifier<String?>(null);

class MVBetSlipCard extends StatefulWidget {
  final String price;
  final String? betSize;
  final bool isBack;
  final bool isVisible;
  final FavStakeData? favStakeData;
  final TextEditingController betQtyController;
  final void Function()? cancelOnTap;
  final void Function()? betPlaceOnTap;

  const MVBetSlipCard({
    super.key,
    required this.price,
    required this.isBack,
    this.isVisible = false,
    this.betSize,
    this.cancelOnTap,
    this.betPlaceOnTap,
    required this.betQtyController,
    this.favStakeData,
  });

  @override
  State<MVBetSlipCard> createState() => _MVBetSlipCardState();
}

class _MVBetSlipCardState extends State<MVBetSlipCard> {
  final GlobalKey<FormState> betFormKey = GlobalKey<FormState>();
  final FocusNode focusNode = FocusNode();
  late List<double> values;
  double selectedValue = 0;
  bool isAcceptOdds = false;

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      setState(() {});
    });
    setStakeValues();
    if (widget.isVisible) {
      _scrollIntoView();
    }
  }

  @override
  void didUpdateWidget(covariant MVBetSlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.favStakeData != widget.favStakeData) {
      setStakeValues();
    }
    if (!oldWidget.isVisible && widget.isVisible) {
      _scrollIntoView();
    }
  }

  void _scrollIntoView() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.isVisible) return;
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        alignment: 0.5,
      );
    });
  }

  void setStakeValues() {
    try {
      if (widget.favStakeData != null && widget.favStakeData!.favStakes.trim().isNotEmpty) {
        values = widget.favStakeData!.favStakes.split(',').map((e) => double.tryParse(e.trim())).where((e) => e != null && e > 0).cast<double>().toList();
        if (values.isEmpty) {
          values = [100, 200, 250, 300, 500, 1000];
        }
      } else {
        values = [100, 200, 250, 300, 500, 1000];
      }

      selectedValue = values.first;
      widget.betQtyController.text = selectedValue.toString();
    } catch (e) {
      log("Error parsing favStakeData: $e");
      values = [100, 200, 250, 300, 500, 1000];
      selectedValue = values.first;
      widget.betQtyController.text = selectedValue.toString();
    }

    setState(() {});
  }

  void setSelectedValue(double v) {
    setState(() {
      selectedValue = v;
      widget.betQtyController.text = v.toString();
    });
  }

  void onKeyTap(String key) {
    String current = widget.betQtyController.text;

    setState(() {
      if (key == "⌫") {
        if (current.isNotEmpty) {
          widget.betQtyController.text = current.substring(0, current.length - 1);
        }
      } else {
        if ((key == "0" || key == "00") && current.isEmpty) return;
        if (key == "." && current.contains(".")) return;

        widget.betQtyController.text = current + key;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Container(
          color: widget.isBack ? backBatShitBg : layBatShitBg,
          child: Form(
            key: betFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text('', style: TextStyle(fontSize: 12)),
                          Container(
                            width: 180,
                            height: 43,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(176, 226, 221, 221),
                              border: Border.all(color: grey),
                              borderRadius: const BorderRadius.all(Radius.circular(5)),
                            ),
                            child: Center(
                              child: Text(
                                widget.betSize == null ? widget.price : "${widget.betSize} / ${widget.price}",
                                style: const TextStyle(color: grey, fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Min Bet', style: TextStyle(color: black, fontSize: 12)),
                          Container(
                            width: 180,
                            height: 43,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: Colors.grey.shade400, width: 1),
                            ),
                            child: Row(
                              children: [
                                /// Minus Button
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border(right: BorderSide(color: grey)),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        if (widget.betQtyController.text.isNotEmpty) {
                                          final val = int.tryParse(widget.betQtyController.text) ?? 0;
                                          if (val > 1) {
                                            widget.betQtyController.text = (val - 1).toString();
                                          }
                                        }
                                      },
                                      child: const Center(child: Icon(Icons.remove, color: Colors.blue, size: 30)),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: TextFormField(
                                    focusNode: focusNode,
                                    textAlign: TextAlign.center,
                                    controller: widget.betQtyController,
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(color: black, fontWeight: FontWeight.bold, fontSize: 15),
                                    decoration: InputDecoration(
                                      fillColor: focusNode.hasFocus ? textFormFieldFocusColor : white,
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border(left: BorderSide(color: grey)),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        final val = int.tryParse(widget.betQtyController.text) ?? 0;
                                        widget.betQtyController.text = (val + 1).toString();
                                      },
                                      child: const Center(child: Icon(Icons.add, color: Colors.blue, size: 30)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                hb8,
                Row(
                  children: values.map((v) {
                    final isSelected = selectedValue == v;
                    return Expanded(
                      child: InkWell(
                        onTap: () => setSelectedValue(v),
                        child: Container(
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border(
                              right: v != values.last ? const BorderSide(color: Colors.white24, width: 1) : BorderSide.none,
                            ),
                            gradient: isSelected
                                ? const LinearGradient(colors: [Colors.green, Colors.teal])
                                : const LinearGradient(
                                    colors: [Color(0xFF32617f), Color(0xFF1f4258)],
                                  ),
                          ),
                          child: Text(
                            "$v",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                hb10,

                /// Custom Keypad
                CustomKeypad(onKeyTap: onKeyTap),
                hb10,

                /// Action Buttons
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: widget.cancelOnTap,
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFFFFFFFF), Color(0xFFEEEEEE)],
                                stops: [0.0, 0.89],
                              ),
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Center(
                              child: Text(
                                "Cancel",
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: black),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          onTap: widget.betPlaceOnTap,
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(gradient: blackGrdntButton, borderRadius: BorderRadius.circular(5)),
                            child: const Center(
                              child: Text(
                                "Place Bet",
                                style: TextStyle(color: appBarText, fontSize: 17, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                hb8,
                Container(
                  decoration: BoxDecoration(color: widget.isBack ? backFooterBg : layFooterBg),
                  child: Row(
                    children: [
                      Checkbox(
                        value: isAcceptOdds,
                        activeColor: Colors.green, // ✅ active color set to green
                        onChanged: (value) {
                          setState(() {
                            isAcceptOdds = value ?? false;
                          });
                        },
                      ),
                      const Text("Accept Any Odds", style: TextStyle(color: black)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomKeypad extends StatelessWidget {
  final Function(String) onKeyTap;
  const CustomKeypad({super.key, required this.onKeyTap});

  @override
  Widget build(BuildContext context) {
    final keys = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "00", ".", "⌫"];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: keys.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        childAspectRatio: 1.5,
      ),
      itemBuilder: (context, index) {
        final key = keys[index];
        return InkWell(
          onTap: () => onKeyTap(key),
          child: Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(border: Border.all(color: Colors.black26)),
            child: Text(key, style: const TextStyle(fontSize: 18, color: black)),
          ),
        );
      },
    );
  }
}
