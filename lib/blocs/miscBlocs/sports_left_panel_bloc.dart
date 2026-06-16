import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import '../../models/competation_with_events_model.dart';
import '../../models/event_with_type_model.dart';

// ============ VIEW MODES ============
enum SportsViewMode { competitions, events, matchOdds, orderWindow }

// ============ STATE ============
abstract class SportsLeftPanelState {
  const SportsLeftPanelState();
}

class SportsLeftPanelInitial extends SportsLeftPanelState {
  const SportsLeftPanelInitial();
}

class SportsLeftPanelSuccess extends SportsLeftPanelState {
  final String screenType;
  final List<Competition> competitions;
  final Competition? selectedCompetition;
  final Event? selectedEvent;
  final Event? pendingEvent;
  final SportsViewMode viewMode;
  final List<String> breadcrumbs;
  final Map<String, List<Event>> groupedEvents;
  const SportsLeftPanelSuccess({
    required this.screenType,
    required this.competitions,
    this.selectedCompetition,
    this.selectedEvent,
    this.pendingEvent,
    required this.viewMode,
    required this.breadcrumbs,
    required this.groupedEvents,
  });
}

// ============ EVENTS ============
abstract class SportsLeftPanelEvent {
  const SportsLeftPanelEvent();
}

class InitSportsPanel extends SportsLeftPanelEvent {
  final String screenType;
  final List<Competition> competitions;

  const InitSportsPanel({
    required this.screenType,
    required this.competitions,
  });
}

class SelectCompetition extends SportsLeftPanelEvent {
  final Competition competition;
  final String screenType;
  final List<Competition> competitions;

  const SelectCompetition({
    required this.competition,
    required this.screenType,
    required this.competitions,
  });
}

class SelectEvent extends SportsLeftPanelEvent {
  final Event event;

  const SelectEvent(this.event);
}

class SelectMatchOdds extends SportsLeftPanelEvent {
  final Event? event;
  const SelectMatchOdds({this.event});
}

class NavigateBreadcrumb extends SportsLeftPanelEvent {
  final int index;

  const NavigateBreadcrumb(this.index);
}

class ResetSportsPanel extends SportsLeftPanelEvent {}

// ============ BLOC ============
class SportsLeftPanelBloc extends Bloc<SportsLeftPanelEvent, SportsLeftPanelState> {
  SportsLeftPanelBloc() : super(const SportsLeftPanelInitial()) {
    on<InitSportsPanel>(_onInitSportsPanel);
    on<SelectCompetition>(_onSelectCompetition);
    on<SelectEvent>(_onSelectEvent);
    on<SelectMatchOdds>(_onSelectMatchOdds);
    on<NavigateBreadcrumb>(_onNavigateBreadcrumb);
    on<ResetSportsPanel>(_onResetSportsPanel);
  }

  // ============ EVENT HANDLERS ============

  void _onInitSportsPanel(
    InitSportsPanel event,
    Emitter<SportsLeftPanelState> emit,
  ) {
    emit(SportsLeftPanelSuccess(
      screenType: event.screenType,
      competitions: event.competitions,
      breadcrumbs: [event.screenType],
      viewMode: SportsViewMode.competitions,
      groupedEvents: const {},
      pendingEvent: null,
    ));
  }

  void _onSelectCompetition(
    SelectCompetition event,
    Emitter<SportsLeftPanelState> emit,
  ) {
    final groupedEvents = _groupEventsByDate(event.competition.events);

    emit(SportsLeftPanelSuccess(
      screenType: event.screenType,
      competitions: event.competitions,
      selectedCompetition: event.competition,
      groupedEvents: groupedEvents,
      viewMode: SportsViewMode.events,
      breadcrumbs: [event.screenType, event.competition.name],
      pendingEvent: null,
    ));
  }

  void _onSelectEvent(
    SelectEvent event,
    Emitter<SportsLeftPanelState> emit,
  ) {
    final currentState = state;
    if (currentState is! SportsLeftPanelSuccess) return;

    // Validate event has open date
    if (event.event.openDate.isEmpty) return;

    // Find the competition for this event
    final competition = _findCompetitionForEvent(
      currentState.competitions,
      currentState.selectedCompetition,
      event.event,
    );

    if (competition == null) return;

    final groupedEvents = _groupEventsByDate(competition.events);

    // If order window is currently open, keep it open and just update the event
    if (currentState.viewMode == SportsViewMode.orderWindow) {
      emit(SportsLeftPanelSuccess(
        screenType: currentState.screenType,
        competitions: currentState.competitions,
        selectedCompetition: competition,
        selectedEvent: event.event, // Update to new event
        pendingEvent: null,
        groupedEvents: groupedEvents,
        viewMode: SportsViewMode.orderWindow, // Keep orderWindow mode
        breadcrumbs: [
          currentState.screenType,
          competition.name,
          event.event.name,
        ],
      ));
      return;
    }

    // Normal behavior: select event but DON'T open order window automatically
    // Just show Match Odds view
    emit(SportsLeftPanelSuccess(
      screenType: currentState.screenType,
      competitions: currentState.competitions,
      selectedCompetition: competition,
      selectedEvent: event.event,
      pendingEvent: null,
      groupedEvents: groupedEvents,
      viewMode: SportsViewMode.matchOdds, // Stay in matchOdds mode
      breadcrumbs: [
        currentState.screenType,
        competition.name,
        event.event.name,
      ],
    ));
  }

