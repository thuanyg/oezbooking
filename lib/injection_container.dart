import 'package:get_it/get_it.dart';
import 'package:oezbooking/features/events/data/datasource/event_datasource.dart';
import 'package:oezbooking/features/events/data/datasource/event_datasource_impl.dart';
import 'package:oezbooking/features/events/data/repository/event_repository_impl.dart';
import 'package:oezbooking/features/events/domain/repository/event_repository.dart';
import 'package:oezbooking/features/events/domain/usecase/event_management.dart';
import 'package:oezbooking/features/events/presentation/bloc/event_bloc.dart';
import 'package:oezbooking/features/login/data/datasource/login_datasource.dart';
import 'package:oezbooking/features/login/data/datasource/login_datasource_impl.dart';
import 'package:oezbooking/features/login/data/repository/login_repository_impl.dart';
import 'package:oezbooking/features/login/domain/repository/login_repository.dart';
import 'package:oezbooking/features/login/domain/usecase/login_usecase.dart';
import 'package:oezbooking/features/login/presentation/bloc/login_bloc.dart';
import 'package:oezbooking/features/orders/data/datasource/order_datasource.dart';
import 'package:oezbooking/features/orders/data/datasource/order_datasource_impl.dart';
import 'package:oezbooking/features/orders/data/repository/order_repository_impl.dart';
import 'package:oezbooking/features/orders/domain/repository/order_repository.dart';
import 'package:oezbooking/features/orders/domain/usecase/fetch_orders.dart';
import 'package:oezbooking/features/orders/presentation/bloc/order_bloc.dart';
import 'package:oezbooking/features/ticket_scanner/data/datasource/ticket_datasource.dart';
import 'package:oezbooking/features/ticket_scanner/data/repository/ticket_repository_impl.dart';
import 'package:oezbooking/features/ticket_scanner/domain/repository/ticket_repository.dart';
import 'package:oezbooking/features/ticket_scanner/domain/usecase/fetch_ticket.dart';
import 'package:oezbooking/features/ticket_scanner/domain/usecase/update_ticket.dart';
import 'package:oezbooking/features/ticket_scanner/presentation/bloc/fetch_ticket_bloc.dart';
import 'package:oezbooking/features/ticket_scanner/presentation/bloc/update_ticket_bloc.dart';

final sl = GetIt.instance;

void initServiceLocator() {
  /// Auth
  sl.registerLazySingleton<LoginDatasource>(
    () => LoginDatasourceImpl(),
  );

  sl.registerLazySingleton<LoginRepository>(
    () => LoginRepositoryImpl(sl<LoginDatasource>()),
  );

  sl.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(sl<LoginRepository>()),
  );

  sl.registerLazySingleton<LoginBloc>(
    () => LoginBloc(sl<LoginUseCase>()),
  );

  /// Events
  sl.registerLazySingleton<EventDatasource>(
    () => EventDatasourceImpl(),
  );

  sl.registerLazySingleton<EventRepository>(
    () => EventRepositoryImpl(sl<EventDatasource>()),
  );

  sl.registerLazySingleton<EventManagementUseCase>(
    () => EventManagementUseCase(sl<EventRepository>()),
  );

  sl.registerLazySingleton<EventBloc>(
    () => EventBloc(sl<EventManagementUseCase>()),
  );

  /// Tickets
  sl.registerLazySingleton<TicketDatasource>(
    () => TicketDatasource(),
  );

  sl.registerLazySingleton<TicketRepository>(
    () => TicketRepositoryImpl(sl<TicketDatasource>()),
  );

  sl.registerLazySingleton<FetchTicketUseCase>(
    () => FetchTicketUseCase(sl<TicketRepository>()),
  );

  sl.registerLazySingleton<UpdateTicketUseCase>(
    () => UpdateTicketUseCase(sl<TicketRepository>()),
  );

  sl.registerLazySingleton<FetchTicketBloc>(
    () => FetchTicketBloc(sl<FetchTicketUseCase>()),
  );

  sl.registerLazySingleton<UpdateTicketBloc>(
    () => UpdateTicketBloc(sl<UpdateTicketUseCase>()),
  );

  /// Order
  sl.registerLazySingleton<OrderDatasource>(
    () => OrderDatasourceImpl(),
  );

  sl.registerLazySingleton<OrderRepository>(
        () => OrderRepositoryImpl(sl<OrderDatasource>()),
  );

  sl.registerLazySingleton<FetchOrdersUseCase>(
        () => FetchOrdersUseCase(sl<OrderRepository>()),
  );

  sl.registerLazySingleton<OrderBloc>(
        () => OrderBloc(sl<FetchOrdersUseCase>()),
  );

}
