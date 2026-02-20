import 'package:cartify/features/profile/views/profile_screen.dart';
import 'package:flutter/material.dart';

import '../products/views/product_list_screen.dart';
import '../carts/views/cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _screens = const [
    ProductListScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    const accent = Color(0xFF8B7355);
    final unselected = isDark
        ? Colors.white.withOpacity(0.35)
        : const Color(0xFF1A1A1A).withOpacity(0.35);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F6F2),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withOpacity(isDark ? 0.35 : 0.08),
        elevation: 8,
        indicatorColor: accent.withOpacity(0.12),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined, color: unselected),
            selectedIcon: Icon(Icons.storefront_rounded, color: accent),
            label: 'Shop',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined, color: unselected),
            selectedIcon: Icon(Icons.shopping_bag_rounded, color: accent),
            label: 'Cart',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded, color: unselected),
            selectedIcon: Icon(Icons.person_rounded, color: accent),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}