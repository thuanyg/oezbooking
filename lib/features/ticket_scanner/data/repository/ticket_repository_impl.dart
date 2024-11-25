import 'package:oezbooking/features/ticket_scanner/data/datasource/ticket_datasource.dart';
import 'package:oezbooking/features/ticket_scanner/data/model/ticket.dart';
import 'package:oezbooking/features/ticket_scanner/domain/repository/ticket_repository.dart';

class TicketRepositoryImpl extends TicketRepository {
  final TicketDatasource datasource;

  TicketRepositoryImpl(this.datasource);

  @override
  Future<Ticket> fetchTicket(String id) async {
    return await datasource.fetchTicket(id);
  }

  @override
  Future<void> updateTicket(String id, Ticket newTicket) async {
    return await datasource.updateTicket(id, newTicket);
  }
}
