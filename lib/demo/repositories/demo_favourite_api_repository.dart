import '../../apis/apiRepositories/favouriteRepo/favourite_api_repository.dart';
import 'package:chopper/chopper.dart';
import '../../models/fav_stake_model.dart';
import '../../models/favourite_model.dart';
import '../data/demo_hive_store.dart';
import 'demo_response.dart';

class DemoFavouriteApiRepository extends FavouriteApiRepository {
  DemoFavouriteApiRepository(this.store) : super();

  final DemoHiveStore store;

  @override
  Future<Response> addFavouriteEvents({required Map<String, dynamic> body}) async {
    final eventId = int.tryParse('${body['eventId'] ?? body['matchId'] ?? body['id'] ?? ''}') ?? 0;
    if (eventId != 0) {
      final favourites = await store.list('favourites');
      if (!favourites.any((item) => item['id'] == eventId || item['eventId'] == eventId)) {
        // Try local store first; fall back to body data so live events can be favourited too.
        final event = await _eventById(eventId);
        final entry = event.isNotEmpty ? {...event, 'eventId': eventId, 'userId': 'demo-user-001'} : {...body, 'id': eventId, 'eventId': eventId, 'userId': 'demo-user-001'};
        favourites.add(entry);
        await store.putList('favourites', favourites);
      }
    }
    return DemoResponse.raw({'status': 200, 'message': 'Added to demo favourites'});
  }

  @override
  Future<Response> removeFavouriteEvents({required Map<String, dynamic> body}) async {
    final matchId = body['matchId']?.toString() ?? body['eventId']?.toString() ?? body['id']?.toString() ?? '';
    final favourites = await store.list('favourites');
    favourites.removeWhere((item) => '${item['id']}' == matchId || '${item['eventId']}' == matchId);
    await store.putList('favourites', favourites);
    return DemoResponse.raw({'status': 200, 'message': 'Removed from demo favourites'});
  }

  @override
  Future<Response<FavouriteModelResponse>> fetchFavEvent() async {
    final favourites = await store.list('favourites');
    final json = {'status': 200, 'message': 'success', 'data': favourites};
    return DemoResponse.typed(json, FavouriteModelResponse.fromJson(json));
  }

  @override
  Future<Response<FavouriteStakeResponse>> getFavStake() async {
    final favStake = await store.map('favStake');
    final json = {'status': 200, 'message': 'success', 'data': favStake};
    return DemoResponse.typed(json, FavouriteStakeResponse.fromJson(json));
  }

  @override
  Future<Response> addFavStake({required Map<String, dynamic> body}) async {
    await store.putMap('favStake', body);
    return DemoResponse.raw({'status': 200, 'message': 'Demo stakes saved'});
  }

  @override
  Future<Response> updateFavStake({required Map<String, dynamic> body}) async {
    await store.putMap('favStake', body);
    return DemoResponse.raw({'status': 200, 'message': 'Demo stakes updated'});
  }

  Future<Map<String, dynamic>> _eventById(int eventId) async {
    final sports = await store.list('sportsEvents');
    for (final sport in sports) {
      final events = sport['event'];
      if (events is List) {
        for (final event in events) {
          if (event is Map && event['id'] == eventId) return Map<String, dynamic>.from(event);
        }
      }
    }
    return <String, dynamic>{};
  }
}
