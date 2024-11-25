import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oezbooking/features/events/data/datasource/event_datasource.dart';
import 'package:oezbooking/features/events/data/model/event.dart';

class EventDatasourceImpl extends EventDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> createEvent(Event event) async {
    try {
      await _firestore.collection("events").doc(event.id).set(event.toMap());
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<void> deleteEvent(Event event) async {
    try {
      final doc = _firestore.collection("events").doc(event.id);
      doc.set({"isDelete", true} as Map<String, dynamic>);
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<List<Event>> fetchEvents(String organizerID) async {
    try {
      final docs = await _firestore
          .collection("events")
          .where("organizer", isEqualTo: organizerID)
          .where("isDelete", isEqualTo: false)
          .orderBy("date", descending: true)
          .get();

      return docs.docs.map((doc) {
        return Event.fromJson(doc.data(), id: doc.id);
      }).toList();
    } on Exception catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> updateEvent(Event event) async {
    try {
      final doc = _firestore.collection("events").doc(event.id);
      doc.update(event.toMap());
    } on Exception catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  @override
  Future<Event> fetchEvent(String eventID) async {
    try {
      final doc = await _firestore.collection("events").doc(eventID).get();
      return Event.fromJson(doc.data() as Map<String, dynamic>);
    } on Exception catch (e) {
      print(e.toString());
      rethrow;
    }
  }
}
