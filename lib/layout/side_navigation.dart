import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SideNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const SideNavigation({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          right: BorderSide(color: colors.outlineVariant),
        ),
      ),
      child: Column(
        children: [
          // Botón hamburguesa o menú
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {},
            tooltip: 'Menú',
          ),

          const SizedBox(height: 24),

          // Opciones de navegación
          _NavItem(
            icon: Icons.login,
            label: 'Iniciar\nSesión',
            selected: selectedIndex == 0,
            onTap: () => onDestinationSelected(0),
          ),
          _NavItem(
            icon: Icons.person_add_alt,
            label: 'Admisión\n2025',
            selected: selectedIndex == 1,
            onTap: () => onDestinationSelected(1),
          ),
          _NavItem(
            icon: Icons.exit_to_app,
            label: 'Regresar a\nUTH.edu.mx',
            selected: selectedIndex == 2,
            onTap: _launchUthWebsite, // Llama a la función
          ),
          _NavItem(
            icon: Icons.settings,
            label: 'Ajustes',
            selected: selectedIndex == 3,
            onTap: () => onDestinationSelected(3),
          ),
        ],
      ),
    );
  }
  void _launchUthWebsite() async {
    const url = 'https://uth.edu.mx';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('No se pudo abrir $url');
    }
  }
}


class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: selected
                    ? colors.secondaryContainer.withOpacity(0.5)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(
                icon,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 11,
                    color: colors.onSurface,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Navegacion de Alumno
class SideNavigationAlumno extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const SideNavigationAlumno({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          right: BorderSide(color: colors.outlineVariant),
        ),
      ),
      child: Column(
        children: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {},
            tooltip: 'Menú',
          ),
          const SizedBox(height: 24),

          // 🔽 Menú para Alumno Logueado
          _NavItem(
            icon: Icons.home,
            label: 'Inicio',
            selected: selectedIndex == 0,
            onTap: () => onDestinationSelected(0),
          ),
          _NavItem(
            icon: Icons.upload_file,
            label: 'Tramites y Servicios',
            selected: selectedIndex == 1,
            onTap: () => onDestinationSelected(1),
          ),
          _NavItem(
            icon: Icons.class_,
            label: 'Mis Clases',
            selected: selectedIndex == 2,
            onTap: () => onDestinationSelected(2),
          ),
          _NavItem(
            icon: Icons.business_center,
            label: 'Estadias',
            selected: selectedIndex == 3,
            onTap: () => onDestinationSelected(3),
          ),
          _NavItem(
            icon: Icons.assignment,
            label: 'Encuestas y Evaluaciones',
            selected: selectedIndex == 4,
            onTap: () => onDestinationSelected(4),
          ),
          _NavItem(
            icon: Icons.credit_card,
            label: 'Becas',
            selected: selectedIndex == 5,
            onTap: () => onDestinationSelected(5),
          ),
          _NavItem(
            icon: Icons.settings,
            label: 'Ajustes',
            selected: selectedIndex == 6,
            onTap: () => onDestinationSelected(6),
          ),
          _NavItem(
            icon: Icons.logout,
            label: 'Cerrar Sesión',
            selected: selectedIndex == 7,
            onTap: () => onDestinationSelected(7),
          ),
        ],
      ),
    );
  }
}

// Navegacion de Administrativo
class SideNavigationAdmin extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const SideNavigationAdmin({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          right: BorderSide(color: colors.outlineVariant),
        ),
      ),
      child: Column(
        children: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {},
            tooltip: 'Menú',
          ),
          const SizedBox(height: 24),

          // 🔽 Menú para Administrativos
          _NavItem(
            icon: Icons.home,
            label: 'Inicio',
            selected: selectedIndex == 0,
            onTap: () => onDestinationSelected(0),
          ),
          _NavItem(
            icon: Icons.rule_folder,
            label: 'Aspirantes',
            selected: selectedIndex == 1,
            onTap: () => onDestinationSelected(1),
          ),
          _NavItem(
            icon: Icons.settings,
            label: 'Ajustes',
            selected: selectedIndex == 6,
            onTap: () => onDestinationSelected(6),
          ),
          _NavItem(
            icon: Icons.logout,
            label: 'Cerrar Sesión',
            selected: selectedIndex == 7,
            onTap: () => onDestinationSelected(7),
          ),
        ],
      ),
    );
  }
}
