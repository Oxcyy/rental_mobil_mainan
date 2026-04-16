import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_store.dart';
import 'cars_screen.dart';
import 'rentals_screen.dart';
import 'dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const CarsScreen(),
    const RentalsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppStore>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : Colors.white;
    final borderColor = isDark ? Colors.white : Colors.black;
    final iconColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(top: BorderSide(color: borderColor, width: 4)), 
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: bgColor,
            indicatorColor: const Color(0xFFEA80FC), 
            indicatorShape: RoundedRectangleBorder(
              side: BorderSide(color: borderColor, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return TextStyle(fontWeight: FontWeight.w900, color: iconColor, fontSize: 12, letterSpacing: 1.0);
              }
              return TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white54 : Colors.black54, fontSize: 11);
            }),
          ),
          child: NavigationBar(
            height: 65,
            elevation: 0,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) =>
                setState(() => _selectedIndex = index),
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined, color: iconColor),
                selectedIcon: const Icon(Icons.dashboard, color: Colors.black),
                label: 'DASHBOARD',
              ),
              NavigationDestination(
                icon: Icon(Icons.directions_car_outlined, color: iconColor),
                selectedIcon: const Icon(Icons.directions_car, color: Colors.black),
                label: 'MOBIL',
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined, color: iconColor),
                selectedIcon: const Icon(Icons.receipt_long, color: Colors.black),
                label: 'SEWA',
              ),
            ],
          ),
        ),
      ),
    );
  }
}