import 'package:oezbooking/features/events/data/model/event.dart';

abstract class EventEvent {}

class FetchEvent extends EventEvent {
  final String eventID;

  FetchEvent(this.eventID);
}

class FetchEvents extends EventEvent {
  final String organizerID;

  FetchEvents(this.organizerID);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FetchEvents &&
          runtimeType == other.runtimeType &&
          organizerID == other.organizerID;

  @override
  int get hashCode => organizerID.hashCode;
}

class CreateEvent extends EventEvent {
  final Event event;

  CreateEvent(this.event);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateEvent &&
          runtimeType == other.runtimeType &&
          event == other.event;

  @override
  int get hashCode => event.hashCode;
}

class DeleteEvent extends EventEvent {
  final Event event;

  DeleteEvent(this.event);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeleteEvent &&
          runtimeType == other.runtimeType &&
          event == other.event;

  @override
  int get hashCode => event.hashCode;
}

class UpdateEvent extends EventEvent {
  final Event event;

  UpdateEvent(this.event);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateEvent &&
          runtimeType == other.runtimeType &&
          event == other.event;

  @override
  int get hashCode => event.hashCode;
}
