import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:siiadmision/admin_aspirantes.dart';
import 'package:siiadmision/admision_documents.dart';
import 'package:siiadmision/admision_status_documents.dart';
import 'package:siiadmision/admision_upload_documents.dart';
import 'package:siiadmision/login_screen.dart';
import 'package:siiadmision/admision_screen.dart';
import 'package:siiadmision/admision_payment_screen.dart';
import 'package:siiadmision/admision_payment_status.dart';
import 'package:siiadmision/theme.dart';
import 'package:siiadmision/side_navigation.dart';
import 'package:siiadmision/alumno_inicio.dart';
import 'package:siiadmision/public_layout.dart';
import 'package:siiadmision/admin_inicio.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() {
  setUrlStrategy(PathUrlStrategy());
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => PublicLayout(child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/admision',
          builder: (context, state) => const AdmissionScreen(),
        ),
        GoRoute(
          path: '/admision/pagoexamen',
          builder: (context, state) => const PaymentScreen(),
        ),
        GoRoute(
          path: '/admision/pagoexamen/status',
          builder: (context, state) => const PaymentStatusScreen(),
        ),
        GoRoute(
          path: '/admision/documentos',
          builder: (context, state) => const DocumentosScreen(),
        ),
        GoRoute(
          path: '/admision/documentos/subida',
          builder: (context, state) => const UploadDocumentsScreen(),
        ),
        GoRoute(
          path: '/admision/documentos/estado',
          builder: (context, state) => const DocumentosStatusScreen(),
        ),
      ],
    ),

    // Rutas privadas fuera del shell público
    GoRoute(
      path: '/alumno/inicio',
      builder: (context, state) => const DashboardAlumnoScreen(),
    ),
    GoRoute(
      path: '/admin/inicio',
      builder: (context, state) => const DashboardAdminScreen(),
    ),
    GoRoute(
      path: '/admin/aspirantes',
      builder: (context, state) => const AspirantesAdminScreen(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final materialTheme = MaterialTheme(ThemeData().textTheme);

    return MaterialApp.router(
      title: 'SII - UTH Admisión',
      theme: materialTheme.light(),
      darkTheme: materialTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}

class ShellLayout extends StatelessWidget {
  final Widget child;
  final int selectedIndex;

  const ShellLayout({
    super.key,
    required this.child,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SideNavigation(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              switch (index) {
                case 0:
                  context.go('/');
                  break;
                case 1:
                  context.go('/admision');
                  break;
                case 2:
                  context.go('/uth');
                  break;
                case 3:
                  context.go('/settings');
                  break;
              }
            },
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
