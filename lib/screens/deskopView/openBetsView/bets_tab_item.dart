import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/authBlocs/user_auth_change_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_open_orders_bloc.dart';
import '../../../reusables/colors.dart';
import 'open_bets_screen.dart';

enum RightPanelTab { betSlip, openBets }

RightPanelTab activeTab = RightPanelTab.betSlip;

class BetsSlipTab extends StatefulWidget {
  const BetsSlipTab({super.key, this.child});
  final Widget? child;

  @override
  State<BetsSlipTab> createState() => _BetsSlipTabState();
}

class _BetsSlipTabState extends State<BetsSlipTab> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserAuthChangesBloc, UserAuthChangesState>(
      builder: (context, ucs) {
        final isLoggedIn = ucs is UserAuthChangesSuccess && ucs.savedUserAuth != null;

        return Column(
          children: [
            Container(
              height: 30,
              color: blueDark,
              child: Row(
                children: [
                  // Bet Slip tab (always visible)
                  Expanded(
                    child: BetsTabItem(
                      title: "Bet Slip",
                      isActive: activeTab == RightPanelTab.betSlip && isLoggedIn,
                      onTap: () => setState(() => activeTab = RightPanelTab.betSlip),
                    ),
                  ),

                  // Open Bets tab (only if logged in)
                  if (isLoggedIn) ...[
                    Expanded(
                      child: BetsTabItem(
                        title: "Open Bets",
                        isActive: activeTab == RightPanelTab.openBets,
                        onTap: () {
                          context.read<FetchOpenOrdersBloc>().add(FetchOpenOrders());
                          setState(() => activeTab = RightPanelTab.openBets);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: white),
                        ),
                        child: InkWell(
                          onTap: () {
                            if (isLoggedIn) {
                              context.read<FetchOpenOrdersBloc>().add(FetchOpenOrders());
                            }
                          },
                          child: const Icon(Icons.refresh, color: white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            /// TAB BODY
            Expanded(
              child: activeTab == RightPanelTab.betSlip
                  ? SizedBox(child: widget.child)
                  : isLoggedIn
                      ? const OpenBetsCard()
                      : SizedBox(),
            ),
          ],
        );
      },
    );
  }
}

class BetsTabItem extends StatelessWidget {
  const BetsTabItem({
    super.key,
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  final String title;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: isActive ? highlightHeader : none, width: 2),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: white,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
