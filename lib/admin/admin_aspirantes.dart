import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:siiadmision/layout/header.dart';
import 'package:siiadmision/layout/side_navigation.dart';

class AspirantesAdminScreen extends StatelessWidget {
  const AspirantesAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final tabs = ['Todos', 'Con Pago', 'Con Documentos', 'Listos para Inscripción'];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: colors.surfaceContainerLowest,
        body: Row(
          children: [
            SideNavigationAdmin(
              selectedIndex: 1,
              onDestinationSelected: (index) {
                switch (index) {
                  case 0:
                    context.go('/admin/inicio');
                    break;
                  case 1:
                    context.go('/admin/aspirantes');
                    break;
                  case 7:
                    context.go('/');
                    break;
                  default:
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Modulo No Implementado')),
                    );
                }
              },
            ),
            Expanded(
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final screenWidth = constraints.maxWidth;
                    final contentWidth = screenWidth.clamp(320.0, 1280.0);

                    return Column(
                      children: [
                        UthHeader(maxWidth: contentWidth),
                        const SizedBox(height: 16),
                        TabBar(
                          isScrollable: true,
                          indicatorColor: colors.primary,
                          labelColor: colors.primary,
                          unselectedLabelColor: colors.onSurfaceVariant,
                          tabs: tabs.map((t) => Tab(text: t)).toList(),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Container(
                            width: contentWidth,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.shadow.withOpacity(0.05),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: const TabBarView(
                              children: [
                                _TodosTab(),
                                _PagoTab(),
                                _DocumentosTab(),
                                _InscripcionTab(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _TodosTab extends StatelessWidget {
  const _TodosTab();

  @override
  Widget build(BuildContext context) => _buildList('ASP001, ASP002, ASP003');
}

class _PagoTab extends StatelessWidget {
  const _PagoTab();

  @override
  Widget build(BuildContext context) => _buildList(
        'ASP001, ASP003',
        buttonLabel: 'Validar Pago',
        onPressed: (context, folio) => context.push('/admin/aspirante/$folio/pago'),
      );
}

class _DocumentosTab extends StatelessWidget {
  const _DocumentosTab();

  @override
  Widget build(BuildContext context) => _buildList(
        'ASP002, ASP004',
        buttonLabel: 'Ver Documentos',
        onPressed: (context, folio) => context.push('/admin/aspirante/$folio/documentos'),
      );
}

class _InscripcionTab extends StatelessWidget {
  const _InscripcionTab();

  @override
  Widget build(BuildContext context) => _buildList(
        'ASP005',
        buttonLabel: 'Autorizar e Inscribir',
        onPressed: (context, folio) => context.push('/admin/aspirante/$folio/inscripcion'),
      );
}

Widget _buildList(
  String items, {
  String? buttonLabel,
  void Function(BuildContext, String)? onPressed,
}) {
  final list = items.split(', ');

  return ListView.separated(
    itemCount: list.length,
    separatorBuilder: (_, __) => const Divider(),
    itemBuilder: (context, index) {
      final folio = list[index];
      return ListTile(
        leading: const Icon(Icons.person_outline),
        title: Text('Folio: $folio'),
        subtitle: const Text('Nombre del aspirante'),
        trailing: buttonLabel != null
            ? ElevatedButton(
                onPressed: () => onPressed?.call(context, folio),
                child: Text(buttonLabel),
              )
            : null,
      );
    },
  );
}
