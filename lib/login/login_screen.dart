// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:siiadmision/config/api_client.dart';
import 'package:siiadmision/config/local_user_store.dart';
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

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final contentWidth = screenWidth.clamp(320.0, 1280.0);

            return Column(
              children: [
                Expanded(
                  child: Center(
                    child: Container(
                      width: contentWidth,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                                  BoxShadow(
                                    color: colors.shadow.withAlpha((0.1 * 255).round()),
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
        AutofillGroup(
          child: Column(
            children: [
              TextField(
                controller: _usernameController,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                textCapitalization: TextCapitalization.none,
                autocorrect: false,
                autofillHints: const [AutofillHints.username, AutofillHints.email],
                onSubmitted: (_) => FocusScope.of(context).nextFocus(),
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
                textInputAction: TextInputAction.done,
                autocorrect: false,
                autofillHints: const [AutofillHints.password],
                onSubmitted: (_) => _submitLogin(context),
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => context.go('/forgot'),
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
            onPressed: () => _submitLogin(context),
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

  Future<void> _submitLogin(BuildContext context) async {
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
      TextInput.finishAutofillContext();
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

      await storage.write(key: "auth_token", value: token);
      await storage.write(key: "role", value: role);

      final session = Session();
      await session.saveIdentity(_buildLocalIdentityPayload(user));

      await session.load();

      switch (role) {
        case "aspirante":
          final stepResponse = await ApiClient.getJson(
            "/aspirantes/progress",
            token: token,
          );

          if (stepResponse["success"] == true) {
            dynamic rawStep;
            if (stepResponse.containsKey('step')) {
              rawStep = stepResponse['step'];
            } else if (stepResponse['data'] is Map && (stepResponse['data'] as Map).containsKey('step')) {
              rawStep = (stepResponse['data'] as Map)['step'];
            }

            if (rawStep == null) {
              throw Exception('Respuesta inválida: step no encontrado');
            }

            int? step;
            if (rawStep is int) {
              step = rawStep;
            } else if (rawStep is String) {
              step = int.tryParse(rawStep);
            }

            if (step == null) {
              throw Exception('Valor de step inválido: $rawStep');
            }
            handleLogin(context, step);
          } else {
            throw Exception("No se pudo obtener progreso");
          }
          break;

        case "alumno":
          context.go("/alumno/inicio");
          break;

        case "administrativo":
          context.go("/admin/inicio");
          break;

        default:
          context.go("/");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al iniciar sesión: $e")),
      );
    }
  }

  LocalIdentity _buildLocalIdentityPayload(Map<String, dynamic> user) {
    final rawRole = (user['role'] as String?) ?? '';
    final identityMap = _toStringKeyedMap(user['identity']);
    final name = (user['name'] as String? ?? '').trim();

    return LocalIdentity(
      role: rawRole,
      name: name.isEmpty ? 'Usuario' : name,
      identifier: _resolveIdentifierValue(rawRole, identityMap, user),
      identifierLabel: _identifierLabelForRole(rawRole),
    );
  }

  Map<String, dynamic> _toStringKeyedMap(dynamic value) {
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString().toLowerCase(), val));
    }
    return const {};
  }

  String _resolveIdentifierValue(
    String role,
    Map<String, dynamic> identityMap,
    Map<String, dynamic> user,
  ) {
    switch (role) {
      case 'aspirante':
        return _stringValue(identityMap['curp']) ?? _stringValue(user['curp']) ?? '';
      case 'alumno':
        return _stringValue(identityMap['matricula']) ?? _stringValue(user['matricula']) ?? '';
      case 'administrativo':
        return _stringValue(identityMap['numero_empleado']) ??
            _stringValue(identityMap['num_empleado']) ??
            _stringValue(user['numero_empleado']) ?? '';
      default:
        break;
    }

    if (identityMap.isNotEmpty) {
      final first = identityMap.values.first;
      final candidate = _stringValue(first);
      if (candidate != null) {
        return candidate;
      }
    }

    return _stringValue(user['identity']) ?? _stringValue(user['id']) ?? '';
  }

  String _identifierLabelForRole(String role) {
    switch (role) {
      case 'aspirante':
        return 'CURP';
      case 'alumno':
        return 'Matrícula';
      case 'administrativo':
        return 'Número de empleado';
      default:
        return 'Identificador';
    }
  }

  String? _stringValue(Object? value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}

Future<void> handleLogin(BuildContext context, int step) async {
  switch (step) {
    case 1:
      context.go('/admision');
      break;
    case 2:
      context.go('/admision/bachillerato');
      break;
    case 3:
      context.go('/admision/pagoexamen');
      break;
    case 4:
      context.go('/admision/pagoexamen/status');
      break;
    case 5:
      context.go('/admision/documentos/subida');
      break;
    case 6:
      context.go('/admision/documentos/estado');
      break;
    case 7:
      context.go('/alumno/inicio');
      break;
    default:
      context.go('/');
  }
}
