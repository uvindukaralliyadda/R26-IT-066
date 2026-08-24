import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import 'dashboard_screen.dart';
import 'yield_treatment_screen.dart';
import 'crop_recommendation_screen.dart';
import 'iot_fertilization_screen.dart';
import 'disease_detection_screen.dart';
import 'login_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    YieldTreatmentScreen(),
    CropRecommendationScreen(),
    IoTFertilizationScreen(),
    DiseaseDetectionScreen(),
  ];

  final List<NavigationItemData> _navItems = const [
    NavigationItemData(
      title: 'Farm Overview',
      shortTitle: 'Home',
      subtitle: 'Progressive Metrics & Tools',
      icon: Icons.grid_view_outlined,
      selectedIcon: Icons.grid_view_rounded,
    ),
    NavigationItemData(
      title: 'Yield Doctor',
      shortTitle: 'Yield',
      subtitle: 'Yield Loss & Treatment Guide',
      icon: Icons.trending_up_outlined,
      selectedIcon: Icons.trending_up_rounded,
    ),
    NavigationItemData(
      title: 'Smart Crop Guide',
      shortTitle: 'Crops',
      subtitle: 'Best Varieties & Price Forecast',
      icon: Icons.grass_outlined,
      selectedIcon: Icons.grass_rounded,
    ),
    NavigationItemData(
      title: 'Soil & Fertilizer',
      shortTitle: 'Fertilizer',
      subtitle: 'NPK Sensor & Dosage Guide',
      icon: Icons.water_drop_outlined,
      selectedIcon: Icons.water_drop_rounded,
    ),
    NavigationItemData(
      title: 'Leaf Health Scanner',
      shortTitle: 'Health',
      subtitle: 'Instant AI Photo Scan',
      icon: Icons.center_focus_strong_outlined,
      selectedIcon: Icons.center_focus_strong_rounded,
    ),
  ];

  void _onSelectScreen(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _openLoginScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWideScreen = screenWidth >= 900;

    return ValueListenableBuilder<UserModel?>(
      valueListenable: FirebaseService.currentUserNotifier,
      builder: (context, currentUser, child) {
        final user = currentUser ?? UserModel.defaultGuest();

        if (isWideScreen) {
          return Scaffold(
            backgroundColor: AppTheme.bgCanvas,
            body: Row(
              children: [
                // Left Navigation Sidebar
                Container(
                  width: 280,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      right: BorderSide(color: AppTheme.borderLight, width: 1),
                    ),
                  ),
                  child: Column(
                    children: [
                      // App Brand Header
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGreen,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryGreen.withValues(alpha: 0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.eco_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AgriSmart Paddy',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Smart AI Farming Assistant',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const Divider(height: 1, color: AppTheme.borderLight),

                      // User Account Profile Card in Sidebar
                      Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.greenLightBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.greenBorder),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 16,
                              backgroundColor: AppTheme.primaryGreen,
                              child: Icon(Icons.person, color: Colors.white, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.fullName,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryGreenDark,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    user.email,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppTheme.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: _openLoginScreen,
                              icon: const Icon(Icons.login_rounded, size: 18, color: AppTheme.primaryGreen),
                              tooltip: 'Sign In / Account',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'FARMING SERVICES',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textSecondary,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),

                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: _navItems.length,
                          itemBuilder: (context, index) {
                            final item = _navItems[index];
                            final isSelected = _selectedIndex == index;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Material(
                                color: isSelected
                                    ? AppTheme.greenLightBg
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => _onSelectScreen(index),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: isSelected
                                          ? Border.all(
                                              color: AppTheme.greenBorder, width: 1)
                                          : null,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isSelected
                                              ? item.selectedIcon
                                              : item.icon,
                                          color: isSelected
                                              ? AppTheme.primaryGreen
                                              : AppTheme.textSecondary,
                                          size: 22,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.title,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: isSelected
                                                      ? FontWeight.bold
                                                      : FontWeight.w600,
                                                  color: isSelected
                                                      ? AppTheme.primaryGreenDark
                                                      : AppTheme.textPrimary,
                                                ),
                                              ),
                                              Text(
                                                item.subtitle,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: isSelected
                                                      ? AppTheme.primaryGreen
                                                          .withValues(alpha: 0.8)
                                                      : AppTheme.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Bottom System Status
                      Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.bgCanvas,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.borderLight),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.cloud_done_rounded,
                              color: AppTheme.primaryGreen,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Firebase Realtime DB',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Credentials & Data Synced',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.primaryGreenDark,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: _screens,
                  ),
                ),
              ],
            ),
          );
        } else {
          // Mobile / Narrow Screen Layout
          return Scaffold(
            backgroundColor: AppTheme.bgCanvas,
            appBar: AppBar(
              title: Text(_navItems[_selectedIndex].title),
              elevation: 0,
              actions: [
                IconButton(
                  onPressed: _openLoginScreen,
                  icon: const Icon(Icons.account_circle, color: AppTheme.primaryGreen),
                  tooltip: 'Sign In',
                ),
                const SizedBox(width: 8),
              ],
            ),
            drawer: Drawer(
              backgroundColor: Colors.white,
              child: Column(
                children: [
                  UserAccountsDrawerHeader(
                    decoration: const BoxDecoration(color: AppTheme.primaryGreen),
                    currentAccountPicture: const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.eco_rounded,
                          color: AppTheme.primaryGreen, size: 28),
                    ),
                    accountName: Text(
                      user.fullName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    accountEmail: Text(user.email),
                  ),
                  ListTile(
                    leading: const Icon(Icons.login_rounded, color: AppTheme.primaryGreen),
                    title: const Text('Sign In / Register Account'),
                    subtitle: const Text('Sync credentials with Firebase Cloud'),
                    onTap: () {
                      Navigator.pop(context);
                      _openLoginScreen();
                    },
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _navItems.length,
                      itemBuilder: (context, index) {
                        final item = _navItems[index];
                        final isSelected = _selectedIndex == index;
                        return ListTile(
                          leading: Icon(
                            isSelected ? item.selectedIcon : item.icon,
                            color: isSelected
                                ? AppTheme.primaryGreen
                                : AppTheme.textSecondary,
                          ),
                          title: Text(
                            item.title,
                            style: TextStyle(
                              fontWeight:
                                  isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected
                                  ? AppTheme.primaryGreen
                                  : AppTheme.textPrimary,
                            ),
                          ),
                          subtitle: Text(item.subtitle,
                              style: const TextStyle(fontSize: 11)),
                          selected: isSelected,
                          onTap: () {
                            Navigator.pop(context);
                            _onSelectScreen(index);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            body: IndexedStack(
              index: _selectedIndex,
              children: _screens,
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(_navItems.length, (index) {
                      final item = _navItems[index];
                      final isSelected = _selectedIndex == index;
                      return Expanded(
                        child: InkWell(
                          onTap: () => _onSelectScreen(index),
                          borderRadius: BorderRadius.circular(16),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.greenLightBg
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              border: isSelected
                                  ? Border.all(color: AppTheme.greenBorder, width: 1)
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isSelected ? item.selectedIcon : item.icon,
                                  size: 20,
                                  color: isSelected
                                      ? AppTheme.primaryGreen
                                      : AppTheme.textSecondary,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.shortTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? AppTheme.primaryGreenDark
                                        : AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}

class NavigationItemData {
  final String title;
  final String shortTitle;
  final String subtitle;
  final IconData icon;
  final IconData selectedIcon;

  const NavigationItemData({
    required this.title,
    required this.shortTitle,
    required this.subtitle,
    required this.icon,
    required this.selectedIcon,
  });
}
