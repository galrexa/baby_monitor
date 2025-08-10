import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/shared/models/app_user.dart';
import 'features/parent/screens/parent_dashboard.dart';
import 'features/caretaker/screens/caretaker_dashboard.dart';
import 'features/admin/screens/admin_dashboard.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baby Monitor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2196F3)),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Listen for auth state changes
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (previous?.isAuthenticated != next.isAuthenticated) {
        if (next.isAuthenticated) {
          // Successfully logged in/registered - navigate to dashboard
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => DashboardScreen(user: next.user!),
            ),
            (route) => false,
          );
        }
      }
    });

    if (authState.isAuthenticated) {
      return DashboardScreen(user: authState.user!);
    } else {
      return const LoginScreen();
    }
  }
}

class DashboardScreen extends StatelessWidget {
  final AppUser user;

  const DashboardScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Route to appropriate dashboard based on user role
    switch (user.role) {
      case UserRole.parent:
        return ParentDashboard(user: user);
      case UserRole.caretaker:
        return CaretakerDashboard(user: user);
      case UserRole.admin:
        return AdminDashboard(user: user);
    }
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.parent:
        return const Color(0xFF2196F3);
      case UserRole.caretaker:
        return const Color(0xFF4CAF50);
      case UserRole.admin:
        return const Color(0xFF9C27B0);
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.parent:
        return Icons.family_restroom;
      case UserRole.caretaker:
        return Icons.baby_changing_station;
      case UserRole.admin:
        return Icons.admin_panel_settings;
    }
  }

  String _getRoleFeatures(UserRole role) {
    switch (role) {
      case UserRole.parent:
        return 'Anda dapat:\n• Memicu alarm untuk memanggil pengasuh\n• Melihat status kamar bayi\n• Mengelola pengaturan alarm';
      case UserRole.caretaker:
        return 'Anda dapat:\n• Menerima notifikasi alarm\n• Merespon panggilan orangtua\n• Monitoring multiple kamar';
      case UserRole.admin:
        return 'Anda dapat:\n• Mengelola pengguna\n• Mengatur kamar dan assignment\n• Melihat statistik sistem';
    }
  }
}
