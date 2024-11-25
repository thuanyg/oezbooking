import 'package:oezbooking/features/ticket_scanner/data/model/ticket.dart';

abstract class TicketRepository {
  Future<Ticket> fetchTicket(String id);
  Future<void> updateTicket(String id, Ticket newTicket);
}