import 'package:oezbooking/features/ticket_scanner/data/model/ticket.dart';

abstract class FetchTicketState {}
class FetchTicketInitial extends FetchTicketState {}
class FetchTicketLoading extends FetchTicketState {}
class FetchTicketSuccess extends FetchTicketState {
  final Ticket ticket;

  FetchTicketSuccess(this.ticket);
}
class FetchTicketError extends FetchTicketState {
  final String error;

  FetchTicketError(this.error);

}