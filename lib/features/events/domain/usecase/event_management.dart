import 'package:oezbooking/features/events/data/model/event.dart';
import 'package:oezbooking/features/events/domain/repository/event_repository.dart';

class EventManagementUseCase {
  final EventRepository _repository;

  EventManagementUseCase(this._repository);

  Future<void> createEvent(Event event) async {
    return await _repository.createEvent(event);
  }

  Future<void> deleteEvent(Event event) async {
    return await _repository.deleteEvent(event);
  }

  Future<void> updateEvent(Event event) async {
    return await _repository.updateEvent(event);
  }

  Future<List<Event>> fetchEvents(String organizerID) async {
    return await _repository.fetchEvents(organizerID);
  }

  Future<Event> fetchEvent(String eventID) async {
    return await _repository.fetchEvent(eventID);
  }
}
