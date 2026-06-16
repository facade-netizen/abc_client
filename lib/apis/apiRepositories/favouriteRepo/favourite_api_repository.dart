import 'package:chopper/chopper.dart';

import '../../../models/fav_stake_model.dart';
import '../../../models/favourite_model.dart';
import '../../../models/mm_add_markets_model.dart';
import '../../../models/mm_fancy_model.dart';
import '../../../models/oneclick_bet_model.dart';
import 'favourite_api_services.dart';

class FavouriteApiRepository {
  FavouriteApiRepository() : _favouriteApiServices = FavouriteApiServices.create();
  final FavouriteApiServices _favouriteApiServices;

  Future<Response> addFavouriteEvents({required Map<String, dynamic> body}) async {
    return await _favouriteApiServices.addFavouriteEvents(body: body);
  }

  Future<Response> removeFavouriteEvents({required Map<String, dynamic> body}) async {
    return await _favouriteApiServices.removeFavouriteEvents(body: body);
  }

  Future<Response<FavouriteModelResponse>> fetchFavEvent() async {
    try {
      return _favouriteApiServices.fetchFavEvent();
    } catch (e) {
      rethrow;
    }
  }

  Future<Response<MMFancyMarketResponse>> fetchMMFancy() async {
    try {
      return _favouriteApiServices.fetchMMFancy();
    } catch (e) {
      rethrow;
    }
  }

  Future<Response<FavouriteStakeResponse>> getFavStake() async {
    try {
      return _favouriteApiServices.getFavStake();
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> addFavStake({required Map<String, dynamic> body}) async {
    return await _favouriteApiServices.addFavStake(body: body);
  }

  Future<Response> updateFavStake({required Map<String, dynamic> body}) async {
    return await _favouriteApiServices.updateFavStake(body: body);
  }

  Future<Response<AddedMMResponse>> fetchAddedFavEvent() async {
    try {
      return _favouriteApiServices.fetchAddedFavEvent();
    } catch (e) {
      rethrow;
    }
  }

  Future<Response<OneClickBetResponse>> getOneClickData() async {
    try {
      return _favouriteApiServices.getOneClickData();
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> updateOnclickBetAllStakes({required Map<String, dynamic> body}) async {
    return await _favouriteApiServices.updateOnclickBetAllStakes(body: body);
  }
}
