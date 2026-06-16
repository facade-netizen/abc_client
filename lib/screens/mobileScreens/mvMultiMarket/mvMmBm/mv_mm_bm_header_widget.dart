import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../constants/app_asset_constants.dart';
import '../../../../reusables/colors.dart';
import '../../../../reusables/sized_box_hw.dart';

class MvMMHeaderBM extends StatelessWidget {
  const MvMMHeaderBM({
    super.key,
    required this.eventName,
    this.removeMarket,
    this.gotoMarket,
    this.refreshMarket,
    this.svgIcon,
  
  });
  final String eventName;
  final void Function()? removeMarket;
  final void Function()? gotoMarket;
  final void Function()? refreshMarket;
  final String? svgIcon;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: darkGreen,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(onTap: removeMarket, child: SvgPicture.asset(AppAssetConstants.removemarket)),
              wb5,
              Expanded(
                child: Row(
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: green,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(3),
                              bottomLeft: Radius.circular(3),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                          child: SvgPicture.asset(
                            AppAssetConstants.clockWhite,
                            height: 14,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: blue,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(3),
                              bottomRight: Radius.circular(3),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                          child: SvgPicture.asset(
                          svgIcon??  AppAssetConstants.b,
                            colorFilter: ColorFilter.mode(white, BlendMode.srcIn),
                            height: 14,
                          ),
                        ),
                      ],
                    ),
                    wb2,
                    Expanded(
                      child: Text(
                        eventName,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF3b5160),
                  border: Border.all(color: Color(0xFF3b5160)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: InkWell(onTap: gotoMarket, child: SvgPicture.asset(AppAssetConstants.arrowleft)),
              ),
              wb5,
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFF3b5160)),
                ),
                child: InkWell(
                  onTap: refreshMarket,
                  child: SvgPicture.asset(AppAssetConstants.refersh),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
