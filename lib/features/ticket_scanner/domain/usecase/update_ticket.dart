import 'package:oezbooking/features/ticket_scanner/data/model/ticket.dart';
import 'package:oezbooking/features/ticket_scanner/domain/repository/ticket_repository.dart';

class UpdateTicketUseCase {
  final TicketRepository repository;

  UpdateTicketUseCase(this.repository);

  Future<void> call(String id, Ticket ticket) async {
    return await repository.updateTicket(id, ticket);
  }
}
