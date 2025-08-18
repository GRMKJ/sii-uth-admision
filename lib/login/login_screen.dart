import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:siiadmision/config/api_client.dart';
import 'package:siiadmision/config/session.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final storage = FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final contentWidth = screenWidth.clamp(320.0, 1280.0);

            return Column(
              children: [
                const SizedBox(height: 24),
                Expanded(
                  child: Center(
                    child: Container(
                      width: contentWidth,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: colors.shadow.withOpacity(0.1),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: screenWidth < 640
                          ? _buildLoginColumn(context)
                          : _buildLoginRow(context),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoginRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: Image.asset(
              'assets/uth_building.jpg',
              fit: BoxFit.cover,
              height: double.infinity,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _buildLoginForm(context),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginColumn(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          child: Image.asset(
            'assets/uth_building.jpg',
            fit: BoxFit.cover,
            height: 180,
            width: double.infinity,
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _buildLoginForm(context),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Inicio de Sesión',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Bienvenido Aspirante / Alumno / Administrativo',
          style: textTheme.labelMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _usernameController,
          decoration: const InputDecoration(
            labelText: 'Usuario',
            prefixIcon: Icon(Icons.person_outline),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Contraseña',
            prefixIcon: Icon(Icons.lock_outline),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: const Text('¿Olvidaste tu contraseña?'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            ),
            onPressed: () async {
              final identity = _usernameController.text.trim();
              final password = _passwordController.text;

              if (identity.isEmpty || password.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Usuario y contraseña requeridos"),
                  ),
                );
                return;
              }

              try {
                final response = await ApiClient.postJson(
                  "/auth/login",
                  body: {"identity": identity, "password": password},
                );

                if (response["success"] != true) {
                  throw Exception(response["message"] ?? "Error desconocido");
                }

                final data = response["data"] as Map<String, dynamic>;
                final token = data["token"] as String;
                final user = data["user"] as Map<String, dynamic>;
                final role = user["role"] as String;

                debugPrint("✅ Token recibido: $token");
                debugPrint("✅ Rol detectado: $role");

                await storage.write(key: "auth_token", value: token);
                await storage.write(key: "role", value: role);

                await Session().load();

                // 🔹 Navegar según rol
                switch (role) {
                  case "aspirante":
                    debugPrint("📌 Rol aspirante: buscando progreso...");
                    final stepResponse = await ApiClient.getJson(
                      "/aspirantes/progress",
                      token: token,
                    );

                    if (stepResponse["success"] == true) {
                      final step = stepResponse["step"] as int;
                      debugPrint("➡️ Progreso detectado: step $step");
                      // Usa tu función para mandar al paso correcto
                      handleLogin(context, step);
                    } else {
                      throw Exception("No se pudo obtener progreso");
                    }
                    break;

                  case "alumno":
                    debugPrint("➡️ Navegando a /alumno/inicio");
                    context.go("/alumno/inicio");
                    break;

                  case "administrativo":
                    debugPrint("➡️ Navegando a /admin/inicio");
                    context.go("/admin/inicio");
                    break;

                  default:
                    debugPrint("⚠️ Rol desconocido, navegando a /");
                    context.go("/");
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error al iniciar sesión: $e")),
                );
              }
            },
            icon: const Icon(Icons.login),
            label: const Text(
              'Iniciar Sesión',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> handleLogin(BuildContext context, int step) async {
  switch (step) {
    case 1:
      context.go('/admision');
      break;
    case 2:
      context.go('/admision/pagoexamen');
      break;
    case 3:
      context.go('/admision/pagoexamen/status');
      break;
    case 4:
      context.go('/admision/documentos/subida');
      break;
    case 5:
      context.go('/admision/documentos/estado');
      break;
    case 6:
      context.go('/alumno/inicio');
      break;
    default:
      context.go('/');
  }
}
