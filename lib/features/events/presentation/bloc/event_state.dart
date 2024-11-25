import 'package:oezbooking/features/events/data/model/event.dart';

abstract class EventState {}

class EventInitial extends EventState {}

class EventLoading extends EventState {}

class EventsLoaded extends EventState {
  final List<Event> events;

  EventsLoaded(this.events);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventsLoaded &&
          runtimeType == other.runtimeType &&
          events == other.events;

  @override
  int get hashCode => events.hashCode;
}

class EventLoaded extends EventState {
  final Event event;

  EventLoaded(this.event);
}

class EventError extends EventState {
  final String message;

  EventError(this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}

class EventActionSuccess extends EventState {}
