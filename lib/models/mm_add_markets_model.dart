import '../blocs/addBloc/add_favourite_event_bloc.dart';
import 'favourite_model.dart';

class AddedMMResponse {
  final int status;
  final List<AddedMMEventItem> data;
  final String message;

  AddedMMResponse({
    required this.status,
    required this.data,
    required this.message,
  });

  factory AddedMMResponse.fromJson(Map<dynamic, dynamic> json) {
    return AddedMMResponse(
      status: json['status'],
      data: (json['data'] as List).map((e) => AddedMMEventItem.fromJson(e)).toList(),
      message: json['message'],
    );
  }
}

class AddedMMEventItem {
  final int id;
  final String eventId;
  final String? marketId;
  final String userId;
  final FavType favType;

  AddedMMEventItem({
    required this.id,
    required this.eventId,
    required this.marketId,
    required this.userId,
    required this.favType,
  });

  factory AddedMMEventItem.fromJson(Map<String, dynamic> json) {
    return AddedMMEventItem(
      id: json['Id'],
      eventId: json['EventId'],
      marketId: json['MarketId'] == "" ? null : json['MarketId'],
      userId: json['UserId'],
      favType: favTypeValue(json['Type'] ?? ''),
    );
  }
}
