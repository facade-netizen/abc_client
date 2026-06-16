import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import '../../../blocs/fetchBlocs/fetch_open_orders_bloc.dart';
import '../../../models/open_order_model.dart';
import '../../../reusables/colors.dart';
import '../../../reusables/data_not_found.dart';
import '../../../reusables/loader.dart';
import '../sportsReusables/sports_header.dart';
import 'open_bets_cards.dart';

class OpenBetsCard extends StatefulWidget {
  const OpenBetsCard({super.key});

  @override
  State<OpenBetsCard> createState() => _OpenBetsCardState();
}

class _OpenBetsCardState extends State<OpenBetsCard> {
  OpenEventBettingData? selectedEvent;
  List<OpenOrder>? openOrdersData;
  List<OpenEventBettingData> openOrderData = [];
  String? selectedItem;
  final ValueNotifier<String?> _selectedItemNotifier = ValueNotifier<String?>(null);

  @override
  void dispose() {
    _selectedItemNotifier.dispose();
    super.dispose();
  }

  void resetSelection() {
    selectedItem = null;
    selectedEvent = null;
    openOrdersData = null;
    _selectedItemNotifier.value = null;
  }

  void autoSelectFirst(List<OpenEventBettingData> data) {
    if (selectedItem != null || data.isEmpty) return;
    final first = data.first;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        selectedItem = first.name;
        selectedEvent = first;
        openOrdersData = first.openOrders;
      });
      _selectedItemNotifier.value = first.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchOpenOrdersBloc, FetchOpenOrdersState>(
      builder: (context, oos) {
        if (oos is FetchOpenOrdersSuccess) {
          openOrderData = oos.openOrderData;
          // 🔤 Sort alphabetically by event name
          openOrderData.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
          //autoSelectFirst(openOrderData);
        }

        if (oos is FetchOpenOrdersProgress) {
          resetSelection();
        }
        return Container(
          color: white,
          child: oos is FetchOpenOrdersProgress
              ? LoaderContainerWithMessage()
              : openOrderData.isEmpty
              ? DataNotFound(message: "No open bets")
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: SizedBox(
                        height: 40,
                        child: DropdownButtonFormField2<String>(
                          isDense: false,
                          isExpanded: true,
                          iconStyleData: IconStyleData(icon: const Icon(Icons.arrow_drop_down, color: black)),
                          valueListenable: _selectedItemNotifier,
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
                          hint: const Text("Select Event", style: TextStyle(color: black)),
                          items: openOrderData
                              .map(
                                (event) => DropdownItem<String>(
                                  value: event.name,
                                  height: 30,
                                  child: Text(
                                    event.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14, color: black),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            final event = openOrderData.firstWhere((e) => e.name == value);
                            setState(() {
                              selectedItem = value;
                              selectedEvent = event;
                              openOrdersData = event.openOrders;
                            });
                            _selectedItemNotifier.value = value;
                          },
                        ),
                      ),
                    ),

                    /// DETAILS
                    if (openOrdersData != null) ...[
                      SportsHeader(title: "Matched", color: primaryGradient),
                      Expanded(
                        child: OpenBetsCardDetails(openOrders: openOrdersData!, openInEvent: selectedEvent?.name ?? ""),
                      ),
                    ],
                  ],
                ),
        );
      },
    );
  }
}
