import 'package:chopper/chopper.dart';

import '../../../models/casion_history_model.dart';
import '../../../models/cg_balance_model.dart';
import '../../../models/sportsbook_model.dart';
import '../../apiHandlers/api_constants.dart';
import '../../apiHandlers/api_interceptors.dart';
import '../../apiHandlers/json_to_type_converter.dart';

part 'cg_api_services.chopper.dart';

final _cgApiClient = ChopperClient(
  baseUrl: Uri.parse(CGApiConstants.baseUrl),
  converter: JsonSerializableConverter({
    CGBalanceResponse: (json) => CGBalanceResponse.fromJson(json),
    SportsBookResponse: (json) => SportsBookResponse.fromJson(json),
    CasinoHistoryResponse: (json) => CasinoHistoryResponse.fromJson(json),
  }),
  interceptors: [ApiAuthInterceptor(), ApiResponseInterceptor(), ApiRequestInterceptor()],
  errorConverter: const JsonConverter(),
);

@ChopperApi(baseUrl: CGApiConstants.baseUrl)
abstract class CGApiServices extends ChopperService {
  ///Don't modify
  static CGApiServices create() {
    return _$CGApiServices(_cgApiClient);
  }

  @GET(path: CGApiConstants.fetchBalance)
  Future<Response<CGBalanceResponse>> getCGBalance(@Query("provider") String provider);

  @POST(path: CGApiConstants.addMoney)
  Future<Response> addCGMoney({@Body() required Map<String, dynamic> body});

  @POST(path: CGApiConstants.withDrawMoney)
  Future<Response> withCGDrawMoney({@Body() required Map<String, dynamic> body});

  @GET(path: CGApiConstants.history)
  Future<Response<CasinoHistoryResponse>> getCGHistory(@Query("From") String fromDate, @Query("To") String toDate, @Query("Limit") int limit, @Query("Page") int page);
  @POST(path: CGApiConstants.cricket)
  Future<Response> fetchPremium({@Body() required Map<String, dynamic> body});

  @GET(path: CGApiConstants.sportHistory)
  Future<Response<SportsBookResponse>> getSportsBookHistory(
    @Query("status") String status,
    @Query("From") String fromDate,
    @Query("To") String toDate,
    @Query("Limit") int limit,
    @Query("Page") int page,
  );
}
