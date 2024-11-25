import 'package:bloc/bloc.dart';
import 'package:oezbooking/features/ticket_scanner/domain/usecase/update_ticket.dart';
import 'package:oezbooking/features/ticket_scanner/presentation/bloc/update_ticket_event.dart';
import 'package:oezbooking/features/ticket_scanner/presentation/bloc/update_ticket_state.dart';

class UpdateTicketBloc extends Bloc<UpdateTicketEvent, UpdateTicketState> {
  final UpdateTicketUseCase updateTicketUseCase;

  UpdateTicketBloc(this.updateTicketUseCase) : super(UpdateTicketInitial()) {
    on<UpdateTicket>(
      (event, emit) async {
        try {
          emit(UpdateTicketLoading());
          await updateTicketUseCase.call(event.id, event.ticket);
          emit(UpdateTicketSuccess(event.ticket));
        } on Exception catch (e) {
          emit(UpdateTicketError(e.toString()));
        }
      },
    );
  }

  void reset() {
    emit(UpdateTicketInitial());
  }
}
