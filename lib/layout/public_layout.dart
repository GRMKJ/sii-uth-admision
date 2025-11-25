import 'package:flutter/material.dart';
import 'package:siiadmision/layout/header.dart';
import 'package:siiadmision/widgets/sidebar.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class PublicLayout extends StatelessWidget {
  final Widget child;
  final String location;

  const PublicLayout({
    super.key,
    required this.child,
    required this.location,
  });

  /// Deducción automática del índice según la ruta actual
  int _getSelectedIndex(String location) {
    if (location == '/') return 0;
    if (location.startsWith('/admision')) return 1;
    if (location.startsWith('/uth')) return 2;
    if (location.startsWith('/ajustes')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _getSelectedIndex(location);
    final useRail = useNavigationRailLayout(context);

    Future<void> openUthSite() async {
      final uri = Uri.parse('https://uth.edu.mx/');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo abrir el sitio de la UTH.')),
          );
        }
      }
    }

    void handleNavigation(int index) {
      switch (index) {
        case 0:
          context.go('/');
          break;
        case 1:
          context.go('/admision');
          break;
        case 2:
          openUthSite();
          break;
        case 3:
          context.go('/ajustes');
          break;
      }
    }

    final content = SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final baseMargin = screenWidth * 0.05;
          final computedWidth = (screenWidth - (baseMargin * 2)).clamp(0.0, 1280.0);
          final contentWidth = computedWidth == 0 ? screenWidth : computedWidth;
          final isCompact = screenWidth < 640;
          final horizontalPadding = isCompact ? 0.0 : (screenWidth - contentWidth) / 2;
          final bodyWidth = isCompact ? screenWidth : contentWidth;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              children: [
                UthHeader(maxWidth: bodyWidth),
                const SizedBox(height: 24),
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: bodyWidth,
                      child: child,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );

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
                Expanded(child: content),
              ],
            )
          : content,
    );
  }
}
