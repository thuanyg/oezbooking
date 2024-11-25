import 'package:oezbooking/features/ticket_scanner/data/model/ticket.dart';

abstract class UpdateTicketState {}

class UpdateTicketInitial extends UpdateTicketState {}

class UpdateTicketLoading extends UpdateTicketState {}

class UpdateTicketSuccess extends UpdateTicketState {
  final Ticket ticketUpdated;

  UpdateTicketSuccess(this.ticketUpdated);
}

class UpdateTicketError extends UpdateTicketState {
  String error;

  UpdateTicketError(this.error);
}
