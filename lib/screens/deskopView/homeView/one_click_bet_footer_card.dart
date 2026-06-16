import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/addBloc/update_onclick_bet_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_one_click_data_bloc.dart';
import '../../../reusables/colors.dart';
import '../../../reusables/sized_box_hw.dart';

class OneClickBetFooterCard extends StatefulWidget {
  const OneClickBetFooterCard({super.key});

  @override
  State<OneClickBetFooterCard> createState() => _OneClickBetFooterCardState();
}

class _OneClickBetFooterCardState extends State<OneClickBetFooterCard> {
  bool isEditable = false;
  bool initializedStakes = false;
  int selectedDefaultIndex = 0;
  final List<TextEditingController> stakeControllers = List.generate(4, (_) => TextEditingController());
  late final List<FocusNode> stakeFocusNodes;

  @override
  void initState() {
    super.initState();
    stakeFocusNodes = List.generate(
      stakeControllers.length,
      (index) => FocusNode()
        ..addListener(() {
          if (stakeFocusNodes[index].hasFocus) {
            setState(() {
              selectedDefaultIndex = index;
            });
          }
        }),
    );

    final defaults = ['100', '200', '300', '400'];
    for (int i = 0; i < stakeControllers.length; i++) {
      stakeControllers[i].text = defaults[i];
    }
  }

  @override
  void dispose() {
    for (final controller in stakeControllers) {
      controller.dispose();
    }
    for (final focusNode in stakeFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UpdateOnclickBetBloc, UpdateOnclickBetState>(
      builder: (context, state) {
        if (state is UpdateOnclickBetSuccess) {}
        return BlocBuilder<FetchOneClickDataBloc, FetchOneClickDataState>(
          builder: (context, state) {
            if (state is! FetchOneClickDataSuccess || !state.oneClickData.isClicked) {
              return const SizedBox.shrink();
            }

            if (!initializedStakes) {
              stakeControllers[0].text = state.oneClickData.stakeOne.toStringAsFixed(state.oneClickData.stakeOne.truncateToDouble() == state.oneClickData.stakeOne ? 0 : 2);
              stakeControllers[1].text = state.oneClickData.stakeTwo.toStringAsFixed(state.oneClickData.stakeTwo.truncateToDouble() == state.oneClickData.stakeTwo ? 0 : 2);
              stakeControllers[2].text = state.oneClickData.stakeThree.toStringAsFixed(state.oneClickData.stakeThree.truncateToDouble() == state.oneClickData.stakeThree ? 0 : 2);
              stakeControllers[3].text = state.oneClickData.stakeFour.toStringAsFixed(state.oneClickData.stakeFour.truncateToDouble() == state.oneClickData.stakeFour ? 0 : 2);
              selectedDefaultIndex = state.oneClickData.defaultStake == state.oneClickData.stakeOne
                  ? 0
                  : state.oneClickData.defaultStake == state.oneClickData.stakeTwo
                  ? 1
                  : state.oneClickData.defaultStake == state.oneClickData.stakeThree
                  ? 2
                  : state.oneClickData.defaultStake == state.oneClickData.stakeFour
                  ? 3
                  : 0;
              initializedStakes = true;
            }

            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: successGradient,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                child: Row(
                  children: [
                    Text(
                      'One Click Bet Stake',
                      style: TextStyle(color: white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(stakeControllers.length, (index) {
                        final controller = stakeControllers[index];
                        final isSelected = selectedDefaultIndex == index;
                        if (isEditable) {
                          return SizedBox(
                            width: 80,
                            height: 25,
                            child: TextField(
                              focusNode: stakeFocusNodes[index],
                              controller: controller,
                              keyboardType: TextInputType.number,
                              style: TextStyle(fontSize: 12, color: black),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                filled: true,
                                fillColor: isSelected ? videoGreenIconColor : white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: BorderSide(color: black, width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: BorderSide(color: black, width: 1),
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  selectedDefaultIndex = index;
                                });
                              },
                              onChanged: (value) {
                                setState(() {});
                              },
                            ),
                          );
                        }
                        return GestureDetector(
                          onTap: () {
                            final selectedValue = controller.text;
                            setState(() {
                              selectedDefaultIndex = index;
                            });
                            context.read<UpdateOnclickBetBloc>().add(UpdateOnclickBet(type: 3, defaultStake: selectedValue));
                          },
                          child: Container(
                            height: 25,
                            width: 80,
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: isSelected ? bottomBarGradient : whiteGradient,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: black, width: 1),
                            ),
                            child: Center(
                              child: Text(
                                controller.text,
                                style: TextStyle(color: isSelected ? appYellow : black, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        if (isEditable) {
                          final body = {
                            "StakeOne": double.tryParse(stakeControllers[0].text) ?? 0,
                            "StakeTwo": double.tryParse(stakeControllers[1].text) ?? 0,
                            "StakeThree": double.tryParse(stakeControllers[2].text) ?? 0,
                            "StakeFour": double.tryParse(stakeControllers[3].text) ?? 0,
                            "DefaultStake": double.tryParse(stakeControllers[selectedDefaultIndex].text) ?? 0,
                            "IsClicked": true,
                          };
                          context.read<UpdateOnclickBetBloc>().add(UpdateOnclickBet(body: body, type: 2));
                        }
                        setState(() {
                          isEditable = !isEditable;
                          if (!isEditable && selectedDefaultIndex > 3) {
                            selectedDefaultIndex = 3;
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: successGradient,
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(color: white, width: 0.5),
                        ),
                        child: Row(
                          children: [
                            Text(isEditable ? 'OK' : 'Edit', style: TextStyle(color: black)),
                            wb2,
                            Icon(isEditable ? Icons.check : Icons.edit, size: 14, color: black),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
