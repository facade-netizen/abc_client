import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/fetchBlocs/fetch_sprots_category_bloc.dart';
import '../../../reusables/colors.dart';
import '../../../reusables/sized_box_hw.dart';
import '../../../reusables/style.dart';
import '../sportsReusables/custom_cta_button.dart';

class InplayFilterPopup extends StatefulWidget {
  final String title;
  final void Function(List<String>) onFilterSelected;
  const InplayFilterPopup({super.key, required this.title, required this.onFilterSelected});

  @override
  State<InplayFilterPopup> createState() => _InplayFilterPopupState();
}

class _InplayFilterPopupState extends State<InplayFilterPopup> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  Set<String> selectedItems = {};
  Set<String> saveList = {};
  final GlobalKey filterKey = GlobalKey();

  void _togglePopup() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      return;
    }

    final overlay = Overlay.of(context);
    RenderBox renderBox = filterKey.currentContext!.findRenderObject() as RenderBox;
    Offset offset = renderBox.localToGlobal(Offset.zero);
    Size size = renderBox.size;
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned(
              left: offset.dx,
              top: offset.dy + size.height,
              width: bw,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0.0, size.height + 2),
                child: Material(
                  elevation: 10,
                  borderRadius: BorderRadius.circular(10),
                  child: StatefulBuilder(
                    builder: (context, setOverlayState) {
                      return BlocBuilder<FetchSportsCategoryBloc, FetchSportsCategoryState>(
                        builder: (context, scs) {
                          List<String> sportsList = [];
                          if (scs is FetchSportsCategorySuccess) {
                            sportsList = scs.categoryResponse.data.map((e) => e.name).toList();
                            sportsList.insert(0, 'All');
                          }
                          return Container(
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                            child: Column(
                              children: [
                                hb10,
                                SizedBox(
                                  height: (sportsList.length * 30) + 15,
                                  child: ListView.builder(
                                    itemCount: sportsList.length,
                                    itemBuilder: (context, index) {
                                      final item = sportsList[index];
                                      return InplayFilterTile(
                                        title: item,
                                        value: selectedItems.contains(item),
                                        onChanged: (bool? value) {
                                          setOverlayState(() {
                                            if (index == 0) {
                                              // ALL selected
                                              if (value == true) {
                                                selectedItems = sportsList.toSet();
                                                saveList = sportsList.toSet();
                                              } else {
                                                selectedItems.clear();
                                                saveList.clear();
                                              }
                                            } else {
                                              if (value == true) {
                                                selectedItems.add(item);
                                                saveList.add(item);
                                              } else {
                                                selectedItems.remove(item);
                                                saveList.remove(item);
                                              }

                                              // auto handle ALL checkbox
                                              if (selectedItems.length == sportsList.length - 1) {
                                                selectedItems.add('All');
                                                saveList.add('All');
                                              } else {
                                                selectedItems.remove('All');
                                                saveList.remove('All');
                                              }
                                            }
                                          });
                                        },
                                      );
                                    },
                                  ),
                                ),
                                Divider(color: whiteOpac1),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      CustomCTAButton(
                                        width: bw / 2 - 25,
                                        title: 'Save',
                                        action: () {
                                          saveList.removeWhere((element) => element.contains('All'));
                                          widget.onFilterSelected(saveList.toList());
                                          _togglePopup();
                                        },
                                      ),
                                      CancelCTAButton(
                                        width: bw / 2 - 25,
                                        action: () {
                                          setOverlayState(() {
                                            selectedItems.clear();
                                            saveList.clear();
                                          });
                                          widget.onFilterSelected([]);
                                          _togglePopup();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                hb8,
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CompositedTransformTarget(
        link: _layerLink,
        child: InkWell(
          onTap: _togglePopup,
          child: SizedBox(
            width: bw,
            key: filterKey,
            child: CancelCTAButton(
              width: bw,
              title: "Filter",
              action: () {
                _togglePopup();
              },
            ),
          ),
        ),
      ),
    );
  }
}

double bw = 250;

class InplayFilterTile extends StatelessWidget {
  const InplayFilterTile({super.key, required this.title, this.value, this.onChanged});
  final String title;
  final bool? value;
  final void Function(bool?)? onChanged;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (onChanged != null) {
          onChanged!(!(value ?? false));
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Checkbox(
              checkColor: white,
              activeColor: bgCktbet,
              value: value,
              onChanged: onChanged,
            ),
            Expanded(child: Text(title, style: n15ts)),
          ],
        ),
      ),
    );
  }
}
