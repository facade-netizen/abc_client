import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../../apis/apiHandlers/api_constants.dart';
import '../../models/news_announcement_model.dart';

class FetchNewsAnnouncementsBloc extends Bloc<FetchNewsAnnouncementsEvent, FetchNewsAnnouncementsState> {
  FetchNewsAnnouncementsBloc() : super(FetchNewsAnnouncementsInitial()) {
    on<FetchNewsAnnouncements>((event, emit) async {
      emit(FetchNewsAnnouncementsProgress());
      try {
        var request = http.Request('GET', Uri.parse(AppNewsStringConstants.newsApiEndpoint));
        http.StreamedResponse response = await request.send();
        if (response.statusCode == 200) {
          String jsonResponse = await response.stream.bytesToString();
          // if (kDebugMode) log(jsonResponse);
          final decoded = jsonDecode(jsonResponse);
          List<NewsAnnouncement> newsList = (decoded as List).map((item) => NewsAnnouncement.fromJson(item)).toList();
          emit(FetchNewsAnnouncementsSuccess(announcements: newsList));
        } else {
          if (kDebugMode) debugPrint('fetch_news_bloc.dart [Response Exception] >>\n ${response.statusCode}');
          emit(FetchNewsAnnouncementsFailure(response.statusCode.toString()));
        }
      } catch (e) {
        if (kDebugMode) debugPrint('FetchNewsAnnouncementsBloc Error: $e');
        emit(FetchNewsAnnouncementsFailure(e));
      }
    });
  }
}

// Events
abstract class FetchNewsAnnouncementsEvent {}

class FetchNewsAnnouncements extends FetchNewsAnnouncementsEvent {}

// States
abstract class FetchNewsAnnouncementsState {}

class FetchNewsAnnouncementsInitial extends FetchNewsAnnouncementsState {}

class FetchNewsAnnouncementsProgress extends FetchNewsAnnouncementsState {}

class FetchNewsAnnouncementsSuccess extends FetchNewsAnnouncementsState {
  final List<NewsAnnouncement> announcements;
  FetchNewsAnnouncementsSuccess({required this.announcements});
}

class FetchNewsAnnouncementsFailure extends FetchNewsAnnouncementsState {
  final dynamic error;
  FetchNewsAnnouncementsFailure(this.error);
}
