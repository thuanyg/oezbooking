import 'package:bloc/bloc.dart';
import 'package:oezbooking/features/ticket_scanner/data/model/ticket.dart';
import 'package:oezbooking/features/ticket_scanner/domain/usecase/fetch_ticket.dart';
import 'package:oezbooking/features/ticket_scanner/presentation/bloc/fetch_ticket_event.dart';
import 'package:oezbooking/features/ticket_scanner/presentation/bloc/fetch_ticket_state.dart';

class FetchTicketBloc extends Bloc<FetchTicketEvent, FetchTicketState> {
  final FetchTicketUseCase fetchTicketUseCase;
  Ticket? ticket;

  FetchTicketBloc(this.fetchTicketUseCase) : super(FetchTicketInitial()) {
    on<FetchTicket>(
      (event, emit) async {
        try {
          emit(FetchTicketLoading());
          final ticket = await fetchTicketUseCase(event.id);
          this.ticket = ticket;
          emit(FetchTicketSuccess(ticket));
        } on Exception catch (e) {
          emit(FetchTicketError(e.toString()));
        }
      },
    );
  }
}
