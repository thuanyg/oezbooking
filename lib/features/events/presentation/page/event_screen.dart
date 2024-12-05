import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oezbooking/core/apps/app_colors.dart';
import 'package:oezbooking/core/utils/dialogs.dart';
import 'package:oezbooking/features/events/data/model/event.dart';
import 'package:oezbooking/features/events/presentation/bloc/event_bloc.dart';
import 'package:oezbooking/features/events/presentation/bloc/event_event.dart';
import 'package:oezbooking/features/events/presentation/bloc/event_state.dart';
import 'package:oezbooking/features/events/presentation/widgets/event_card.dart';
import 'package:oezbooking/features/events/presentation/widgets/event_detail_preview.dart';
import 'package:oezbooking/features/events/presentation/widgets/event_edit.dart';
import 'package:oezbooking/features/login/presentation/bloc/login_bloc.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen>
    with SingleTickerProviderStateMixin {
  late EventBloc eventBloc;
  late LoginBloc loginBloc;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    eventBloc = BlocProvider.of<EventBloc>(context);
    loginBloc = BlocProvider.of<LoginBloc>(context);
    eventBloc.add(FetchEvents(loginBloc.organizer?.id ?? ""));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          height: 64,
          width: size.width,
          padding: const EdgeInsets.symmetric(horizontal: 28),
          color: Colors.black26,
          child: Row(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "My Events",
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: showCreateEventDialog,
                icon: const Icon(Icons.add),
                color: Colors.white70,
              ),
            ],
          ),
        ),
        TabBar(
          labelStyle: const TextStyle(
            color: Colors.white70,
          ),
          indicatorSize: TabBarIndicatorSize.label,
          dividerHeight: .5,
          dividerColor: Colors.transparent,
          indicatorColor: Colors.grey,
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming Events'),
            Tab(text: 'Past Events'),
          ],
        ),
        Expanded(
          child: BlocBuilder(
            bloc: eventBloc,
            builder: (context, state) {
              if (state is EventActionSuccess) {
                DialogUtils.hide(context);
                DialogUtils.hide(context);
                eventBloc.add(FetchEvents(loginBloc.organizer?.id ?? ""));
              }
              if (state is EventLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (state is EventsLoaded) {
                // Separate upcoming and past events
                final now = DateTime.now();
                final upcomingEvents = state.events
                    .where((event) => event.date.isAfter(now))
                    .toList();
                final pastEvents = state.events
                    .where((event) => event.date.isBefore(now))
                    .toList();

                return TabBarView(
                  controller: _tabController,
                  children: [
                    // Upcoming Events Tab
                    _buildEventList(upcomingEvents),
                    // Past Events Tab
                    _buildEventList(pastEvents),
                  ],
                );
              }
              if (state is EventError) {
                return Center(
                  child: Text(
                    state.message,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEventList(List<Event> events) {
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        return EventCard(
          event: events[index],
          onView: () async => showEventPreview(events[index]),
          onEdit: () async => showEditEventDialog(events[index]),
          onDelete: () {
            DialogUtils.showConfirmationDialog(
              cancelPressed: () => Navigator.pop(context),
              context: context,
              title: "Are you sure you want to delete this event?",
              textCancelButton: "Cancel",
              textAcceptButton: "Delete",
              acceptPressed: () {
                DialogUtils.showLoadingDialog(context);
                final eventUpdate = events[index];
                eventUpdate.isDelete = true;
                eventBloc.add(UpdateEvent(eventUpdate));
              },
            );
          },
        );
      },
    );
  }

  showEditEventDialog(Event event) async {
    final size = MediaQuery.of(context).size;
    await showGeneralDialog(
      context: context,
      barrierLabel: '',
      barrierDismissible: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container(
          height: size.height * 0.8,
          width: size.width,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Align(
            alignment: Alignment.center,
            child: Material(
              color: Colors.transparent,
              child: Container(
                height: size.height * 0.8,
                width: size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  child: EditEvent(
                    actionType: ActionType.update,
                    event: event,
                    onClose: () => Navigator.pop(context),
                    onSave: (event) async {
                      eventBloc.add(UpdateEvent(event));
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> showEventPreview(Event event) async {
    final size = MediaQuery.of(context).size;
    await showGeneralDialog(
      context: context,
      barrierLabel: '',
      barrierDismissible: true,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container(
          height: size.height * 0.8,
          width: size.width,
          child: Align(
            alignment: Alignment.center,
            child: Material(
              color: Colors.transparent,
              child: Container(
                height: size.height * 0.8,
                width: size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  child: EventPreview(
                    event: event,
                    onEdit: (event) => showEditEventDialog(event),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void showCreateEventDialog() {
    final size = MediaQuery.of(context).size;
    showGeneralDialog(
      context: context,
      barrierLabel: '',
      barrierDismissible: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container(
          height: size.height * 0.8,
          width: size.width,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Align(
            alignment: Alignment.center,
            child: Material(
              color: Colors.transparent,
              child: Container(
                height: size.height * 0.8,
                width: size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  child: EditEvent(
                    actionType: ActionType.create,
                    onClose: () => Navigator.pop(context),
                    onSave: (event) {
                      eventBloc.add(CreateEvent(event));
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
