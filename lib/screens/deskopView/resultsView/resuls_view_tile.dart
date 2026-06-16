import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/fetchBlocs/fetch_match_result_bloc.dart';
import '../../../models/result_model.dart';
import '../../../reusables/colors.dart';
import '../../../reusables/highlighted_text_widget.dart';
import '../../../reusables/loader.dart';
import '../../../reusables/sized_box_hw.dart';
import '../sportsReusables/sports_header.dart';

class ResultViewTile extends StatelessWidget {
  const ResultViewTile({
    super.key,
    required this.resultTab,
    required this.selectedSport,
  });

  final String resultTab;
  final String selectedSport;

  @override
  Widget build(BuildContext context) {
    final isCricket = selectedSport == 'CRICKET';
    final isSoccer = selectedSport == 'SOCCER' || selectedSport == 'E-SOCCER';

    return SingleChildScrollView(
      child: Column(
        children: [
          const SportsHeader(title: 'Result', color: darkGreen),
          RRData(
            eventDate: 'Event Date/Time',
            eventName: 'Event Name',
            value1: isCricket ? 'Home' : (isSoccer ? 'HT' : 'Home'),
            value2: isCricket ? 'Away' : (isSoccer ? 'FT' : 'Away'),
            isHeader: true,
          ),
          BlocBuilder<FetchMatchResultBloc, FetchMatchResultState>(
            builder: (context, state) {
              if (state is FetchMatchResultProgress) {
                return LoaderContainerWithMessage(message: 'Loading results...');
              }
              if (state is FetchMatchResultSuccess) {
                return _ResultTable(
                  resultResponse: state.resultResponse,
                  selectedSport: selectedSport,
                  resultTab: resultTab,
                );
              }

              return NoRData();
            },
          ),
          hb10,
        ],
      ),
    );
  }
}

class _ResultTable extends StatelessWidget {
  const _ResultTable({
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

    // Get the appropriate data based on selected sport
    List<dynamic> matches = [];

    if (selectedSport == 'CRICKET') {
      matches = dayData.cricket;
    } else if (selectedSport == 'SOCCER') {
      matches = dayData.soccer;
    } else if (selectedSport == 'E-SOCCER') {
      matches = dayData.eSoccer;
    }

    if (matches.isEmpty) {
      return NoRData();
    }

    return Column(
      children: matches.map((match) {
        String eventDate = '';
        String eventName = '';
        String value1 = '';
        String value2 = '';

        if (selectedSport == 'CRICKET') {
          final cricketMatch = match as CricketMatch;
          eventDate = cricketMatch.eventDate;
          eventName = cricketMatch.eventName;
          value1 = cricketMatch.home;
          value2 = cricketMatch.away;
        } else if (selectedSport == 'SOCCER') {
          final soccerMatch = match as OtherMatch;
          eventDate = soccerMatch.eventDate;
          eventName = soccerMatch.eventName;
          value1 = soccerMatch.ht;
          value2 = soccerMatch.ft;
        } else if (selectedSport == 'E-SOCCER') {
          final eSoccerMatch = match as OtherMatch;
          eventDate = eSoccerMatch.eventDate;
          eventName = eSoccerMatch.eventName;
          value1 = eSoccerMatch.ht;
          value2 = eSoccerMatch.ft;
        }

        return RRData(
          eventDate: eventDate,
          eventName: eventName,
          value1: value1,
          value2: value2,
          isHeader: false,
        );
      }).toList(),
    );
  }
}

class RRData extends StatelessWidget {
  const RRData({
    super.key,
    required this.eventDate,
    required this.eventName,
    required this.value1,
    required this.value2,
    this.isHeader = true,
  });

  final String eventDate;
  final String eventName;
  final String value1;
  final String value2;
  final bool isHeader;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      decoration: BoxDecoration(
        color: isHeader ? const Color(0xFFe4e4e4) : white,
        border: Border(bottom: BorderSide(color: darkGreen, width: 0.5)),
      ),
      child: Row(
        children: [
          SizedBox(width: 12),
          Expanded(
            child: HighlightText(
              eventDate,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: black,
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: HighlightText(
              eventName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: black,
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: HighlightText(
              value1,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: black,
                fontWeight: isHeader ? FontWeight.bold : FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: HighlightText(
              value2,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: black,
                fontWeight: isHeader ? FontWeight.bold : FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          SizedBox(width: 12),
        ],
      ),
    );
  }
}

class NoRData extends StatelessWidget {
  const NoRData({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: white,
        border: Border(bottom: BorderSide(color: darkGreen, width: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        'There are no events to be displayed.',
        style: TextStyle(color: black),
      ),
    );
  }
}
