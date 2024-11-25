import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oezbooking/features/events/domain/usecase/event_management.dart';
import 'event_event.dart';
import 'event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final EventManagementUseCase _useCase;

  EventBloc(this._useCase) : super(EventInitial()) {
    on<FetchEvents>(_onFetchEvents);
    on<FetchEvent>(_onFetchEvent);
    on<CreateEvent>(_onCreateEvent);
    on<DeleteEvent>(_onDeleteEvent);
    on<UpdateEvent>(_onUpdateEvent);
  }

  Future<void> _onFetchEvents(
      FetchEvents event, Emitter<EventState> emit) async {
    emit(EventLoading());
    try {
      final events = await _useCase.fetchEvents(event.organizerID);
      emit(EventsLoaded(events));
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onFetchEvent(
      FetchEvent event, Emitter<EventState> emit) async {
    emit(EventLoading());
    try {
      final e = await _useCase.fetchEvent(event.eventID);
      emit(EventLoaded(e));
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onCreateEvent(
      CreateEvent event, Emitter<EventState> emit) async {
    emit(EventLoading());
    try {
      await _useCase.createEvent(event.event);
      emit(EventActionSuccess());
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onDeleteEvent(
      DeleteEvent event, Emitter<EventState> emit) async {
    emit(EventLoading());
    try {
      await _useCase.deleteEvent(event.event);
      emit(EventActionSuccess());
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onUpdateEvent(
      UpdateEvent event, Emitter<EventState> emit) async {
    emit(EventLoading());
    try {
      await _useCase.updateEvent(event.event);
      emit(EventActionSuccess());
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }
}
