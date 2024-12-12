
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oezbooking/core/apps/app_colors.dart';
import 'package:oezbooking/core/services/firebase_cloud_message.dart';
import 'package:oezbooking/core/services/notification_service.dart';
import 'package:oezbooking/features/events/presentation/bloc/event_bloc.dart';
import 'package:oezbooking/features/login/presentation/bloc/login_bloc.dart';
import 'package:oezbooking/features/orders/presentation/bloc/order_bloc.dart';
import 'package:oezbooking/features/splash/splash_page.dart';
import 'package:oezbooking/features/ticket_scanner/presentation/bloc/fetch_ticket_bloc.dart';
import 'package:oezbooking/features/ticket_scanner/presentation/bloc/update_ticket_bloc.dart';
import 'package:oezbooking/firebase_options.dart';
import 'package:oezbooking/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  initServiceLocator();
  await NotificationService.init();
  final fcm = FirebaseCloudMessage();
  await fcm.initialize();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<LoginBloc>()),
        BlocProvider(create: (_) => sl<EventBloc>()),
        BlocProvider(create: (_) => sl<FetchTicketBloc>()),
        BlocProvider(create: (_) => sl<UpdateTicketBloc>()),
        BlocProvider(create: (_) => sl<OrderBloc>()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Master',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.backgroundColor,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashPage(),
    );
  }
}
