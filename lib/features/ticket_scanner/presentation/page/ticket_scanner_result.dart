import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:oezbooking/core/apps/app_colors.dart';
import 'package:oezbooking/core/utils/dialogs.dart';
import 'package:oezbooking/core/utils/function_utils.dart';
import 'package:oezbooking/features/events/presentation/bloc/event_bloc.dart';
import 'package:oezbooking/features/events/presentation/bloc/event_event.dart';
import 'package:oezbooking/features/events/presentation/bloc/event_state.dart';
import 'package:oezbooking/features/login/presentation/widgets/main_button.dart';
import 'package:oezbooking/features/ticket_scanner/data/model/ticket.dart';
import 'package:oezbooking/features/ticket_scanner/presentation/bloc/update_ticket_bloc.dart';
import 'package:oezbooking/features/ticket_scanner/presentation/bloc/update_ticket_event.dart';
import 'package:oezbooking/features/ticket_scanner/presentation/bloc/update_ticket_state.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TicketScannerResult extends StatefulWidget {
  final Ticket ticket;

  const TicketScannerResult({super.key, required this.ticket});

  @override
  State<TicketScannerResult> createState() => _TicketScannerResultState();
}

class _TicketScannerResultState extends State<TicketScannerResult> {
  late EventBloc eventBloc;
  late UpdateTicketBloc updateTicketBloc;
  late Ticket ticket;

  @override
  void initState() {
    super.initState();
    ticket = widget.ticket;
    updateTicketBloc = BlocProvider.of<UpdateTicketBloc>(context);
    eventBloc = BlocProvider.of<EventBloc>(context);
    eventBloc.add(FetchEvent(widget.ticket.eventID));
  }

  @override
  void dispose() {
    super.dispose();
    updateTicketBloc.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title:
            const Text('Ticket Details', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: _buildTicketContent(context),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: AppColors.primaryColor,
        child: const Icon(
          Icons.headset_mic,
          color: Colors.black87,
        ),
        onPressed: () {},
      ),
    );
  }

  Widget _buildTicketContent(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder(
          bloc: updateTicketBloc,
          builder: (context, state) {
            if (state is UpdateTicketSuccess) {
              DialogUtils.hide(context);
              DialogUtils.hide(context);
              ticket = state.ticketUpdated;
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _getStatusAnimation(ticket),
                _buildTicketHeader(ticket),
                const SizedBox(height: 24),
                _buildTicketDetails(ticket),
                const SizedBox(height: 16),
                _buildEventDetails(),
                const SizedBox(height: 24),
                _buildActionButton(ticket),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTicketHeader(Ticket ticket) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getStatusColor(ticket),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ticket #${ticket.id}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                ticket.status,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          if (ticket.status == "Used" && ticket.usedAt != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                "Checked-in at: ${DateFormat("hh:mma dd-MM-yyyy").format(ticket.usedAt!)}",
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(Ticket ticket) {
    switch (ticket.status) {
      case 'Available':
        return Colors.green;
      case 'Used':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _getStatusAnimation(Ticket ticket) {
    switch (ticket.status) {
      case 'Available':
        return const SizedBox.shrink();
      case 'Used':
        return Center(
          child: Lottie.asset(
            "assets/animations/success.json",
            height: 75,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildQRCode() {
    return Container(
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: QrImageView(
        data: ticket.qrCodeData,
        version: QrVersions.auto,
        size: 100,
        gapless: false,
        errorStateBuilder: (cxt, err) {
          return const Center(
            child: Text('Error generating QR code'),
          );
        },
      ),
    );
  }

  Widget _buildTicketDetails(Ticket ticket) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.drawerColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildDetailRow('Ticket Type', ticket.ticketType),
          const Divider(),
          _buildDetailRow(
              'Price', '\$${ticket.ticketPrice.toStringAsFixed(2)}'),
          const Divider(),
          _buildDetailRow('Purchase Date', formatDate(ticket.createdAt)),
        ],
      ),
    );
  }

  Widget _buildEventDetails() {
    return BlocBuilder(
      bloc: eventBloc,
      builder: (context, state) {
        if (state is EventLoaded) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.drawerColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Event Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDetailRow('Event Name', state.event.name),
                const Divider(),
                _buildDetailRow('Date', formatDate(state.event.date)),
                const Divider(),
                _buildDetailRow('Location', state.event.location),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 15,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActionButton(Ticket ticket) {
    return Row(
      children: [
        if (ticket.status == "Available")
          Expanded(
            child: MainElevatedButton(
              text: "Check-in",
              onTap: () {
                DialogUtils.showConfirmationDialog(
                  context: context,
                  labelTitle: "Check-in",
                  title: "Are you sure that you want to check-in this ticket?",
                  textCancelButton: "No",
                  textAcceptButton: "Yes",
                  cancelPressed: () => Navigator.pop(context),
                  acceptPressed: () {
                    Ticket ticketUpdate = ticket;
                    ticketUpdate.status = "Used";
                    ticketUpdate.usedAt =
                        DateTime.now().toUtc().add(const Duration(hours: 7));
                    updateTicketBloc
                        .add(UpdateTicket(ticketUpdate.id, ticketUpdate));
                    // Show Dialog
                    DialogUtils.showLoadingDialog(context);
                  },
                );
              },
            ),
          ),
        const SizedBox(width: 12),
        Expanded(
          child: MainElevatedButton(
            text: "Back",
            onTap: () => Navigator.of(context).pop(),
          ),
        ),
      ],
    );
  }
}
