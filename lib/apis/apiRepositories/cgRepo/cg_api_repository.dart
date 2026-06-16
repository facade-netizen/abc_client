import 'package:chopper/chopper.dart';
import '../../../models/casion_history_model.dart';
import '../../../models/cg_balance_model.dart';
import '../../../models/sportsbook_model.dart';
import 'cg_api_services.dart';

class CGApiRepository {
  CGApiRepository() : _cgApiServices = CGApiServices.create();
  final CGApiServices _cgApiServices;

  Future<Response<CGBalanceResponse>> getCGBalance(String provider) async {
    try {
      return _cgApiServices.getCGBalance(provider);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> addCGMoney({required Map<String, dynamic> body}) async {
    return await _cgApiServices.addCGMoney(body: body);
  }

  Future<Response> withCGDrawMoney({required Map<String, dynamic> body}) async {
    return await _cgApiServices.withCGDrawMoney(body: body);
  }

  Future<Response<CasinoHistoryResponse>> getCGHistory(
    String fromDate,
    String toDate,
    int limit,
    int page,
  ) async {
    try {
      return _cgApiServices.getCGHistory(
        fromDate,
        toDate,
        limit,
        page,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> fetchPremium({required Map<String, dynamic> body}) async {
    return await _cgApiServices.fetchPremium(body: body);
  }

  Future<Response<SportsBookResponse>> getSportsBookHistory(String status, String fromDate, String toDate, int limit, int page) async {
    try {
      return _cgApiServices.getSportsBookHistory(status, fromDate, toDate, limit, page);
    } catch (e) {
      rethrow;
    }
  }
}
