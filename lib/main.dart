import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/constants.dart';
import 'utils/theme.dart';
import 'providers/appointment_provider.dart';
import 'providers/queue_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/booking_screen.dart';
import 'screens/queue_status_screen.dart';
import 'screens/appointment_list_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/search_filter_screen.dart';
import 'screens/login_screen.dart';
import 'database/sync_service.dart';
import 'widgets/connectivity_banner.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartAppointmentApp());
}

class SmartAppointmentApp extends StatelessWidget {
  const SmartAppointmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
        ChangeNotifierProvider(create: (_) => QueueProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) {
          final syncService = SyncService();
          syncService.initialize();
          return syncService;
        }),
      ],
      child: MaterialApp(
        title: 'Smart Appointment',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.isAuthenticated) {
      return const LoginScreen();
    }

    return const MainNavigation();
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentProvider>().loadAppointments();
      context.read<QueueProvider>().loadTodayQueue();
      if (context.read<AuthProvider>().isDoctor) {
        context.read<AdminProvider>().loadDashboard();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDoctor = context.watch<AuthProvider>().isDoctor;

    final List<Widget> screens = isDoctor
        ? const [
            AdminDashboardScreen(),
            QueueStatusScreen(),
          ]
        : const [
            BookingScreen(),
            QueueStatusScreen(),
            AppointmentListScreen(),
          ];

    // Reset index if role changes and index is out of bounds
    if (_currentIndex >= screens.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      body: Column(
        children: [
          const ConnectivityBanner(),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: screens,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: isDoctor
              ? const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.admin_panel_settings_outlined),
                    activeIcon: Icon(Icons.admin_panel_settings_rounded),
                    label: 'Dashboard',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.queue_rounded),
                    activeIcon: Icon(Icons.queue_rounded),
                    label: 'Queue',
                  ),
                ]
              : const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.add_circle_outline_rounded),
                    activeIcon: Icon(Icons.add_circle_rounded),
                    label: 'Book',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.queue_rounded),
                    activeIcon: Icon(Icons.queue_rounded),
                    label: 'Queue',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.list_alt_rounded),
                    activeIcon: Icon(Icons.list_alt_rounded),
                    label: 'My Appts',
                  ),
                ],
        ),
      ),
      floatingActionButton: isDoctor
          ? FloatingActionButton.small(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchFilterScreen()));
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.search_rounded, color: Colors.white),
            )
          : null,
    );
  }
}
