import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oezbooking/features/ticket_scanner/data/model/ticket.dart';

class TicketDatasource {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  Future<Ticket> fetchTicket(String id) async {
    try {
      // Reference to the tickets collection
      DocumentSnapshot ticketDoc =
          await firebaseFirestore.collection('tickets').doc(id).get();

      // Check if the document exists
      if (!ticketDoc.exists) {
        throw Exception('Ticket not found');
      }

      return Ticket.fromFirestore(ticketDoc.data() as Map<String, dynamic>, id);
    } catch (e) {
      // Handle errors and rethrow
      throw Exception('Failed to fetch ticket: $e');
    }
  }

  Future<void> updateTicket(String id, Ticket newTicket) async {
    try {
      // Reference the specific ticket document by ID
      DocumentReference ticketDoc =
          firebaseFirestore.collection('tickets').doc(id);

      // Perform the update
      await ticketDoc.update(newTicket.toJson());

      print('Ticket updated successfully');
    } catch (e) {
      // Handle errors
      throw Exception('Failed to update ticket: $e');
    }
  }
}
