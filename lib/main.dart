import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:root_jailbreak_detector/root_jailbreak_detector.dart';
import 'package:siiadmision/admin/admin_aspirantes.dart';
import 'package:siiadmision/admision/admision_documents.dart';
import 'package:siiadmision/admision/admision_status_documents.dart';
import 'package:siiadmision/admision/admision_upload_documents.dart';
import 'package:siiadmision/login/login_screen.dart';
import 'package:siiadmision/login/forgot_password_screen.dart';
import 'package:siiadmision/admision/admision_screen.dart';
import 'package:siiadmision/admision/admision_bachillerato.dart';
import 'package:siiadmision/admision/admision_payment_screen.dart';
import 'package:siiadmision/admision/admision_payment_status.dart';
import 'package:siiadmision/login/reset_password_screen.dart';
import 'package:siiadmision/theme/theme.dart';
import 'package:siiadmision/widgets/sidebar.dart';
import 'package:siiadmision/widgets/connectivity_banner.dart';
import 'package:siiadmision/alumno/alumno_inicio.dart';
import 'package:siiadmision/layout/public_layout.dart';
import 'package:siiadmision/admin/admin_inicio.dart';
import 'package:siiadmision/admin/admin_aspirantes_detalles.dart';
import 'package:siiadmision/admin/admin_finanzas.dart';
import 'package:siiadmision/config/api_client.dart';
import 'package:siiadmision/config/session.dart';
import 'package:siiadmision/config/theme_controller.dart';
import 'package:siiadmision/config/startup_notification_dispatcher.dart';
import 'package:siiadmision/settings/settings_screen.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'config/platform_info.dart';
import 'admision/models/bachillerato_form_data.dart';
import 'firebase_options.dart';

late GoRouter _router;
const String _webPushKey = String.fromEnvironment('FIREBASE_WEB_PUSH_KEY', defaultValue: '');
final GlobalKey<ScaffoldMessengerState> _rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('FCM background message: ${message.messageId}');
}

void main() async {
  setUrlStrategy(PathUrlStrategy());
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _configureFirebaseMessaging();
  await Session().load(); 
  await themeController.loadThemeMode();

  final initialLocation = await _resolveInitialLocation();
  _router = _buildRouter(initialLocation);

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

  runApp(MyApp(themeController: themeController));
}

Future<void> _configureFirebaseMessaging() async {
  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  final messaging = FirebaseMessaging.instance;
  final settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    announcement: false,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
  );

  if (settings.authorizationStatus == AuthorizationStatus.denied) {
    debugPrint('Push notifications permission denied.');
  } else {
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  String? fcmToken;
  if (kIsWeb) {
    if (_webPushKey.isNotEmpty) {
      fcmToken = await messaging.getToken(vapidKey: _webPushKey);
    } else {
      debugPrint('Set FIREBASE_WEB_PUSH_KEY to receive web push tokens.');
    }
  } else {
    fcmToken = await messaging.getToken();
  }

  if (fcmToken != null && fcmToken.isNotEmpty) {
    await StartupNotificationDispatcher.registerFcmToken(fcmToken);
  }

  FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
}

void _handleForegroundMessage(RemoteMessage message) {
  final notification = message.notification;
  final title = notification?.title ?? message.data['title'] ?? 'Nueva notificación';
  final body = notification?.body ?? message.data['body'] ?? '';
  final deeplink = message.data['deeplink'] as String?;

  debugPrint('Push received: ${notification?.title ?? message.messageId}');

  final messenger = _rootScaffoldMessengerKey.currentState;
  if (messenger == null) {
    return;
  }

  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 6),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          if (body.isNotEmpty)
            Text(body),
        ],
      ),
      action: deeplink != null && deeplink.isNotEmpty
          ? SnackBarAction(
              label: 'Ver',
              onPressed: () => _navigateFromNotification(deeplink),
            )
          : null,
    ),
  );
}

void _navigateFromNotification(String deeplink) {
  final messenger = _rootScaffoldMessengerKey.currentState;
  messenger?.clearSnackBars();

  final uri = Uri.tryParse(deeplink);
  if (uri == null) {
    return;
  }

  if (uri.scheme == 'siiadmision') {
    final host = uri.host.isNotEmpty ? '/${uri.host}' : '';
    final path = uri.path.isNotEmpty ? uri.path : '';
    final fullPath = '$host$path';

    if (fullPath.isNotEmpty) {
      _router.go(fullPath);
    }
    return;
  }

  if (uri.hasAuthority || deeplink.startsWith('/')) {
    _router.go(uri.path.isEmpty ? '/' : uri.toString());
  }
}

