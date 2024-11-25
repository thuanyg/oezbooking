import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:oezbooking/core/apps/app_colors.dart';
import 'package:oezbooking/core/apps/app_styles.dart';
import 'package:oezbooking/core/utils/image_helper.dart';
import 'package:oezbooking/features/events/presentation/page/event_screen.dart';
import 'package:oezbooking/features/orders/presentation/page/orders_page.dart';
import 'package:oezbooking/features/ticket_scanner/presentation/page/ticket_scanner_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController pageController;
  ValueNotifier<int> currentIndex = ValueNotifier(0);
  List<String> listImageSliders = [
    "https://www.cheggindia.com/wp-content/uploads/2024/08/event-management-course.png",
    "https://techstory.in/wp-content/uploads/2023/03/EM.jpg",
    "https://www.whistlingwoods.net/wp-content/uploads/2023/04/wwi_blog-posts_Career-In-Event-Management-.jpg",
    "https://img.freepik.com/free-psd/dj-party-woman-with-headphones-banner_23-2148623858.jpg?semt=ais_hybrid"
  ];

  @override
  void initState() {
    super.initState();
    pageController = PageController(
      initialPage: 0,
      keepPage: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: pageController,
          onPageChanged: (index) {
            currentIndex.value = index;
          },
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Top Banner
                  const SizedBox(height: 20),
                  CarouselSlider.builder(
                    itemCount: listImageSliders.length,
                    options: CarouselOptions(
                      height: 120,
                      aspectRatio: 16 / 9,
                      viewportFraction: 0.95,
                      initialPage: 0,
                      enableInfiniteScroll: true,
                      reverse: false,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 3),
                      autoPlayAnimationDuration:
                          const Duration(milliseconds: 800),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enlargeCenterPage: true,
                      enlargeFactor: 0.3,
                      onPageChanged: (index, reason) {},
                      scrollDirection: Axis.horizontal,
                    ),
                    itemBuilder: (BuildContext context, int itemIndex,
                        int pageViewIndex) {
                      return ImageHelper.loadNetworkImage(
                        listImageSliders[itemIndex],
                        fit: BoxFit.cover,
                        radius: BorderRadius.circular(8),
                        height: 100,
                        width: double.infinity,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: FractionalOffset.centerLeft,
                    child: Text(
                      "Verify QR Code",
                      style: AppStyle.heading2.copyWith(fontSize: 17),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.qr_code_2,
                          color: Colors.white70,
                          size: 36,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Ticket Scan",
                          style: AppStyle.heading2.copyWith(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const TicketScannerPage(),
                            ));
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.white54),
                            ),
                            child: const Text(
                              "Scan",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: FractionalOffset.centerLeft,
                    child: Text(
                      "Services",
                      style: AppStyle.heading2.copyWith(fontSize: 17),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: AppColors.drawerColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 3,
                      mainAxisSpacing: 3.0,
                      crossAxisSpacing: 16.0,
                      children: [
                        _buildMenuItem(
                          icon: Icons.shopping_bag,
                          label: 'Orders',
                          notifications: 0,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrdersPage(),
                              ),
                            );
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.star,
                          label: 'Reviews',
                          notifications: 0,
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          icon: Icons.monetization_on_outlined,
                          label: 'Revenue',
                          notifications: 0,
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          icon: Icons.headset_mic,
                          label: 'Help Center',
                          notifications: 0,
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          icon: Icons.group,
                          label: 'Management',
                          notifications: 1,
                          onTap: () {},
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const EventScreen(),
          ],
        ),
      ),
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: currentIndex,
        builder: (context, value, child) {
          return BottomNavigationBar(
            backgroundColor: AppColors.drawerColor,
            onTap: (index) {
              currentIndex.value = index;
              pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            selectedItemColor: AppColors.primaryColor,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.event),
                label: 'Events',
              ),
            ],
            currentIndex: value,
          );
        },
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required int notifications,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.black54),
              ),
            ),
            if (notifications > 0)
              Positioned(
                right: -5,
                top: -5,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    notifications.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
