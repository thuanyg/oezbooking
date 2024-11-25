import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oezbooking/features/events/data/model/event.dart';
import 'package:oezbooking/features/orders/data/datasource/order_datasource.dart';
import 'package:oezbooking/features/orders/data/model/order.dart' as OrderModel;

class OrderDatasourceImpl extends OrderDatasource {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Future<List<OrderModel.Order>> fetchOrders(String organizer) async {
    try {
      // Fetch all events for the given organizer
      final eventQuerySnapshot = await firebaseFirestore
          .collection("events")
          .where("organizer", isEqualTo: organizer)
          .get();

      // If no events found, return an empty list
      if (eventQuerySnapshot.docs.isEmpty) {
        return [];
      }

      // Fetch orders for each event ID
      List<Future<List<OrderModel.Order>>> orderFutures =
          eventQuerySnapshot.docs.map((eventDoc) async {
        final eventId = eventDoc.data()['id'] as String;

        final orderQuerySnapshot = await firebaseFirestore
            .collection("orders")
            .where("eventID", isEqualTo: eventId)
            .get();

        // Convert Firestore documents to OrderModel.Order objects
        return orderQuerySnapshot.docs.map((orderDoc) {
          return OrderModel.Order.fromFirestore(orderDoc.data(), orderDoc.id);
        }).toList();
      }).toList();

      // Wait for all order futures to complete
      final orderLists = await Future.wait(orderFutures);

      // Flatten the list of lists
      return orderLists.expand((orderList) => orderList).toList();
    } catch (e) {
      // Handle potential errors
      print("Error fetching orders: $e");
      return [];
    }
  }

  @override
  Future<Event> fetchEventOrder(String eventID) async {
    try {
      // Fetch the event document by ID
      final eventDoc =
          await firebaseFirestore.collection("events").doc(eventID).get();

      // Check if the document exists
      if (!eventDoc.exists) {
        throw Exception("Event with ID $eventID not found.");
      }

      // Convert the document data into an Event object
      return Event.fromJson(eventDoc.data()!);
    } catch (e) {
      print("Error fetching event: $e");
      rethrow; // Re-throwing the error to let the caller handle it
    }
  }

  @override
  Future<String> fetchUserOrder(String userID) async {
    try {
      // Query the orders collection for the specific user ID
      final userQuerySnapshot = await firebaseFirestore
          .collection("users")
          .where("id", isEqualTo: userID)
          .get();

      // If no orders are found, return an empty string or handle as needed
      if (userQuerySnapshot.docs.isEmpty) {
        return "No results found for userID: $userID";
      }

      // Combine order IDs into a single string (or handle as necessary)
      final userFullName = userQuerySnapshot.docs.first.get("fullName");

      return userFullName;
    } catch (e) {
      print("Error fetching user orders: $e");
      rethrow; // Re-throwing the error to let the caller handle it
    }
  }
}
