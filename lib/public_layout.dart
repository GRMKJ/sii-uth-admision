import 'package:flutter/material.dart';
import 'package:siiadmision/header.dart';
import 'package:siiadmision/side_navigation.dart';
import 'package:go_router/go_router.dart';

class PublicLayout extends StatelessWidget {
  final Widget child;

  const PublicLayout({
    super.key,
    required this.child,
  });

  /// Deducción automática del índice según la ruta actual
  int _getSelectedIndex(String location) {
    if (location.startsWith('/admision')) return 1;
    if (location.startsWith('/admision/pagoexamen')) return 1;
    if (location.startsWith('/admision/pagoexamen/status')) return 1;
    if (location.startsWith('/uth')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final selectedIndex = _getSelectedIndex(location);

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
          Expanded(
            child: SafeArea(
              child: Column(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final screenWidth = constraints.maxWidth;
                      final margin = screenWidth * 0.05;
                      final contentWidth = screenWidth.clamp(320.0, 1280.0);
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: margin),
                        child: UthHeader(maxWidth: contentWidth),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Expanded(child: child),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
