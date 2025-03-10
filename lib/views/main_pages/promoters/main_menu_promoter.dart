import 'package:flutter/material.dart';
import 'package:livit/utilities/bars_containers_fields/navigation_bar.dart';
import 'package:livit/views/main_pages/promoters/event_dashboard/event_dashboard.dart';
import 'package:livit/views/main_pages/promoters/location_detail/location_detail.dart';
import 'package:livit/views/main_pages/promoters/promoter_profile.dart';

class MainMenuPromoter extends StatefulWidget {
  const MainMenuPromoter({super.key});

  @override
  State<MainMenuPromoter> createState() => _MainMenuPromoterState();
}

class _MainMenuPromoterState extends State<MainMenuPromoter> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const LocationDetailView(), // Grid of locations
    const EventDashboard(), // Events overview
    const PromoterProfile(), // Profile & settings
  ];

  @override
  Widget build(BuildContext context) {
    debugPrint('🛠️ [MainMenuPromoter] Building');
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: LivitNavigationBar.promoter(
          currentIndex: _selectedIndex,
          onItemTapped: (value) {
            setState(() {
              _selectedIndex = value;
            });
          }),
    );
  }
}
