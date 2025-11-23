import 'package:flutter/material.dart';

const double kNavigationRailBreakpoint = 900;

bool useNavigationRailLayout(BuildContext context) {
  return MediaQuery.of(context).size.width >= kNavigationRailBreakpoint;
}

class _NavItemData {
  final IconData icon;
  final String label;

  const _NavItemData(this.icon, this.label);
}

const List<_NavItemData> _publicNavItems = [
  _NavItemData(Icons.login, 'Inicio'),
  _NavItemData(Icons.person_add_alt, 'Admisión'),
  _NavItemData(Icons.exit_to_app, 'Portal'),
  _NavItemData(Icons.settings, 'Ajustes'),
];

const List<_NavItemData> _alumnoNavItems = [
  _NavItemData(Icons.home, 'Inicio'),
  _NavItemData(Icons.upload_file, 'Trámites'),
  _NavItemData(Icons.class_, 'Clases'),
  _NavItemData(Icons.business_center, 'Estadías'),
  _NavItemData(Icons.assignment, 'Encuestas'),
  _NavItemData(Icons.credit_card, 'Becas'),
  _NavItemData(Icons.settings, 'Ajustes'),
  _NavItemData(Icons.logout, 'Salir'),
];

const List<_NavItemData> _adminNavItems = [
  _NavItemData(Icons.home, 'Inicio'),
  _NavItemData(Icons.rule_folder, 'Aspirantes'),
  _NavItemData(Icons.account_balance, 'Finanzas'),
  _NavItemData(Icons.settings, 'Ajustes'),
  _NavItemData(Icons.logout, 'Salir'),
];

List<NavigationDestination> _buildNavigationDestinations(List<_NavItemData> items) {
  return items
      .map(
        (item) => NavigationDestination(
          icon: Icon(item.icon),
          label: item.label,
        ),
      )
      .toList();
}

final List<NavigationDestination> publicNavigationDestinations =
  _buildNavigationDestinations(_publicNavItems);

final List<NavigationDestination> alumnoNavigationDestinations =
  _buildNavigationDestinations(_alumnoNavItems);

final List<NavigationDestination> adminNavigationDestinations =
  _buildNavigationDestinations(_adminNavItems);

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
    if (!useNavigationRailLayout(context)) {
      return const SizedBox.shrink();
    }

    return NavigationRail(
      minWidth: 80,
      labelType: NavigationRailLabelType.all,
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: _publicNavItems
          .map(
            (item) => NavigationRailDestination(
              icon: Icon(item.icon),
              label: Text(item.label),
            ),
          )
          .toList(),
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
    if (!useNavigationRailLayout(context)) {
      return const SizedBox.shrink();
    }

    return NavigationRail(
      minWidth: 80,
      labelType: NavigationRailLabelType.all,
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: _alumnoNavItems
          .map(
            (item) => NavigationRailDestination(
              icon: Icon(item.icon),
              label: Text(item.label),
            ),
          )
          .toList(),
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
    if (!useNavigationRailLayout(context)) {
      return const SizedBox.shrink();
    }

    return NavigationRail(
      minWidth: 80,
      labelType: NavigationRailLabelType.all,
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: _adminNavItems
          .map(
            (item) => NavigationRailDestination(
              icon: Icon(item.icon),
              label: Text(item.label),
            ),
          )
          .toList(),
    );
  }
}
