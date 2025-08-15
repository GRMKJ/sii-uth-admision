import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
              padding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 20,
              ),
            ),
            onPressed: () {
              final user = _usernameController.text;
              final pass = _passwordController.text;

              if (user == 'ASP123456' && pass == 'aspirante') {
                context.go('/admision');
              } else if (user == 'ALU2025001' && pass == 'alumno') {
                context.go('/alumno/inicio');
              } else if (user == 'ADM001' && pass == 'admin') {
                context.go('/admin/inicio');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Usuario o contraseña incorrectos')),
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
