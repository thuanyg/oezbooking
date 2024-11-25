import 'package:flutter/material.dart';
import 'package:oezbooking/core/apps/app_colors.dart';
import 'package:oezbooking/core/apps/app_styles.dart';
import 'package:oezbooking/core/utils/dialogs.dart';
import 'package:oezbooking/core/utils/image_helper.dart';
import 'package:oezbooking/features/login/presentation/page/login_page.dart';
import 'package:oezbooking/features/login/presentation/widgets/main_button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ImageHelper.loadSvgImage(
                      "assets/images/img_welcome.svg",
                      height: 250,
                      width: 250,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "EventMaster",
                      style: AppStyle.heading1.copyWith(color: Colors.black87),
                    ),
                    Text(
                      textAlign: TextAlign.center,
                      "Efficiently manage personal events with ease",
                      style: AppStyle.heading2.copyWith(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            MainElevatedButton(
              text: "Get started",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: () {
                  DialogUtils.showWarningDialog(
                      context: context,
                      title:
                          "Please contact hotline 19001009 to register for event organizer!",
                      onClickOutSide: () {});
                },
                child: const Text(
                  "Create an account",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
