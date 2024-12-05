import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:oezbooking/core/utils/image_helper.dart';
import 'package:oezbooking/core/utils/storage.dart';
import 'package:oezbooking/features/home/presentation/page/home_page.dart';
import 'package:oezbooking/features/login/data/model/organizer.dart';
import 'package:oezbooking/features/login/presentation/bloc/login_bloc.dart';
import 'package:oezbooking/features/login/presentation/page/login_page.dart';
import 'package:oezbooking/features/welcome/presentation/page/welcome_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    handleNavigate();
  }

  Future<void> handleNavigate() async {

    final isFirstRun = await PreferencesUtils.getBool("isFirstRun");

    if(isFirstRun == null || isFirstRun){
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const WelcomePage(),
        ),
            (route) => false,
      );
      return;
    }

    final loginBloc = BlocProvider.of<LoginBloc>(context);
    final userID = await PreferencesUtils.getString(loginSessionKey);
    if (userID != null) {
      final orgDoc = await FirebaseFirestore.instance
          .collection("organizers")
          .doc(userID)
          .get();
      if (orgDoc.exists) {
        loginBloc.organizer = Organizer.fromJson(orgDoc.data()!);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
          (route) => false,
        );
        return;
      }
    }
    // Default navigate
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ImageHelper.loadAssetImage(
              'assets/images/img_logo.png',
              height: 40,
              tintColor: Colors.white70,
            ),
            const SizedBox(height: 10),
            Lottie.asset(
              "assets/animations/loading.json",
              width: 80,
              fit: BoxFit.cover,
            )
          ],
        ),
      ),
    );
  }
}
