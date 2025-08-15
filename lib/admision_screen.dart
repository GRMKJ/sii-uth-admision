import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdmissionScreen extends StatefulWidget {
  const AdmissionScreen({super.key});

  @override
  State<AdmissionScreen> createState() => _AdmissionScreenState();
}

class _AdmissionScreenState extends State<AdmissionScreen> {
  bool _acceptedConditions = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
  backgroundColor: colors.surfaceContainerLowest,
  body: SafeArea(
    child: LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final contentWidth = screenWidth.clamp(320.0, 1000.0);
        final isMobile = screenWidth < 640;

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
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: colors.shadow.withOpacity(0.1),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: isMobile
                      ? _buildColumnLayout(context)
                      : _buildRowLayout(context),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    ),
  ),
  floatingActionButton: FloatingActionButton(
    onPressed: _showHelpDialog,
    tooltip: 'Ayuda',
    child: const Icon(Icons.help_outline),
  ),
);

  }

  Widget _buildRowLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              bottomLeft: Radius.circular(24),
            ),
            child: Image.asset(
              'assets/uth_fondo2.jpg',
              fit: BoxFit.cover,
              height: double.infinity,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: _formContent(context, isMobile: false),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColumnLayout(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: Image.asset(
            'assets/uth_fondo2.jpg',
            fit: BoxFit.cover,
            height: 180,
            width: double.infinity,
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _formContent(context, isMobile: true),
          ),
        ),
      ],
    );
  }

  Widget _formContent(BuildContext context, {required bool isMobile}) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Admisión 2025', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Bienvenido Aspirante', style: textTheme.labelLarge),
        const SizedBox(height: 12),
        Text('¿Quieres ser un Guerrero UTH? Estás en el lugar adecuado.', style: textTheme.bodyMedium),
        const SizedBox(height: 8),
        Text('Necesitamos:\n1. Tu Acta de Nacimiento\n2. Datos de tu Bachillerato', style: textTheme.bodySmall),
        const SizedBox(height: 24),

        isMobile
            ? Column(
                children: [
                  _inputField('Nombre(s)', Icons.person),
                  const SizedBox(height: 12),
                  _inputField('Apellido Paterno', Icons.person),
                  const SizedBox(height: 12),
                  _inputField('Apellido Materno', Icons.person),
                ],
              )
            : Row(children: [
                Expanded(child: _inputField('Nombre(s)', Icons.person)),
                const SizedBox(width: 12),
                Expanded(child: _inputField('Apellido Paterno', Icons.person)),
                const SizedBox(width: 12),
                Expanded(child: _inputField('Apellido Materno', Icons.person)),
              ]),
        const SizedBox(height: 16),

        isMobile
            ? Column(
                children: [
                  _inputField('Sexo', Icons.transgender),
                  const SizedBox(height: 12),
                  _inputField('Fecha de Nacimiento', Icons.calendar_today),
                  const SizedBox(height: 12),
                  _inputField('Selecciona tu Estado', Icons.map_outlined),
                ],
              )
            : Row(children: [
                Expanded(flex: 2, child: _inputField('Sexo', Icons.transgender)),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: _inputField('Fecha de Nacimiento', Icons.calendar_today)),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: _inputField('Selecciona tu Estado', Icons.map_outlined)),
              ]),
        const SizedBox(height: 24),

        Text('Si conoces tu CURP puedes solo llenar el CURP y el Correo', style: textTheme.bodySmall),
        const SizedBox(height: 12),

        isMobile
            ? Column(
                children: [
                  _inputField('CURP de 18 Dígitos', Icons.password),
                  const SizedBox(height: 12),
                  _inputField('Correo Electrónico', Icons.email_outlined),
                ],
              )
            : Row(children: [
                Expanded(child: _inputField('CURP de 18 Dígitos', Icons.password)),
                const SizedBox(width: 12),
                Expanded(child: _inputField('Correo Electrónico', Icons.email_outlined)),
              ]),
        const SizedBox(height: 24),

        Text('NOTA: Se enviará una contraseña temporal al correo proporcionado.', style: textTheme.bodySmall),
        const SizedBox(height: 16),

        Align(
          alignment: Alignment.bottomRight,
          child: FilledButton.icon(
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (context) => StatefulBuilder(
                  builder: (context, setState) {
                    return AlertDialog(
                      title: const Text('Condiciones de Registro'),
                      content: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Este registro está sujeto a las siguientes condiciones:\n\n• Fechas oficiales para realizarlo, veracidad y totalidad de los datos e información que se requiere y proporcione, incluido el pago.\n• Iniciado este registro tienes 5 días hábiles para concluirlo en su totalidad, en caso de no concluirlo será borrado y puede iniciar nuevamente.\n• En su caso, atienda las observaciones que se le hagan llegar a su correo electrónico o algún otro medio de comunicación.\n• Debe recibir un correo electrónico de confirmación de registro.\n• En caso de que no reciba la confirmación de registro, o tenga alguna duda debe consultar mediante el contacto de Dudas que se muestra abajo.\n• Que haya leído y acepte los Avisos de Privacidad del link de más abajo.',
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                'https://transparencia.puebla.gob.mx/avisos-de-privacidad-transparencia?catid=196',
                                style: TextStyle(color: colors.primary),
                              ),
                            ),
                            const SizedBox(height: 16),
                            CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Acepto las Condiciones de Registro'),
                              value: _acceptedConditions,
                              onChanged: (value) => setState(() => _acceptedConditions = value ?? false),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('No Acepto'),
                        ),
                        FilledButton(
                          onPressed: _acceptedConditions
                              ? () {
                                  Navigator.pop(context);
                                  context.push('/admision/pagoexamen'); 
                                }
                              : null,
                          child: const Text('Acepto'),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Siguiente'),
          ),
        ),
      ],
    );
  }

  Widget _inputField(String label, IconData icon) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }

  void _showHelpDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Row(
        children: [
          Icon(Icons.help_outline, size: 32),
          SizedBox(width: 8),
          Expanded(child: Text('¿Necesitas ayuda?', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Si tienes dudas sobre tu registro, puedes contactarnos:'),
          SizedBox(height: 12),
          Text('📧 Correo:'),
          SelectableText('aspirante@uth.edu.mx'),
          SizedBox(height: 8),
          Text('📞 Teléfonos:'),
          Text('227 275 9311'),
          Text('227 275 9313'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    ),
  );
}

}
