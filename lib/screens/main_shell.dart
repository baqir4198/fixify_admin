import 'package:fixify_admin/screens/providers_screen.dart';
import 'package:flutter/material.dart';
import '../responsive/responsive_layout.dart';
import '../widgets/side_menu.dart';
import 'bookings_screen.dart';
import 'categories_screen.dart';
import 'customers_screen.dart';
import 'overview_dashboard.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentTabIndex = 0;

  final List<Widget> _pages = [
    const OverviewDashboard(),
    const ProvidersScreen(),
    const CustomersScreen(),
    const BookingsScreen(),
    const CategoriesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(

      mobileBody: Scaffold(
        drawer: Drawer(
          child: SideMenu(
            selectedIndex: _currentTabIndex,
            onTabSelected: (index) {
              setState(() => _currentTabIndex = index);
              Navigator.pop(context); // Close drawer after selection
            },
          ),
        ),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          iconTheme: const IconThemeData(color: Colors.black),
          title: const Text("Fixify Control Room", style: TextStyle(color: Colors.black, fontSize: 16)),
          // Flutter automatically creates the hamburger icon and links it perfectly
          // to the drawer when the drawer is on the SAME Scaffold! No Builder needed.
        ),
        body: _pages[_currentTabIndex],
      ),

      // 🖥️ DESKTOP VIEW (No drawer needed, sidebar is fixed on the left)
      desktopBody: Scaffold(
        body: Row(
          children: [
            SizedBox(
              width: 260,
              child: SideMenu(
                selectedIndex: _currentTabIndex,
                onTabSelected: (index) {
                  setState(() => _currentTabIndex = index);
                },
              ),
            ),
            Expanded(
              child: Container(
                color: const Color(0xFFF8FAFC),
                child: _pages[_currentTabIndex],
              ),
            ),
          ],
        ),
      ),
    );
  }
}