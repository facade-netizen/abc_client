import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/fetchBlocs/fetch_fancy_book_bloc.dart';
import '../../../../reusables/colors.dart';
import '../../../../reusables/custom_alert_dialog.dart';
import '../../../../reusables/loader.dart';
import '../../../../reusables/sized_box_hw.dart';

Future<dynamic> showFancyBookView(
  BuildContext context,
  String runnerName,
) {
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext ctxt) {
      return ShowFancyBookView(
        runnerName: runnerName,
      );
    },
  );
}

class ShowFancyBookView extends StatelessWidget {
  const ShowFancyBookView({super.key, required this.runnerName});
  final String runnerName;
  @override
  Widget build(BuildContext context) {
    double tfw = 700;
    Size size = MediaQuery.sizeOf(context);
    return CustomAlertDialog(
      title: 'Book Position',
      contentPadding: EdgeInsets.zero,
      content: SizedBox(
        height: size.height,
        width: tfw,
        child: Column(
          children: [
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
                              SizedBox(
                                height: size.height - 200,
                                child: ListView.builder(
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
                              ),
                            ],
                          )
                        : SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