  void _onSelectMatchOdds(
    SelectMatchOdds event,
    Emitter<SportsLeftPanelState> emit,
  ) {
    final currentState = state;
    if (currentState is! SportsLeftPanelSuccess) return;

    // Prefer provided event, otherwise use pendingEvent, otherwise current selectedEvent
    final Event? ev = event.event ?? currentState.pendingEvent ?? currentState.selectedEvent;
    if (ev == null) return;

    // Ensure we have the competition for this event
    final competition = _findCompetitionForEvent(currentState.competitions, currentState.selectedCompetition, ev);
    final groupedEvents = competition != null ? _groupEventsByDate(competition.events) : currentState.groupedEvents;

    final List<String> newBreadcrumbs = [currentState.screenType];
    if (competition != null) newBreadcrumbs.add(competition.name);
    newBreadcrumbs.add(ev.name);

    emit(SportsLeftPanelSuccess(
      screenType: currentState.screenType,
      competitions: currentState.competitions,
      selectedCompetition: competition ?? currentState.selectedCompetition,
      selectedEvent: ev,
      pendingEvent: null,
      groupedEvents: groupedEvents,
      viewMode: SportsViewMode.orderWindow,
      breadcrumbs: newBreadcrumbs,
    ));
  }

  void _onNavigateBreadcrumb(
    NavigateBreadcrumb event,
    Emitter<SportsLeftPanelState> emit,
  ) {
    final currentState = state;
    if (currentState is! SportsLeftPanelSuccess) return;

    final newBreadcrumbs = currentState.breadcrumbs.sublist(0, event.index + 1);
    final (viewMode, selectedCompetition, selectedEvent) = _getNavigationState(
      event.index,
      currentState,
    );

    emit(SportsLeftPanelSuccess(
      screenType: currentState.screenType,
      competitions: currentState.competitions,
      selectedCompetition: selectedCompetition,
      selectedEvent: selectedEvent,
      viewMode: viewMode,
      breadcrumbs: newBreadcrumbs,
      groupedEvents: currentState.groupedEvents,
      pendingEvent: null,
    ));
  }

  void _onResetSportsPanel(
    ResetSportsPanel event,
    Emitter<SportsLeftPanelState> emit,
  ) {
    emit(const SportsLeftPanelInitial());
  }

  // ============ HELPER METHODS ============

  Competition? _findCompetitionForEvent(
    List<Competition> competitions,
    Competition? selectedCompetition,
    Event event,
  ) {
    // Check if selected competition matches first
    if (selectedCompetition?.id == event.competitionId) {
      return selectedCompetition;
    }

    // Search in all competitions
    try {
      return competitions.firstWhereOrNull((c) => c.id == event.competitionId);
    } catch (e) {
      return null;
    }
  }

  (SportsViewMode, Competition?, Event?) _getNavigationState(int index, SportsLeftPanelSuccess state) {
    switch (index) {
      case 0: // Back to competitions
        return (SportsViewMode.competitions, null, null);
      case 1: // Back to events
        return (SportsViewMode.events, state.selectedCompetition, null);
      case 2: // Back to match odds
        return (SportsViewMode.matchOdds, state.selectedCompetition, state.selectedEvent);
      default:
        return (SportsViewMode.competitions, null, null);
    }
  }

  Map<String, List<Event>> _groupEventsByDate(List<Event> events) {
    final Map<String, List<Event>> grouped = {};

    for (final event in events) {
      if (event.openDate.isEmpty) continue;

      final dateKey = _extractDateKey(event.openDate);
      grouped.putIfAbsent(dateKey, () => []).add(event);
    }

    // Sort events within each date
    for (final dateKey in grouped.keys) {
      grouped[dateKey]!.sort((a, b) => a.name.compareTo(b.name));
    }

    return grouped;
  }

  String _extractDateKey(String openDate) {
    final date = DateTime.parse(openDate);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
