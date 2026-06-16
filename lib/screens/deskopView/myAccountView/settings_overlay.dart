import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/addBloc/add_fav_stake_bloc.dart';
import '../../../blocs/addBloc/update_onclick_bet_bloc.dart';
import '../../../blocs/authBlocs/user_auth_change_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_fav_stake_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_one_click_data_bloc.dart';
import '../../../models/fav_stake_model.dart';
import '../../../reusables/colors.dart';
import '../../../reusables/regexes.dart';
import '../../../reusables/sized_box_hw.dart';
import '../../../reusables/style.dart';
import '../authView/desktop_login_view.dart';
import '../sportsReusables/custom_cta_button.dart';

double obw = 280;

class SettingsOverlay extends StatefulWidget {
  const SettingsOverlay({super.key});
  @override
  State<SettingsOverlay> createState() => _SettingsOverlayState();
}

class _SettingsOverlayState extends State<SettingsOverlay> {
  bool isChecked = false;
  bool isCheckedInitialized = false;
  final LayerLink layerLink = LayerLink();
  OverlayEntry? overlayEntry;
  int isHovered = -1;
  final GlobalKey filterKey = GlobalKey();

  // Method to close overlay - always works
  void closeOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  void toggleAccountMenu() {
    if (overlayEntry != null) {
      closeOverlay();
      return;
    }

    final overlay = Overlay.of(context);
    RenderBox renderBox = filterKey.currentContext!.findRenderObject() as RenderBox;
    Offset offset = renderBox.localToGlobal(Offset.zero);
    Size size = renderBox.size;

    overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: offset.dx,
          top: offset.dy + size.height,
          width: obw + 50,
          child: CompositedTransformFollower(
            link: layerLink,
            showWhenUnlinked: false,
            offset: Offset(-200, size.height + 5),
            child: Material(
              elevation: 5,
              color: lightBlueShade,
              borderRadius: BorderRadius.circular(10),
              child: BlocBuilder<FetchFavStakeBloc, FetchFavStakeState>(
                builder: (context, fss) {
                  return SettingsPanel(onClose: closeOverlay, favStakeData: fss is FetchFavStakeSuccess ? fss.favStakeData : null);
                },
              ),
            ),
          ),
        );
      },
    );
    overlay.insert(overlayEntry!);
  }

  @override
  void initState() {
    super.initState();
    context.read<FetchFavStakeBloc>().add(FetchFavStake());
  }

  @override
  void dispose() {
    closeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return BlocBuilder<UserAuthChangesBloc, UserAuthChangesState>(
      builder: (context, ucs) {
        bool isLoggedIn = false;
        if (ucs is UserAuthChangesSuccess) {
          isLoggedIn = ucs.savedUserAuth != null;
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (size.width >= 1536 && !isLoggedIn)
              RichText(
                text: TextSpan(
                  text: 'Time Zone : ',
                  style: const TextStyle(color: black, fontSize: 14),
                  children: [
                    TextSpan(
                      text: 'GMT+5:30',
                      style: const TextStyle(color: black, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            wb10,
            BlocListener<UpdateOnclickBetBloc, UpdateOnclickBetState>(
              listener: (context, state) {
                if (state is UpdateOnclickBetSuccess) {
                  context.read<FetchOneClickDataBloc>().add(FetchOneClickData());
                }
              },
              child: BlocBuilder<FetchOneClickDataBloc, FetchOneClickDataState>(
                builder: (context, state) {
                  if (state is FetchOneClickDataSuccess && !isCheckedInitialized) {
                    isChecked = state.oneClickData.isClicked;
                    isCheckedInitialized = true;
                  }
                  return Container(
                    decoration: BoxDecoration(gradient: isChecked ? successGradient : bottomBarGradient),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: isChecked,
                            onChanged: (value) {
                              if (isLoggedIn) {
                                final nextValue = value ?? false;
                                setState(() {
                                  isChecked = nextValue;
                                });
                                context.read<UpdateOnclickBetBloc>().add(UpdateOnclickBet(type: 1, isClicked: nextValue));
                              } else {
                                desktopLoginView(context);
                              }
                            },
                            fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
                              if (states.contains(WidgetState.selected)) {
                                return isChecked ? Color(0xFF02BD58) : bgCktbet;
                              }
                              return Colors.grey;
                            }),
                            checkColor: black,
                            side: WidgetStateBorderSide.resolveWith((states) {
                              if (states.contains(WidgetState.selected)) {
                                return const BorderSide(color: white, width: 0.5);
                              }
                              return const BorderSide(color: white, width: 0.2);
                            }),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          Text(
                            'One Click Bet',
                            style: TextStyle(color: isChecked ? black : bgCktbet, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            CompositedTransformTarget(
              link: layerLink,
              child: BlocBuilder<UserAuthChangesBloc, UserAuthChangesState>(
                builder: (context, ucs) {
                  return CustomCTAButton(
                    key: filterKey,
                    width: 130,
                    title: "Setting",
                    icon: Icons.settings,
                    color: black,
                    gradientColor: noneGradient,
                    action: () {
                      if (isLoggedIn) {
                        toggleAccountMenu();
                      } else {
                        desktopLoginView(context);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class SettingsPanel extends StatefulWidget {
  const SettingsPanel({super.key, this.onClose, this.favStakeData});

  final VoidCallback? onClose;
  final FavStakeData? favStakeData;

  @override
  State<SettingsPanel> createState() => SettingsPanelState();
}

class SettingsPanelState extends State<SettingsPanel> {
  TextEditingController stakeController = TextEditingController();
  final FocusNode focusNodeDefaultStake = FocusNode();
  final FocusNode focusNodeQuickStack = FocusNode();

  final List<String> numbers = ["100", "200", "300", "500", "1000", "1500", "2000", "25000"];

  List<String> selectedIndexList = ["100", "200", "300", "500", "1000", "1500"];

  late List<TextEditingController> quickStakeControllers;
  late List<FocusNode> quickStakeFocusNodes;

  bool isEditable = false;
  bool fancyBetAnyOdds = false;
  bool sportsBookAnyOdds = false;
  bool enableForecastWithCommission = false;
  bool oddsAnyOdds = false;
  bool singleClick = false;

  @override
  void initState() {
    super.initState();
    quickStakeControllers = numbers.map((n) => TextEditingController(text: n)).toList();
    quickStakeFocusNodes = List.generate(numbers.length, (_) => FocusNode()..addListener(() => setState(() {})));
    focusNodeDefaultStake.addListener(() => setState(() {}));
    if (widget.favStakeData != null) {
      final data = widget.favStakeData!;
      stakeController.text = data.defaultStake.toString();
      singleClick = data.singleClick;
      fancyBetAnyOdds = data.fancyBetAnyOdds;
      sportsBookAnyOdds = data.sportsBookAnyOdds;
      oddsAnyOdds = data.oddsAnyOdds;
      enableForecastWithCommission = data.enableForecastWithCommission;
      final favList = data.favStakes.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      selectedIndexList = List.from(favList); // ✅ FIX
      final commonList = data.commonStakes.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      for (int i = 0; i < commonList.length && i < quickStakeControllers.length; i++) {
        quickStakeControllers[i].text = commonList[i];
      }
    }
  }

  @override
  void dispose() {
    stakeController.dispose();
    focusNodeDefaultStake.dispose();
    focusNodeQuickStack.dispose();
    for (var c in quickStakeControllers) {
      c.dispose();
    }
    for (var f in quickStakeFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void saveSettings() {
    final body = {
      "favStakes": selectedIndexList.map((e) => double.tryParse(e) ?? 0).join(","), // ✅ correct
      "commonStakes": quickStakeControllers.map((c) => double.tryParse(c.text) ?? 0).join(","),
      "singleClick": singleClick,
      "fancyBetAnyOdds": fancyBetAnyOdds,
      "sportsBookAnyOdds": sportsBookAnyOdds,
      "oddsAnyOdds": oddsAnyOdds,
      "enableForecastWithCommission": enableForecastWithCommission,
      "defaultStake": double.tryParse(stakeController.text) ?? 0,
    };
    context.read<AddFavStakeBloc>().add(AddFavStake(body: body));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddFavStakeBloc, AddFavStakeState>(
      listener: (context, state) {
        if (state is AddFavStakeSuccess) {
          context.read<FetchFavStakeBloc>().add(FetchFavStake());
          // Auto close after a short delay
          Future.delayed(const Duration(microseconds: 100), () {
            if (mounted) {
              debugPrint("Calling onClose callback");
              widget.onClose?.call();
            }
          });
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Default Stake
                Row(
                  children: [
                    sectionTitle("Default stake"),
                    wb30,
                    Expanded(
                      child: TextField(
                        controller: stakeController,
                        style: const TextStyle(fontSize: 13, color: black),
                        cursorColor: black,
                        keyboardType: TextInputType.number,
                        inputFormatters: [integers, LengthLimitingTextInputFormatter(7)],
                        decoration: const InputDecoration(fillColor: white, filled: true, border: InputBorder.none, isDense: true),
                      ),
                    ),
                  ],
                ),
                const Divider(color: darkGreen),

                // Quick Stakes
                sectionTitle("Quick Stakes"),
                hb10,
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: List.generate(numbers.length, (index) {
                    final controller = quickStakeControllers[index];
                    final value = controller.text; // ✅ FIX
                    final isSelected = selectedIndexList.contains(value);
                    final focusNode = quickStakeFocusNodes[index];

                    return Container(
                      height: 35,
                      width: obw / 4,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(gradient: isSelected && !isEditable ? blackGrdntButton : whiteGradient, borderRadius: BorderRadius.circular(4)),
                      child: TextField(
                        focusNode: focusNode,
                        controller: quickStakeControllers[index],
                        readOnly: !isEditable,
                        textAlign: TextAlign.center,
                        cursorColor: black,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected && !isEditable ? FontWeight.bold : FontWeight.normal,
                          color: isSelected && !isEditable ? bgCktbet : black,
                        ),
                        inputFormatters: [integers, LengthLimitingTextInputFormatter(7)],
                        decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                        onTap: () {
                          if (!isEditable) {
                            setState(() {
                              final currentValue = controller.text; // ✅ FIX
                              if (selectedIndexList.contains(currentValue)) {
                                selectedIndexList.remove(currentValue);
                              } else {
                                if (selectedIndexList.length < 6) {
                                  selectedIndexList.add(currentValue);
                                } else {
                                  selectedIndexList.removeAt(0);
                                  selectedIndexList.add(currentValue);
                                }
                              }
                            });
                          }
                        },
                        onChanged: (val) {
                          setState(() {
                            for (int i = 0; i < selectedIndexList.length; i++) {
                              if (selectedIndexList[i] == value) {
                                selectedIndexList[i] = val;
                              }
                            }
                          });
                        },
                      ),
                    );
                  }),
                ),
                hb10,

                // Edit/OK button
                InkWell(
                  onTap: () {
                    setState(() {
                      isEditable = !isEditable;
                    });
                  },
                  child: Container(
                    width: obw + 25,
                    height: 30,
                    decoration: BoxDecoration(gradient: isEditable ? blackGrdntButton : whiteGradient, borderRadius: BorderRadius.circular(4)),
                    child: Center(
                      child: Text(
                        isEditable ? "OK" : "Edit Stakes",
                        style: TextStyle(color: isEditable ? bgCktbet : black, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),

                const Divider(color: darkGreen),
                sectionTitle("Odds"),
                checkBoxTile("Highlight when odds change", oddsAnyOdds, (v) => setState(() => oddsAnyOdds = v)),

                const Divider(color: darkGreen),
                sectionTitle("FancyBet"),
                checkBoxTile("Accept Any Odds", fancyBetAnyOdds, (v) => setState(() => fancyBetAnyOdds = v)),

                const Divider(color: darkGreen),
                sectionTitle("SportsBook"),
                checkBoxTile("Accept Any Odds", sportsBookAnyOdds, (v) => setState(() => sportsBookAnyOdds = v)),

                const Divider(color: darkGreen),
                sectionTitle("Win Selection forecast"),
                checkBoxTile("With Commission", enableForecastWithCommission, (v) => setState(() => enableForecastWithCommission = v)),

                const Divider(color: darkGreen),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CancelCTAButton(isDisabled: isEditable, width: (obw - 10) / 2, action: widget.onClose),
                    CustomCTAButton(isDisabled: isEditable, width: (obw - 10) / 2, color: bgCktbet, title: "Save", action: isEditable ? null : saveSettings),
                  ],
                ),
                hb10,
              ],
            ),
          ),
        );
      },
    );
  }
}

// Helper widgets
Widget sectionTitle(String text) {
  return Text(text, style: b13ts(color: darkGreen));
}

Widget checkBoxTile(String text, bool value, Function(bool) onChanged) {
  return Row(
    children: [
      Checkbox(checkColor: white, activeColor: bgCktbet, value: value, onChanged: (v) => onChanged(v!)),
      Expanded(child: Text(text, style: n12ts)),
    ],
  );
}
