import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/event_with_type_model.dart';
import '../../screens/deskopView/sportsView/betSlipOrder/sports_bet_slip_order_card.dart';
import '../signalRBloc/protoUsage/receive/receive.pb.dart';

// ============ EVENTS ============
abstract class BetSlipEvent {}

class AddBetSlipItem extends BetSlipEvent {
  final Event event;
  final String price;
  final bool isBack;
  final AbcRunner? runner;
  final String? defaultStake;

  AddBetSlipItem({
    required this.event,
    required this.price,
    required this.isBack,
    this.runner,
    this.defaultStake,
  });
}

class RemoveBetSlipItem extends BetSlipEvent {
  final int index;

  RemoveBetSlipItem(this.index);
}

// Add ClearBetSlipItems event
class ClearBetSlipItems extends BetSlipEvent {}

// ============ STATES ============
abstract class BetSlipState {}

class BetSlipInitial extends BetSlipState {}

class BetSlipUpdated extends BetSlipState {
  final List<BetSlipItem> betSlipItems;

  BetSlipUpdated(this.betSlipItems);
}

// ============ BLOC ============
class BetSlipBloc extends Bloc<BetSlipEvent, BetSlipState> {
  final List<BetSlipItem> _betSlipItems = [];

  BetSlipBloc() : super(BetSlipInitial()) {
    on<AddBetSlipItem>(_onAddBetSlipItem);
    on<RemoveBetSlipItem>(_onRemoveBetSlipItem);
    on<ClearBetSlipItems>((event, emit) {
      _betSlipItems.clear();
      emit(BetSlipUpdated(List.from(_betSlipItems)));
    });
  }

  void _onAddBetSlipItem(AddBetSlipItem event, Emitter<BetSlipState> emit) {
    final index = _betSlipItems.indexWhere(
      (b) => b.event.id == event.event.id && b.price == event.price && b.isBack == event.isBack,
    );

    if (index == -1) {
      _betSlipItems.add(
        BetSlipItem(
          event: event.event,
          price: event.price,
          isBack: event.isBack,
          runner: event.runner,
          defaultStake: event.defaultStake,
        ),
      );
    }

    emit(BetSlipUpdated(List.from(_betSlipItems)));
  }

  void _onRemoveBetSlipItem(RemoveBetSlipItem event, Emitter<BetSlipState> emit) {
    if (event.index >= 0 && event.index < _betSlipItems.length) {
      _betSlipItems.removeAt(event.index);
    }

    emit(BetSlipUpdated(List.from(_betSlipItems)));
  }
}
