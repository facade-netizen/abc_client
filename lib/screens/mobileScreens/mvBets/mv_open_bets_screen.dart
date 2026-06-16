import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/fetchBlocs/fetch_open_orders_bloc.dart';
import '../../../constants/app_asset_constants.dart';
import '../../../models/open_order_model.dart';
import '../../../reusables/colors.dart';
import '../../../reusables/custom_headers.dart';
import '../../../reusables/loader.dart';
import '../../../services/navigators.dart';
import 'mv_open_bet_details_screen.dart';

class MvOpenBetsScreen extends StatefulWidget {
  const MvOpenBetsScreen({super.key});

  @override
  State<MvOpenBetsScreen> createState() => _MvOpenBetsScreenState();
}

class _MvOpenBetsScreenState extends State<MvOpenBetsScreen> {
  bool showBetDetailsScreen = false;
  List<OpenOrder>? openOrdersData;
  String openInEvent = '';

  @override
  void initState() {
    context.read<FetchOpenOrdersBloc>().add(FetchOpenOrders());
    super.initState();
  }

  void toggleBetDetailsScreen(List<OpenOrder> openOrders) {
    if (showBetDetailsScreen) {
      setState(() {
        showBetDetailsScreen = false;
        openOrders = [];
      });
    } else {
      setState(() {
        showBetDetailsScreen = true;
        openOrdersData = openOrders;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchOpenOrdersBloc, FetchOpenOrdersState>(
      builder: (context, fos) {
        return Scaffold(
          backgroundColor: white,
          body: SafeArea(
            child: Column(
              children: [
                CustomHeadersWithSvgAndTitle(
                  svgIcon: AppAssetConstants.dollar,
                  headerTitle: 'Open Bets',
                  onTap: () {
                    removeScreen(context);
                  },
                ),
                showBetDetailsScreen
                    ? MVOpenBetDetailScreen(toggleScreen: toggleBetDetailsScreen, openOrders: openOrdersData!, openInEvent: openInEvent)
                    : Expanded(
                        child: fos is FetchOpenOrdersProgress
                            ? LoaderContainerWithMessage()
                            : fos is FetchOpenOrdersSuccess
                            ? ListView.builder(
                                shrinkWrap: true,
                                itemCount: fos.openOrderData.length,
                                itemBuilder: (context, index) {
                                  final openOrderDetails = fos.openOrderData[index];
                                  return Container(
                                    decoration: BoxDecoration(
                                      border: Border(bottom: BorderSide(color: grey, width: 0.5)),
                                    ),
                                    child: ListTile(
                                      leading: const Icon(Icons.radio_button_off, color: Colors.grey),
                                      title: Text(
                                        openOrderDetails.name,
                                        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
                                      ),
                                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
                                      onTap: () {
                                        setState(() {
                                          openInEvent = openOrderDetails.name;
                                        });
                                        toggleBetDetailsScreen(openOrderDetails.openOrders);
                                      },
                                    ),
                                  );
                                },
                              )
                            : SizedBox.shrink(),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}
