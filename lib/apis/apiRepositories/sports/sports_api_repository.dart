import 'package:chopper/chopper.dart';

import '../../../models/event_with_type_model.dart';
import '../../../models/result_model.dart';
import '../../../models/sport_category_model.dart';
import 'sports_api_services.dart';

class SportApiRepository {
  SportApiRepository() : _sportsApiServices = SportsApiServices.create();
  final SportsApiServices _sportsApiServices;

  //Events Type
  Future<Response<EventTypeResponse>> getSportsCategory() async {
    try {
      return _sportsApiServices.getSportsCategory();
    } catch (e) {
      rethrow;
    }
  }

  ///Result Match
  Future<Response<ResultResponse>> getResultMatch() async {
    try {
      return _sportsApiServices.getResultMatch();
    } catch (e) {
      rethrow;
    }
  }

  ///Result Line Match
  Future<ResultLineResponse> getResultLineMatch({required bool isYesterDay}) async {
    try {
      return _sportsApiServices.getResultLineMatch(isYesterDay: isYesterDay);
    } catch (e) {
      rethrow;
    }
  }

  //Events Type
  Future<Response<SportsResponse>> getEventWithType({int? evenTypeID, bool? tomorrow, bool? inPlay}) async {
    try {
      return _sportsApiServices.getEventWithType(evenTypeID: evenTypeID ?? 0, tomorrow: tomorrow ?? false, inPlay: inPlay ?? false);
    } catch (e) {
      rethrow;
    }
  }
}
