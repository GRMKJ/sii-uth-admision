import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:root_jailbreak_detector/root_jailbreak_detector.dart';
import 'package:siiadmision/admin/admin_aspirantes.dart';
import 'package:siiadmision/admision/admision_documents.dart';
import 'package:siiadmision/admision/admision_status_documents.dart';
import 'package:siiadmision/admision/admision_upload_documents.dart';
import 'package:siiadmision/login/login_screen.dart';
import 'package:siiadmision/login/forgot_password_screen.dart';
import 'package:siiadmision/admision/admision_screen.dart';
import 'package:siiadmision/admision/admision_payment_screen.dart';
import 'package:siiadmision/admision/admision_payment_status.dart';
import 'package:siiadmision/login/reset_password_screen.dart';
import 'package:siiadmision/theme/theme.dart';
import 'package:siiadmision/widgets/sidebar.dart';
import 'package:siiadmision/alumno/alumno_inicio.dart';
import 'package:siiadmision/layout/public_layout.dart';
import 'package:siiadmision/admin/admin_inicio.dart';
import 'package:siiadmision/admin/admin_aspirantes_detalles.dart';
import 'package:siiadmision/admin/admin_finanzas.dart';
import 'package:siiadmision/config/session.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'config/platform_info.dart';

void main() async {
  setUrlStrategy(PathUrlStrategy());
  WidgetsFlutterBinding.ensureInitialized();
  await Session().load(); 

  // Only run jailbreak detection on real mobile platforms (Android/iOS).
  // The plugin is not implemented on web/desktop and will throw
  // MissingPluginException if invoked there.
  final bool isMobile = !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  if (isMobile) {
    try {
      final bool? jailbroken = await RootJailbreakDetector().isRooted();
      if (jailbroken == true) {
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      }
    } on MissingPluginException catch (e) {
      debugPrint('Root/jailbreak plugin missing: $e');
    } catch (e, st) {
      debugPrint('Root/jailbreak detection failed: $e\n$st');
    }
  } else {
    debugPrint('Skipping jailbreak detection: not running on Android/iOS. Platform version: ${PlatformInfo.version}');
  }

  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final session = Session();

    // Bloquear acceso a rutas de alumno si no es alumno
    if (state.uri.toString().startsWith('/alumno') && !session.isAlumno) {
      return '/';
    }

    // Bloquear acceso a rutas de admin si no es admin
    if (state.uri.toString().startsWith('/admin') && !session.isAdmin) {
      return '/';
    }

    return null; // acceso permitido
  },
  routes: [
    // Public layout
    ShellRoute( 
      builder: (context, state, child) => PublicLayout(
        key: ValueKey(state.uri.path.isNotEmpty ? state.uri.path : '/'),
        location: state.uri.path.isNotEmpty ? state.uri.path : '/',
        child: child,
      ),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/forgot',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(path: '/admision', builder: (_, __) => const AdmissionScreen()),
        GoRoute(path: '/admision/pagoexamen', builder: (_, __) => const PaymentScreen()),
        GoRoute(path: '/admision/pagoexamen/status', builder: (_, __) => const PaymentStatusScreen()),
        GoRoute(path: '/admision/documentos', builder: (_, __) => const DocumentosScreen()),
        GoRoute(path: '/admision/documentos/subida', builder: (_, __) => const UploadDocumentsScreen()),
        GoRoute(path: '/admision/documentos/estado', builder: (_, __) => const DocumentosStatusScreen()),
      ],
    ),
    GoRoute(
      path: '/reset',
      name: 'reset',
      builder: (context, state) => _ResetRouteWrapper(state: state),
    ),

    // Rutas privadas de alumno
    GoRoute(
      path: '/alumno/inicio',
      builder: (context, state) => const DashboardAlumnoScreen(),
    ),

    // Rutas privadas de admin
    GoRoute(path: '/admin/inicio', builder: (_, __) => const DashboardAdminScreen()),
    GoRoute(path: '/admin/aspirantes', builder: (_, __) => const AspirantesAdminScreen()),
    GoRoute(path: '/admin/finanzas', builder: (_, __) => const AdminFinanzasScreen()),
    GoRoute(path: '/admin/aspirante/:referencia/pago', builder: (context, state) => PagoDetalleScreen(referencia: state.pathParameters['referencia']!)),
    GoRoute(path: '/admin/aspirante/:referencia/documentos', builder: (context, state) => VerDocumentosScreen(folio: state.pathParameters['referencia']!)),
    GoRoute(path: '/admin/aspirante/:referencia/inscripcion', builder: (context, state) => AutorizarInscripcionScreen(folio: state.pathParameters['referencia']!)),
  ],
);

class _ResetRouteWrapper extends StatelessWidget {
  final GoRouterState state;

  const _ResetRouteWrapper({
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final token = state.uri.queryParameters['token'] ?? '';
    final email = state.uri.queryParameters['email'] ?? '';
    final role = state.uri.queryParameters['role'] ?? 'desconocido';

    final location = state.uri.path.isNotEmpty ? state.uri.path : '/';
    final child = (token.isEmpty || email.isEmpty)
        ? const Center(child: Text('Link de restablecimiento inválido o incompleto'))
        : ResetPasswordScreen(email: email, token: token, role: role);

    return PublicLayout(
      key: ValueKey(location),
      location: location,
      child: child,
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme baseText = ThemeData(useMaterial3: true).textTheme;
    final materialTheme = MaterialTheme(baseText);
    final ThemeData lightTheme = materialTheme.light();
    final ThemeData darkTheme  = materialTheme.dark();

    return MaterialApp.router(
      routerConfig: _router, // si usas go_router
      debugShowCheckedModeBanner: false,
      title: 'SII Admisión',
      theme: lightTheme,   
      darkTheme: darkTheme,
      locale: const Locale('es', 'MX'), // 👈 aquí configuras español
      supportedLocales: const [
        Locale('es', 'MX'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
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
