import 'package:chopper/chopper.dart';

import '../../../models/event_with_type_model.dart';
import '../../../models/result_model.dart';
import '../../../models/sport_category_model.dart';
import '../../apiHandlers/api_constants.dart';
import '../../apiHandlers/api_interceptors.dart';
import '../../apiHandlers/json_to_type_converter.dart';

part 'sports_api_services.chopper.dart';

final _sportsApiClient = ChopperClient(
  baseUrl: Uri.parse(SportsApiConstants.baseUrl),
  converter: JsonSerializableConverter({
    EventTypeResponse: (json) => EventTypeResponse.fromJson(json),
    ResultResponse: (json) => ResultResponse.fromJson(json),
    ResultLineResponse: (json) => ResultLineResponse.fromJson(json),
  }),
  interceptors: [ApiAuthInterceptor(), ApiResponseInterceptor(), ApiRequestInterceptor()],
  errorConverter: const JsonConverter(),
);

@ChopperApi(baseUrl: SportsApiConstants.baseUrl)
abstract class SportsApiServices extends ChopperService {
  ///Don't modify
  static SportsApiServices create() {
    return _$SportsApiServices(_sportsApiClient);
  }

  @GET(path: SportsApiConstants.eventTypes)
  Future<Response<EventTypeResponse>> getSportsCategory();

  @GET(path: SportsApiConstants.resultMatch)
  Future<Response<ResultResponse>> getResultMatch();

  @GET(path: SportsApiConstants.resultLine)
  Future<ResultLineResponse> getResultLineMatch({
    @Query() required bool isYesterDay,
  });

  @GET(path: SportsApiConstants.sportsEvents)
  Future<Response<SportsResponse>> getEventWithType({@Query() required int evenTypeID, @Query() required bool tomorrow, @Query() required bool inPlay});
}
