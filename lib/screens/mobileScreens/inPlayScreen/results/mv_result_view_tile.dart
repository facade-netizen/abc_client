import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/fetchBlocs/fetch_match_result_bloc.dart';
import '../../../../models/result_model.dart';
import '../../../../reusables/colors.dart';
import '../../../../reusables/highlighted_text_widget.dart';
import '../../../../reusables/loader.dart';

class MobileSportsResultView extends StatefulWidget {
  const MobileSportsResultView({super.key, required this.resultTab, required this.selectedSport});

  final String resultTab;
  final String selectedSport;

  @override
  State<MobileSportsResultView> createState() => _MobileSportsResultViewState();
}

class _MobileSportsResultViewState extends State<MobileSportsResultView> {
  
  @override
  void initState() {
    super.initState();
    context.read<FetchMatchResultBloc>().add(FetchMatchResult());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchMatchResultBloc, FetchMatchResultState>(
      builder: (context, state) {
        if (state is FetchMatchResultProgress) {
          return LoaderContainerWithMessage(message: 'Loading results...');
        }
        if (state is FetchMatchResultSuccess) {
          return _MobileResultTable(
            resultResponse: state.resultResponse,
            selectedSport: widget.selectedSport,
            resultTab: widget.resultTab,
          );
        }
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('No data available.', style: TextStyle(color: black)),
          ),
        );
      },
    );
  }
}

class _MobileResultTable extends StatelessWidget {
  const _MobileResultTable({
    required this.resultResponse,
    required this.selectedSport,
    required this.resultTab,
  });

  final ResultResponse resultResponse;
  final String selectedSport;
  final String resultTab;

  @override
  Widget build(BuildContext context) {
    final dayData = resultTab == 'Yesterday' ? resultResponse.data.yesterday : resultResponse.data.today;

    List<dynamic> matches = [];
    if (selectedSport == 'CRICKET') {
      matches = dayData.cricket;
    } else if (selectedSport == 'SOCCER') {
      matches = dayData.soccer;
    } else if (selectedSport == 'E-SOCCER') {
      matches = dayData.eSoccer;
    }

    if (matches.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('There are no events to be displayed.', style: TextStyle(color: black)),
        ),
      );
    }

    final isCricket = selectedSport == 'CRICKET';
    final col1Label = isCricket ? 'Home' : 'HT';
    final col2Label = isCricket ? 'Away' : 'FT';

    return ListView.builder(
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        String eventDate = '';
        String eventName = '';
        String value1 = '';
        String value2 = '';

        if (isCricket) {
          final m = match as CricketMatch;
          eventDate = m.eventDate;
          eventName = m.eventName;
          value1 = m.home;
          value2 = m.away;
        } else {
          final m = match as OtherMatch;
          eventDate = m.eventDate;
          eventName = m.eventName;
          value1 = m.ht;
          value2 = m.ft;
        }

        return Padding(
          padding: EdgeInsets.only(bottom: index == matches.length - 1 ? 40 : 0),
          child: _MobileResultRow(
            eventDate: eventDate,
            eventName: eventName,
            value1: value1,
            value2: value2,
            col1Label: col1Label,
            col2Label: col2Label,
          ),
        );
      },
    );
  }
}

class _MobileResultRow extends StatelessWidget {
  const _MobileResultRow({
    required this.eventDate,
    required this.eventName,
    required this.value1,
    required this.value2,
    required this.col1Label,
    required this.col2Label,
  });

  final String eventDate;
  final String eventName;
  final String value1;
  final String value2;
  final String col1Label;
  final String col2Label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: white,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left: date + match name
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HighlightText(
                      eventDate,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    HighlightText(
                      eventName,
                      style: const TextStyle(
                        fontSize: 13,
                        color: black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Right: two score columns
            _ScoreColumn(label: col1Label, value: value1),
            _ScoreColumn(label: col2Label, value: value2),
          ],
        ),
      ),
    );
  }
}

class _ScoreColumn extends StatelessWidget {
  const _ScoreColumn({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: white,
          border: Border(left: BorderSide(color: Colors.grey[300]!)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HighlightText(
                label,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              HighlightText(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  color: black,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
