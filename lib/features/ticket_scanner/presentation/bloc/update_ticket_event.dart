import 'package:oezbooking/features/ticket_scanner/data/model/ticket.dart';

abstract class UpdateTicketEvent {}
class UpdateTicket extends UpdateTicketEvent {
  final Ticket ticket;
  final String id;

  UpdateTicket(this.id, this.ticket);
}