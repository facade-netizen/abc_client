import 'package:chopper/chopper.dart';

import '../../../models/fav_stake_model.dart';
import '../../../models/favourite_model.dart';
import '../../../models/mm_add_markets_model.dart';
import '../../../models/mm_fancy_model.dart';
import '../../../models/oneclick_bet_model.dart';
import '../../apiHandlers/api_constants.dart';
import '../../apiHandlers/api_interceptors.dart';
import '../../apiHandlers/json_to_type_converter.dart';

part 'favourite_api_services.chopper.dart';

final _favouriteApiClient = ChopperClient(
  baseUrl: Uri.parse(FavoriteApiConstants.baseUrl),
  converter: JsonSerializableConverter({
    AddedMMResponse: (json) => AddedMMResponse.fromJson(json),
    FavouriteStakeResponse: (json) => FavouriteStakeResponse.fromJson(json),
    FavouriteModelResponse: (json) => FavouriteModelResponse.fromJson(json),
    MMFancyMarketResponse: (json) => MMFancyMarketResponse.fromJson(json),
    OneClickBetResponse: (json) => OneClickBetResponse.fromJson(json),
  }),
  interceptors: [ApiAuthInterceptor(), ApiResponseInterceptor(), ApiRequestInterceptor()],
  errorConverter: const JsonConverter(),
);

@ChopperApi(baseUrl: FavoriteApiConstants.baseUrl)
abstract class FavouriteApiServices extends ChopperService {
  ///Don't modify
  static FavouriteApiServices create() {
    return _$FavouriteApiServices(_favouriteApiClient);
  }

  @POST(path: FavoriteApiConstants.favorite)
  Future<Response> addFavouriteEvents({@Body() required Map<String, dynamic> body});

  @GET(path: FavoriteApiConstants.favorite)
  Future<Response<FavouriteModelResponse>> fetchFavEvent();

  @GET(path: FavoriteApiConstants.mmFancy)
  Future<Response<MMFancyMarketResponse>> fetchMMFancy();

  @DELETE(path: FavoriteApiConstants.favorite)
  Future<Response> removeFavouriteEvents({@Body() required Map<String, dynamic> body});

  @GET(path: FavoriteApiConstants.favStake)
  Future<Response<FavouriteStakeResponse>> getFavStake();

  @POST(path: FavoriteApiConstants.favStake)
  Future<Response> addFavStake({@Body() required Map<String, dynamic> body});

  @PUT(path: FavoriteApiConstants.favStake)
  Future<Response> updateFavStake({@Body() required Map<String, dynamic> body});

  @GET(path: FavoriteApiConstants.detail)
  Future<Response<AddedMMResponse>> fetchAddedFavEvent();

  @GET(path: FavoriteApiConstants.oneClick)
  Future<Response<OneClickBetResponse>> getOneClickData();
  
  @PUT(path: FavoriteApiConstants.allStakes)
  Future<Response> updateOnclickBetAllStakes({@Body() required Map<String, dynamic> body});
}
