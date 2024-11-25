abstract class FetchTicketEvent {}

class FetchTicket extends FetchTicketEvent {
  final String id;

  FetchTicket(this.id);
}
