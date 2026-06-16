import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChangeMainTabViewBloc extends Bloc<ChangeMainTabViewEvent, ChangeMainTabViewState> {
  ChangeMainTabViewBloc() : super(ChangeMainTabViewSuccess()) {
    on<ChangeMainTabView>((event, emit) {
      if (kDebugMode) debugPrint("Called - ChangeMainTabViewBloc to screen >> ${event.menu}");
      emit(ChangeMainTabViewSuccess(menu: event.menu, sid: event.sid));
    });
    on<ChangePageSetToInit>((event, emit) {
      emit(ChangeMainTabViewSuccess());
    });
  }
}

//state - inst
abstract class ChangeMainTabViewState {}

//event - inst

abstract class ChangeMainTabViewEvent {}

///states - impl
class ChangeMainTabViewSuccess extends ChangeMainTabViewState {
  final int? sid;
  final Map<String, dynamic>? menu;
  ChangeMainTabViewSuccess({this.menu, this.sid});
}

///events impl
class ChangeMainTabView extends ChangeMainTabViewEvent {
  final int? sid;
  final Map<String, dynamic>? menu;
  ChangeMainTabView({this.menu, this.sid});
}

class ChangePageSetToInit extends ChangeMainTabViewEvent {}
