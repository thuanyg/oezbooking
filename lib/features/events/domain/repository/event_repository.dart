import 'package:oezbooking/features/events/data/model/event.dart';

abstract class EventRepository {
  Future<void> createEvent(Event event);
  Future<void> deleteEvent(Event event);
  Future<void> updateEvent(Event event);
  Future<List<Event>> fetchEvents(String organizerID);
  Future<Event> fetchEvent(String eventID);
}