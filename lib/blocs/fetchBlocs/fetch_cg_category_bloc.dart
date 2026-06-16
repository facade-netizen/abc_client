import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../apis/apiHandlers/api_constants.dart';
import '../../models/cg_model.dart';

class FetchCGCategoryBloc extends Bloc<FetchCGCategoryEvent, FetchCGCategoryState> {
  FetchCGCategoryBloc() : super(FetchCGCategoryInitial()) {
    on<FetchCGCategory>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchCGCategoryBloc');
      emit(FetchCGCategoryProgress());
      try {
        var request = http.Request('GET', Uri.parse("${CGApiConstants.getGames}?Page=${event.page}&PageSize=${50}"));
        http.StreamedResponse response = await request.send();
        if (response.statusCode == 200) {
          final bodyString = await response.stream.bytesToString();
          final decoded = jsonDecode(bodyString);
          CGResponse cgResponse = CGResponse.fromJson(decoded);
          final List<CGData> cGData = cgResponse.data;
          const int chunkSize = 10;
          final List<CGData> emittedData = [];
          for (var i = 0; i < cGData.length; i += chunkSize) {
            final endIndex = i + chunkSize > cGData.length ? cGData.length : i + chunkSize;
            emittedData.addAll(cGData.sublist(i, endIndex));
            emit(FetchCGCategorySuccess(cGData: List.unmodifiable(emittedData)));
            await Future<void>.delayed(const Duration(seconds: 2));
          }
        } else {
          emit(FetchCGCategoryFailure("Non ${response.statusCode} Status"));
        }
      } catch (e) {
        if (kDebugMode) debugPrint("FetchCGCategory exception page=${event.page} error=$e");
        emit(FetchCGCategoryFailure(e));
      }
    });
  }
}

//states
abstract class FetchCGCategoryState {}

//events
abstract class FetchCGCategoryEvent {}

//states implementation
class FetchCGCategoryInitial extends FetchCGCategoryState {}

class FetchCGCategoryProgress extends FetchCGCategoryState {}

class FetchCGCategorySuccess extends FetchCGCategoryState {
  final List<CGData> cGData;

  FetchCGCategorySuccess({required this.cGData});
}

class FetchCGCategoryFailure extends FetchCGCategoryState {
  final dynamic error;
  FetchCGCategoryFailure(this.error);
}

//events implementation
class FetchCGCategory extends FetchCGCategoryEvent {
  final int page;
  final int pageSize;
  FetchCGCategory({required this.page, required this.pageSize});
}
