import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChangePageViewBloc extends Bloc<ChangePageViewEvent, ChangePageViewState> {
  ChangePageViewBloc() : super(ChangePageViewSuccess()) {
    on<ChangePageView>((event, emit) {
      if (kDebugMode) debugPrint("Called - ChangePageViewBloc to screen >> ${event.dashboardTabs}");
      emit(ChangePageViewSuccess(
        inplayMenu: event.inplayMenu,
        dashboardTabs: event.dashboardTabs,
        betTabs: event.betTabs,
        accountMenu: event.accountMenu,
        resultsMenu: event.resultsMenu,
      ));
    });
    on<ChangePageSetToInit>((event, emit) {
      emit(ChangePageViewSuccess());
    });
  }
}

//state - inst
abstract class ChangePageViewState {}

class ChangePageViewInitial extends ChangePageViewState {}

//event - inst

abstract class ChangePageViewEvent {}

///states - impl
class ChangePageViewSuccess extends ChangePageViewState {
  final Map<String, dynamic>? inplayMenu;
  final Map<String, dynamic>? dashboardTabs;
  final Map<String, dynamic>? betTabs;
  final Map<String, dynamic>? accountMenu;
  final Map<String, dynamic>? resultsMenu;
  ChangePageViewSuccess({
    this.inplayMenu,
    this.dashboardTabs,
    this.betTabs,
    this.accountMenu,
    this.resultsMenu,
  });
}

///events impl
class ChangePageView extends ChangePageViewEvent {
  final Map<String, dynamic>? inplayMenu;
  final Map<String, dynamic>? dashboardTabs;
  final Map<String, dynamic>? betTabs;
  final Map<String, dynamic>? accountMenu;
  final Map<String, dynamic>? resultsMenu;
  ChangePageView({
    this.inplayMenu,
    this.dashboardTabs,
    this.betTabs,
    this.accountMenu,
    this.resultsMenu,
  });
}

class ChangePageSetToInit extends ChangePageViewEvent {}
