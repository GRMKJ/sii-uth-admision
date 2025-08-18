import 'package:flutter/material.dart';
import 'package:siiadmision/layout/header.dart';
import 'package:siiadmision/layout/side_navigation.dart';
import 'package:go_router/go_router.dart';

class DashboardAlumnoScreen extends StatefulWidget {
  const DashboardAlumnoScreen({super.key});

  @override
  State<DashboardAlumnoScreen> createState() => _DashboardAlumnoScreenState();
}

class _DashboardAlumnoScreenState extends State<DashboardAlumnoScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      body: Row(
        children: [
          SideNavigationAlumno(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              switch (index) {
                case 0:
                  context.go('/alumno/inicio');
                  break;
                case 7:
                  context.go('/');
                  break;
              }
            },
          ),
          Expanded(
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = constraints.maxWidth;
                  final contentWidth = screenWidth.clamp(320.0, 1000.0);

                  return Column(
                    children: [
                      UthHeader(maxWidth: contentWidth),
                      const SizedBox(height: 24),
                      Expanded(
                        child: Center(
                          child: Container(
                            width: contentWidth,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.shadow.withOpacity(0.1),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Panel de Alumno',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 24),
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Horario Semanal
                                      Expanded(
                                        child: _HorarioWidget(),
                                      ),
                                      const SizedBox(width: 16),
                                      // Estado de inscripción y festivos
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: const [
                                            _EstadoInscripcionWidget(),
                                            SizedBox(height: 16),
                                            _ProximosFestivosWidget(),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HorarioWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Horario Semanal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Lunes - Matemáticas 8:00 - 9:30'),
                Text('Aula 3')
              ],
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Martes - Programación 10:00 - 12:00'),
                Text('Laboratorio')
              ],
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Miércoles - Inglés 9:00 - 10:30'),
                Text('Aula 5')
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EstadoInscripcionWidget extends StatelessWidget {
  const _EstadoInscripcionWidget();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Estado de Inscripción', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 12),
            Text('✅ Documentos completos'),
            Text('✅ Pago validado'),
          ],
        ),
      ),
    );
  }
}

class _ProximosFestivosWidget extends StatelessWidget {
  const _ProximosFestivosWidget();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Próximos Días Festivos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 12),
            Text('🎉 16 de Septiembre - Día de la Independencia'),
            Text('🕊️ 2 de Noviembre - Día de Muertos'),
          ],
        ),
      ),
    );
  }
}