GoRouter _buildRouter(String initialLocation) {
  return GoRouter(
  initialLocation: initialLocation,
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
        GoRoute(path: '/admision/bachillerato', builder: (_, __) => const BachilleratoScreen()),
        GoRoute(
          path: '/admision/pagoexamen',
          builder: (_, state) {
            final extra = state.extra;
            return PaymentScreen(
              formData: extra is BachilleratoFormData ? extra : null,
              sessionIdFromQuery: state.uri.queryParameters['session_id'],
              statusFromQuery: state.uri.queryParameters['status'],
            );
          },
        ),
        GoRoute(path: '/admision/pagoexamen/status', builder: (_, __) => const PaymentStatusScreen()),
        GoRoute(path: '/admision/documentos', builder: (_, __) => const DocumentosScreen()),
        GoRoute(
          path: '/admision/documentos/subida',
          builder: (_, state) => UploadDocumentsScreen(
            sessionIdFromQuery: state.uri.queryParameters['session_id'],
            statusFromQuery: state.uri.queryParameters['status'],
          ),
        ),
        GoRoute(path: '/admision/documentos/estado', builder: (_, __) => const DocumentosStatusScreen()),
        GoRoute(path: '/ajustes', builder: (_, __) => const SettingsScreen()),
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
    GoRoute(
      path: '/alumno/ajustes',
      builder: (context, state) => const AlumnoSettingsScreen(),
    ),

    // Rutas privadas de admin
    GoRoute(path: '/admin/inicio', builder: (_, __) => const DashboardAdminScreen()),
    GoRoute(path: '/admin/aspirantes', builder: (_, __) => const AspirantesAdminScreen()),
    GoRoute(path: '/admin/finanzas', builder: (_, __) => const AdminFinanzasScreen()),
    GoRoute(path: '/admin/ajustes', builder: (_, __) => const AdminSettingsScreen()),
    GoRoute(path: '/admin/aspirante/:referencia/pago', builder: (context, state) => PagoDetalleScreen(referencia: state.pathParameters['referencia']!)),
    GoRoute(path: '/admin/aspirante/:referencia/documentos', builder: (context, state) => VerDocumentosScreen(folio: state.pathParameters['referencia']!)),
    GoRoute(path: '/admin/aspirante/:referencia/inscripcion', builder: (context, state) => AutorizarInscripcionScreen(folio: state.pathParameters['referencia']!)),
  ],
);
}

Future<String> _resolveInitialLocation() async {
  const storage = FlutterSecureStorage();
  final token = await storage.read(key: 'auth_token');
  final session = Session();

  if (token == null || token.isEmpty) {
    return '/';
  }

  if (session.isAdmin) {
    return '/admin/inicio';
  }

  if (session.isAlumno) {
    return '/alumno/inicio';
  }

  if (session.isAspirante) {
    try {
      final response = await ApiClient.getJson('/aspirantes/progress', token: token);
      if (response['success'] == true) {
        final step = _extractProgressStep(response);
        if (step != null) {
          return _routeForAspiranteStep(step);
        }
      }
    } catch (_) {
      // Silently fall back to default admission path
    }
    return '/admision';
  }

  return '/';
}

int? _extractProgressStep(Map<String, dynamic> stepResponse) {
  dynamic rawStep;
  if (stepResponse.containsKey('step')) {
    rawStep = stepResponse['step'];
  } else if (stepResponse['data'] is Map && (stepResponse['data'] as Map).containsKey('step')) {
    rawStep = (stepResponse['data'] as Map)['step'];
  }

  if (rawStep == null) {
    return null;
  }

  if (rawStep is int) {
    return rawStep;
  }

  if (rawStep is String) {
    return int.tryParse(rawStep);
  }

  return null;
}

String _routeForAspiranteStep(int step) {
  switch (step) {
    case 1:
      return '/admision';
    case 2:
      return '/admision/bachillerato';
    case 3:
      return '/admision/pagoexamen';
    case 4:
      return '/admision/pagoexamen/status';
    case 5:
      return '/admision/documentos/subida';
    case 6:
      return '/admision/documentos/estado';
    case 7:
      return '/alumno/inicio';
    default:
      return '/';
  }
}

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
  final ThemeController themeController;

  const MyApp({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    final TextTheme baseText = ThemeData(useMaterial3: true).textTheme;
    final materialTheme = MaterialTheme(baseText);
    final ThemeData lightTheme = materialTheme.light();
    final ThemeData darkTheme  = materialTheme.dark();

    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        return MaterialApp.router(
          scaffoldMessengerKey: _rootScaffoldMessengerKey,
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
          title: 'SII Admisión',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeController.mode,
          locale: const Locale('es', 'MX'),
          supportedLocales: const [
            Locale('es', 'MX'),
            Locale('en', 'US'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) => ConnectivityBanner(
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
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
    final useRail = useNavigationRailLayout(context);

    void handleNavigation(int index) {
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
          context.go('/ajustes');
          break;
      }
    }

    return Scaffold(
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          final hasRailSpace = constraints.maxWidth >= kNavigationRailBreakpoint;
          return hasRailSpace
              ? const SizedBox.shrink()
              : NavigationBar(
                  selectedIndex: selectedIndex,
                  destinations: publicNavigationDestinations,
                  onDestinationSelected: handleNavigation,
                );
        },
      ),
      body: useRail
          ? Row(
              children: [
                SizedBox(
                  width: 96,
                  child: SideNavigation(
                    selectedIndex: selectedIndex,
                    onDestinationSelected: handleNavigation,
                  ),
                ),
                Expanded(child: child),
              ],
            )
          : child,
    );
  }
}
