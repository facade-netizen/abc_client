import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import '../../../blocs/addBloc/add_fav_stake_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_fav_stake_bloc.dart';
import '../../../constants/app_asset_constants.dart';
import '../../../models/fav_stake_model.dart';
import '../../../reusables/colors.dart';
import '../../../reusables/custom_headers.dart';
import '../../../reusables/sized_box_hw.dart';
import '../../../reusables/style.dart';
import '../../../services/navigators.dart';

class MvDefaultStakesScreen extends StatefulWidget {
  const MvDefaultStakesScreen({super.key, this.favStakeData});
  final FavStakeData? favStakeData;

  @override
  State<MvDefaultStakesScreen> createState() => _MvDefaultStakesScreenState();
}

class _MvDefaultStakesScreenState extends State<MvDefaultStakesScreen> {
  TextEditingController stakeController = TextEditingController();
  final FocusNode focusNodeDefaultStake = FocusNode();
  final FocusNode focusNodeQuickStack = FocusNode();

  final List<String> numbers = [
    "100",
    "200",
    "300",
    "500",
    "1000",
    "1500",
    "2000",
    "25000",
  ];

  List<String> selectedIndexList = [
    "100",
    "200",
    "300",
    "500",
    "1000",
    "1500",
  ];

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
    quickStakeFocusNodes = List.generate(
      numbers.length,
      (_) => FocusNode()..addListener(() => setState(() {})),
    );
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

  Color getRandomColor() {
    final random = Random();
    return Color.fromARGB(255, random.nextInt(256), random.nextInt(256), random.nextInt(256));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddFavStakeBloc, AddFavStakeState>(
      listener: (context, state) {
        if (state is AddFavStakeSuccess) {
          context.read<FetchFavStakeBloc>().add(FetchFavStake());
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            CustomHeadersWithSvgAndTitle(
              svgIcon: AppAssetConstants.setting,
              headerTitle: 'Setting',
              onTap: () => removeScreen(context),
            ),
            CustomHeadersBlueGredWithTitle(headerTitle: "Stake"),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text("Default stake", style: TextStyle(color: secondaryTextClr, fontSize: 16, fontWeight: FontWeight.w500)),
                  wb10,
                  SizedBox(
                    width: 150,
                    height: 40,
                    child: TextFormField(
                      focusNode: focusNodeDefaultStake,
                      cursorColor: black,
                      style: TextStyle(color: black, fontSize: 15),
                      textAlign: TextAlign.center,
                      controller: stakeController,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.number,
                      decoration: tfInputDecoration.copyWith(
                        fillColor: focusNodeDefaultStake.hasFocus ? textFormFieldFocusColor : white,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: grey, thickness: 0.5),

            /// Quick Stakes
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Quick Stakes", style: TextStyle(color: secondaryTextClr, fontSize: 16, fontWeight: FontWeight.w500)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Wrap(
                    spacing: 5,
                    runSpacing: 10,
                    children: List.generate(numbers.length, (index) {
                      final controller = quickStakeControllers[index];
                      final value = controller.text; // ✅ FIX
                      final isSelected = selectedIndexList.contains(value);
                      final focusNode = quickStakeFocusNodes[index];
                      return SizedBox(
                        width: 100,
                        height: 40,
                        child: TextFormField(
                          focusNode: focusNode,
                          readOnly: !isEditable,
                          textAlign: TextAlign.center,
                          controller: quickStakeControllers[index],
                          cursorColor: black,
                          style: TextStyle(
                            color: isSelected && !isEditable ? appBarText : black,
                            fontWeight: isSelected && !isEditable ? FontWeight.bold : FontWeight.normal,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                            filled: true,
                            fillColor: isSelected && !isEditable
                                ? Colors.grey[800]
                                : focusNode.hasFocus
                                    ? textFormFieldFocusColor
                                    : white,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
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
                ),
                hb10,
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () => setState(() => isEditable = !isEditable),
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: isEditable ? blackGrdntButton : editBtn,
                        border: Border.all(color: grey),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isEditable ? "OK" : "Edit Stake",
                              style: TextStyle(color: isEditable ? appBarText : secondaryTextClr, fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            wb5,
                            SvgPicture.asset(AppAssetConstants.editIcon, colorFilter: ColorFilter.mode(secondaryTextClr, BlendMode.srcIn), height: 18, width: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ---------------- Switches ----------------
            buildCustomSwitch(title: "Highlight when odds change", value: oddsAnyOdds, onTap: () => setState(() => oddsAnyOdds = !oddsAnyOdds)),
            buildCustomSwitch(title: "Accept Any Odds (FancyBet)", value: fancyBetAnyOdds, onTap: () => setState(() => fancyBetAnyOdds = !fancyBetAnyOdds)),
            buildCustomSwitch(title: "Accept Any Odds (SportsBook)", value: sportsBookAnyOdds, onTap: () => setState(() => sportsBookAnyOdds = !sportsBookAnyOdds)),
            buildCustomSwitch(
                title: "With Commission (Forecast)",
                value: enableForecastWithCommission,
                onTap: () => setState(() => enableForecastWithCommission = !enableForecastWithCommission)),

            hb20,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: isEditable ? null : () => removeScreen(context),
                  child: Container(
                    width: 200,
                    height: 50,
                    decoration: BoxDecoration(
                      color: white,
                      border: Border.all(color: grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: black, fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                wb10,
                InkWell(
                  onTap: isEditable ? null : saveSettings,
                  child: Container(
                    width: 200,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: blackGrdntButton,
                      border: Border.all(color: grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Text(
                        "Save",
                        style: TextStyle(color: appBarText, fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget buildCustomSwitch({required String title, required bool value, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(color: secondaryTextClr, fontSize: 16, fontWeight: FontWeight.w500),
          ),
          InkWell(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 45,
              height: 45,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: value ? const Color(0xff6bbd11) : const Color(0xffa2b1ba)),
              child: Align(
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 15,
                      height: 47,
                      decoration: const BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 1))],
                      ),
                    ),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: whiteOpac1,
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 1))],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
