import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/fetchBlocs/fetch_fancy_book_bloc.dart';
import '../../../../reusables/colors.dart';
import '../../../../reusables/loader.dart';
import '../../../../reusables/sized_box_hw.dart';
import '../../../../services/navigators.dart';

void showFancyBookBottomSheet(BuildContext context, String runnerName) {
  showModalBottomSheet(
    context: context,
    backgroundColor: white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
    ),
    builder: (BuildContext context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(gradient: bottomBarGradient),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Book Position',
                  style: TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                InkWell(
                  onTap: () => removeScreen(context),
                  child: Container(
                    width: 40,
                    decoration: BoxDecoration(
                      border: Border(left: BorderSide(color: appYellow, width: 0.5)),
                    ),
                    child: Center(child: Icon(Icons.close, color: appYellow)),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(gradient: blackGrdntButton),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            alignment: Alignment.centerLeft,
            child: Text(
              runnerName,
              style: TextStyle(color: Colors.white),
            ),
          ),
          BlocBuilder<FetchFancyBookBloc, FetchFancyBookState>(
            builder: (context, fbs) {
              return fbs is FetchFancyBookProgress
                  ? LoaderContainerWithMessage()
                  : fbs is FetchFancyBookSuccess
                      ? Column(
                          children: [
                            Container(
                              color: backFooterBg,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: const Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Runs',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: black,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Amount',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            hb20,
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: fbs.fancyBook.length,
                              itemBuilder: (context, index) {
                                final bookData = fbs.fancyBook[index];
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(color: bookData.amount > 0 ? backFooterBg : layFooterBg, border: Border.all(color: white)),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "${bookData.runs}",
                                          style: TextStyle(color: black, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          bookData.amount > 0 ? "${bookData.amount}" : '(${bookData.amount.toString().replaceAll('-', '')})',
                                          style: TextStyle(
                                            color: bookData.amount > 0 ? black : red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        )
                      : SizedBox.shrink();
            },
          ),
        ],
      );
    },
  );
}
