import 'package:oezbooking/features/ticket_scanner/data/model/ticket.dart';
import 'package:oezbooking/features/ticket_scanner/domain/repository/ticket_repository.dart';

class FetchTicketUseCase {
  final TicketRepository repository;

  FetchTicketUseCase(this.repository);

  Future<Ticket> call(String id) async {
    return await repository.fetchTicket(id);
  }
}
