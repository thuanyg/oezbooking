import 'package:oezbooking/features/events/data/datasource/event_datasource.dart';
import 'package:oezbooking/features/events/data/model/event.dart';
import 'package:oezbooking/features/events/domain/repository/event_repository.dart';

class EventRepositoryImpl extends EventRepository {
  final EventDatasource datasource;

  EventRepositoryImpl(this.datasource);

  @override
  Future<void> createEvent(Event event) async {
    return await datasource.createEvent(event);
  }

  @override
  Future<void> deleteEvent(Event event) async {
    return await datasource.deleteEvent(event);
  }

  @override
  Future<List<Event>> fetchEvents(String organizerID) async {
    return await datasource.fetchEvents(organizerID);
  }

  @override
  Future<void> updateEvent(Event event) async {
    return await datasource.updateEvent(event);
  }

  @override
  Future<Event> fetchEvent(String eventID)  async {
    return await datasource.fetchEvent(eventID);
  }
}
