import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/fetchBlocs/fetch_current_user_info_bloc.dart';
import '../../../../models/user_details_model.dart';
import '../../../../reusables/colors.dart';
import '../../../../reusables/loader.dart';
import '../../../../reusables/sized_box_hw.dart';
import '../../../mobileScreens/mvAccounts/mvProfile/change_password_dialog.dart';
import '../../sportsReusables/table_cell_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchUserAccountDetailsBloc, FetchUserAccountDetailsState>(
      builder: (context, fud) {
        UserAccountDetails? userDetails;
        if (fud is FetchUserAccountDetailsSuccess) {
          userDetails = fud.userDetails;
        }
        return fud is FetchUserAccountDetailsProgress
            ? LoaderContainerWithMessage()
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TableHeader(title: "Account Details"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ProfileHeader(title: "About You", isHeader: true),
                            ProfileHeader(title: "Account Id", value: userDetails?.userName ?? "--"),
                            ProfileHeader(title: "First Name", value: userDetails?.firstName ?? "--"),
                            ProfileHeader(title: "Last Name", value: userDetails?.lastName ?? "--"),
                            ProfileHeader(title: "Birthday", value: "--"),
                            ProfileHeader(
                              title: "Password",
                              value: "**************************",
                              isEdit: true,
                              onTap: () {
                                showPasswordChangeDialog(context);
                              },
                            ),
                            hb20,
                            ProfileHeader(title: "Address", isHeader: true),
                            ProfileHeader(title: "Address", value: "--"),
                            ProfileHeader(title: "Town/City", value: "--"),
                            ProfileHeader(title: "Country", value: "--"),
                            ProfileHeader(title: "Country/State", value: "--"),
                            ProfileHeader(title: "Postcode", value: "--"),
                            ProfileHeader(
                              title: "Timezone",
                              value: formatTimezone(userDetails?.users.first.timezone),
                            ),
                          ],
                        ),
                      ),
                      wb20,
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ProfileHeader(title: "Setting", isHeader: true),
                            ProfileHeader(title: "Currency", value: "--"),
                            ProfileHeader(title: "Odds Format", value: ""),
                            hb20,
                            ProfileHeader(title: "Commission", isHeader: true),
                            ProfileHeader(title: "Commission Charged", value: "${userDetails?.commissionRate.toStringAsFixed(2)} %"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
      },
    );
  }
}

String formatTimezone(String? tz) {
  if (tz == null || tz.isEmpty) return "--";
  return tz.split('(').first.trim();
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.title,
    this.value,
    this.isHeader = false,
    this.onTap,
    this.isEdit = false,
  });
  final String title;
  final String? value;
  final bool isHeader;
  final void Function()? onTap;
  final bool? isEdit;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Container(
      height: 30,
      width: size.width,
      decoration: BoxDecoration(
        color: isHeader ? darkGreen : white,
        border: Border(bottom: BorderSide(color: darkGreen, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 150,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(title, style: TextStyle(color: isHeader ? white : black, fontWeight: isHeader ? FontWeight.bold : FontWeight.normal)),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (value != null) Text(value == null || value!.isEmpty ? "--" : value!, style: TextStyle(color: black, overflow: TextOverflow.ellipsis)),
              if (isEdit == true)
                InkWell(
                  onTap: onTap,
                  child: Row(
                    children: [
                      Text("Edit", style: TextStyle(color: blue, fontSize: 12)),
                      const Icon(Icons.edit, size: 16, color: Colors.blue),
                    ],
                  ),
                ),
            ],
          )
        ],
      ),
    );
  }
}
