import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:siiadmision/config/aspirante_progress.dart';
import 'package:siiadmision/config/api_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

class AdmissionScreen extends StatefulWidget {
  const AdmissionScreen({super.key});

  @override
  State<AdmissionScreen> createState() => _AdmissionScreenState();
}

class _AdmissionScreenState extends State<AdmissionScreen> {
  bool _acceptedConditions = false;
  bool _submitting = false;

  // 🔹 Controladores mínimos necesarios para el registro
  final _nombreCtrl = TextEditingController();
  final _apPatCtrl = TextEditingController();
  final _apMatCtrl = TextEditingController();
  final _curpCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  // 🔹 Campos agregados: sexo, fecha y estado de nacimiento
  String? _sexo; // 'H' o 'M'
  DateTime? _fechaNac;
  String? _estadoNac; // código entidad: 'PL', 'DF', etc.

  final _estadosMx = const [
    {'code': 'AS', 'name': 'Aguascalientes'},
    {'code': 'BC', 'name': 'Baja California'},
    {'code': 'BS', 'name': 'Baja California Sur'},
    {'code': 'CC', 'name': 'Campeche'},
    {'code': 'CL', 'name': 'Coahuila'},
    {'code': 'CM', 'name': 'Colima'},
    {'code': 'CS', 'name': 'Chiapas'},
    {'code': 'CH', 'name': 'Chihuahua'},
    {'code': 'DF', 'name': 'Ciudad de México'},
    {'code': 'DG', 'name': 'Durango'},
    {'code': 'GT', 'name': 'Guanajuato'},
    {'code': 'GR', 'name': 'Guerrero'},
    {'code': 'HG', 'name': 'Hidalgo'},
    {'code': 'JC', 'name': 'Jalisco'},
    {'code': 'MC', 'name': 'México'},
    {'code': 'MN', 'name': 'Michoacán'},
    {'code': 'MS', 'name': 'Morelos'},
    {'code': 'NT', 'name': 'Nayarit'},
    {'code': 'NL', 'name': 'Nuevo León'},
    {'code': 'OC', 'name': 'Oaxaca'},
    {'code': 'PL', 'name': 'Puebla'},
    {'code': 'QT', 'name': 'Querétaro'},
    {'code': 'QR', 'name': 'Quintana Roo'},
    {'code': 'SP', 'name': 'San Luis Potosí'},
    {'code': 'SL', 'name': 'Sinaloa'},
    {'code': 'SR', 'name': 'Sonora'},
    {'code': 'TC', 'name': 'Tabasco'},
    {'code': 'TS', 'name': 'Tamaulipas'},
    {'code': 'TL', 'name': 'Tlaxcala'},
    {'code': 'VZ', 'name': 'Veracruz'},
    {'code': 'YN', 'name': 'Yucatán'},
    {'code': 'ZS', 'name': 'Zacatecas'},
    {'code': 'NE', 'name': 'Nacido en el extranjero'},
  ];

  @override
  void initState() {
    super.initState();
    // Autorrelleno desde CURP cuando es válida
    _curpCtrl.addListener(() {
      final curp = _curpCtrl.text.trim().toUpperCase();
      if (curp.length == 18 &&
          RegExp(r'^[A-Z]{4}\d{6}[HM][A-Z]{5}[A-Z0-9]\d\$').hasMatch(curp)) {
        _applyFromCurp(curp);
      }
    });
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apPatCtrl.dispose();
    _apMatCtrl.dispose();
    _curpCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  // 🔹 Genera una contraseña temporal si aún no la recolectas en esta vista
  String _genTempPassword() {
    final rnd = Random.secure();
    const upper = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
    const lower = 'abcdefghijkmnpqrstuvwxyz';
    const digits = '23456789';
    const all = '$upper$lower$digits';
    String pick(String s) => s[rnd.nextInt(s.length)];
    final base = [
      pick(upper),
      pick(lower),
      pick(digits),
      pick(lower),
      ...List.generate(6, (_) => pick(all)),
    ]
      ..shuffle(rnd);
    return base.join();
  }

  // 🔹 Derivar sexo/fecha/estado desde la CURP
  void _applyFromCurp(String curp) {
    final yy = int.parse(curp.substring(4, 6));
    final mm = int.parse(curp.substring(6, 8));
    final dd = int.parse(curp.substring(8, 10));
    // Heurística: >= 30 => 1900s, si no => 2000s (ajusta a tu población objetivo)
    final year = yy >= 30 ? 1900 + yy : 2000 + yy;

    final sexo = curp.substring(10, 11); // 'H' o 'M'
    final estado = curp.substring(11, 13); // código entidad

    setState(() {
      _sexo = sexo;
      _fechaNac = DateTime(year, mm, dd);
      if (_estadosMx.any((e) => e['code'] == estado)) {
        _estadoNac = estado;
      }
    });
  }

  Future<void> _pickFechaNac() async {
    final now = DateTime.now();
    final initial = _fechaNac ?? DateTime(now.year - 18, now.month, now.day);
    final first = DateTime(now.year - 80);
    final last = DateTime(now.year - 12);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      helpText: 'Selecciona tu fecha de nacimiento',
      locale: const Locale('es', 'MX'),
    );
    if (picked != null) {
      setState(() => _fechaNac = picked);
    }
  }

  Future<void> _registerAspirante() async {
    if (_submitting) return;

    final nombre = _nombreCtrl.text.trim();
    final apPat = _apPatCtrl.text.trim();
    final apMat = _apMatCtrl.text.trim();
    String curp = _curpCtrl.text.trim().toUpperCase();
    final email = _emailCtrl.text.trim();

    

    final bool curpValida =
        RegExp(r'^[A-Z]{4}\d{6}[HM][A-Z]{5}[A-Z0-9]\d\$').hasMatch(curp);
    final bool emailValido =
        RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+\$').hasMatch(email);

    if (curp.isEmpty && nombre.isNotEmpty && apPat.isNotEmpty && _fechaNac != null && _sexo != null && _estadoNac != null) {
      curp = generarCurp(
        nombre: nombre,
        apPat: apPat,
        apMat: apMat,
        sexo: _sexo!,
        fechaNac: _fechaNac!,
        estadoNac: _estadoNac!,
      );
      _curpCtrl.text = curp; // para que lo vea en el formulario
    }

    // Camino A: CURP + email
    final bool caminoA = curpValida;
    // Camino B: Nombre + Ap. Paterno + CURP
    final bool caminoB = nombre.isNotEmpty && apPat.isNotEmpty && apMat.isNotEmpty ;

    if (!emailValido) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El correo electrónico es obligatorio y debe ser válido')),
      );
      return;
    }

    if (!caminoA && !caminoB) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Completa CURP válida y correo, o bien Nombre, Ap. Paterno y CURP válida'),
        ),
      );
      return;
    }

    // Reglas adicionales para sexo/fecha/estado
    if (curpValida) {
      if (_sexo == null || _fechaNac == null || _estadoNac == null) {
        _applyFromCurp(curp);
      }
    } else {
      if (_sexo == null || _fechaNac == null || _estadoNac == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Completa sexo, fecha y estado de nacimiento')),
        );
        return;
      }
    }

    setState(() => _submitting = true);

    try {
      final body = {
        'nombre': nombre,
        'ap_paterno': apPat,
        'ap_materno': apMat.isEmpty ? null : apMat,
        'curp': curp.isEmpty ? null : curp,
        'password': _genTempPassword(),
        'sexo': _sexo, // 'H' o 'M'
        'fecha_nacimiento': _fechaNac != null
            ? '${_fechaNac!.year.toString().padLeft(4, '0')}-${_fechaNac!.month.toString().padLeft(2, '0')}-${_fechaNac!.day.toString().padLeft(2, '0')}'
            : null,
        'estado_nacimiento': _estadoNac,
        'email': emailValido ? email : null,
      };

      final resp = await ApiClient.postJson('/aspirantes/start', body: body);

      // Se espera { token, token_type, user: { ... , redirect_to } }
      final token = (resp['data']?['token'] ?? resp['token']) as String?;
      final user =
          (resp['data']?['user'] ?? resp['user']) as Map<String, dynamic>?;

      if (token == null || user == null) {
        throw Exception('Respuesta inválida del servidor');
      }

      // Guarda token de forma segura
      final secure = const FlutterSecureStorage();
      await secure.write(key: 'auth_token', value: token);
      await secure.write(
        key: 'token_type',
        value: (resp['data']?['token_type'] ?? resp['token_type'] ?? 'Bearer')
            .toString(),
      );

      // Guarda progreso local (opcional)
      ProgressService.saveStep(2);

      // Redirige: si tu Resource devuelve redirect_to, úsalo
      final redirect = user['redirect_to']?.toString() ?? '/admision/pagoexamen';
      if (!mounted) return;
      context.push(redirect);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

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
    final uri = Uri.parse(
        'https://transparencia.puebla.gob.mx/avisos-de-privacidad-transparencia?catid=196');

    Widget nombres = isMobile
        ? Column(
            children: [
              _inputField(
                  controller: _nombreCtrl,
                  label: 'Nombre(s)',
                  icon: Icons.person),
              const SizedBox(height: 12),
              _inputField(
                  controller: _apPatCtrl,
                  label: 'Apellido Paterno',
                  icon: Icons.person),
              const SizedBox(height: 12),
              _inputField(
                  controller: _apMatCtrl,
                  label: 'Apellido Materno',
                  icon: Icons.person),
            ],
          )
        : Row(children: [
            Expanded(
                child: _inputField(
                    controller: _nombreCtrl,
                    label: 'Nombre(s)',
                    icon: Icons.person)),
            const SizedBox(width: 12),
            Expanded(
                child: _inputField(
                    controller: _apPatCtrl,
                    label: 'Apellido Paterno',
                    icon: Icons.person)),
            const SizedBox(width: 12),
            Expanded(
                child: _inputField(
                    controller: _apMatCtrl,
                    label: 'Apellido Materno',
                    icon: Icons.person)),
          ]);

    Widget sexoFechaEstado = isMobile
        ? Column(
            children: [
              _sexoDropdown(),
              const SizedBox(height: 12),
              _fechaNacField(),
              const SizedBox(height: 12),
              _estadoDropdown(),
            ],
          )
        : Row(
            children: [
              Expanded(child: _sexoDropdown()),
              const SizedBox(width: 12),
              Expanded(child: _fechaNacField()),
              const SizedBox(width: 12),
              Expanded(child: _estadoDropdown()),
            ],
          );

    Widget curpCorreo = isMobile
        ? Column(
            children: [
              _inputField(
                controller: _curpCtrl,
                label: 'CURP de 18 Dígitos',
                icon: Icons.password,
                keyboardType: TextInputType.visiblePassword,
                textCapitalization: TextCapitalization.characters,
                maxLength: 18,
              ),
              const SizedBox(height: 12),
              _inputField(
                controller: _emailCtrl,
                label: 'Correo Electrónico',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          )
        : Row(children: [
            Expanded(
              child: _inputField(
                controller: _curpCtrl,
                label: 'CURP de 18 Dígitos',
                icon: Icons.password,
                keyboardType: TextInputType.visiblePassword,
                textCapitalization: TextCapitalization.characters,
                maxLength: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _inputField(
                controller: _emailCtrl,
                label: 'Correo Electrónico',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
            ),
          ]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Admisión 2025',
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Bienvenido Aspirante', style: textTheme.labelLarge),
        const SizedBox(height: 12),
        Text('¿Quieres ser un Guerrero UTH? Estás en el lugar adecuado.',
            style: textTheme.bodyMedium),
        const SizedBox(height: 8),
        Text('Necesitamos:\n1. Tu Acta de Nacimiento\n2. Datos de tu Bachillerato',
            style: textTheme.bodySmall),
        const SizedBox(height: 24),

        nombres,
        const SizedBox(height: 16),

        sexoFechaEstado,
        const SizedBox(height: 24),

        Text('Si conoces tu CURP puedes solo llenar el CURP y el Correo',
            style: textTheme.bodySmall),
        const SizedBox(height: 12),

        curpCorreo,
        const SizedBox(height: 24),

        Text('NOTA: Se enviará una contraseña temporal al correo proporcionado.',
            style: textTheme.bodySmall),
        const SizedBox(height: 16),

        Align(
          alignment: Alignment.bottomRight,
          child: FilledButton.icon(
            onPressed: _submitting
                ? null
                : () async {
                    setState(() => _acceptedConditions = false);
                    await showDialog(
                      context: context,
                      builder: (context) => StatefulBuilder(
                        builder: (context, setStateDialog) {
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
                                  InkWell(
                                    onTap: () async {
                                      final uri = Uri.parse(
                                          'https://transparencia.puebla.gob.mx/avisos-de-privacidad-transparencia?catid=196');
                                      if (await canLaunchUrl(uri)) {
                                        await launchUrl(uri,
                                            mode: LaunchMode.externalApplication);
                                      }
                                    },
                                    child: Text(
                                      'https://transparencia.puebla.gob.mx/avisos-de-privacidad-transparencia?catid=196',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  CheckboxListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: const Text(
                                        'Acepto las Condiciones de Registro'),
                                    value: _acceptedConditions,
                                    onChanged: (value) => setStateDialog(
                                        () => _acceptedConditions =
                                            value ?? false),
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
                                    ? () async {
                                        Navigator.pop(context);
                                        await _registerAspirante();
                                      }
                                    : null,
                                child: _submitting
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2))
                                    : const Text('Acepto'),
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  },
            icon: const Icon(Icons.arrow_forward),
            label: _submitting
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Siguiente'),
          ),
        ),
      ],
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      maxLength: maxLength,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
      ).copyWith(
        labelText: label,
        prefixIcon: Icon(icon),
        counterText: '', // oculta contador
      ),
    );
  }

  Widget _sexoDropdown() {
    return DropdownButtonFormField<String>(
      value: _sexo,
      decoration: const InputDecoration(
        labelText: 'Sexo',
        prefixIcon: Icon(Icons.wc),
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'H', child: Text('Hombre')),
        DropdownMenuItem(value: 'M', child: Text('Mujer')),
      ],
      onChanged: (v) => setState(() => _sexo = v),
    );
  }

  Widget _fechaNacField() {
    final text = _fechaNac == null
        ? ''
        : '${_fechaNac!.day.toString().padLeft(2, '0')}/${_fechaNac!.month.toString().padLeft(2, '0')}/${_fechaNac!.year}';
    final controller = TextEditingController(text: text);
    return InkWell(
      onTap: _pickFechaNac,
      child: IgnorePointer(
        child: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Fecha de nacimiento',
            prefixIcon: Icon(Icons.cake_outlined),
            border: OutlineInputBorder(),
            hintText: 'DD/MM/AAAA',
            suffixIcon: Icon(Icons.calendar_today),
          ),
        ),
      ),
    );
  }

  Widget _estadoDropdown() {
    return DropdownButtonFormField<String>(
      value: _estadoNac,
      decoration: const InputDecoration(
        labelText: 'Estado de nacimiento',
        prefixIcon: Icon(Icons.location_on_outlined),
        border: OutlineInputBorder(),
      ),
      items: _estadosMx
          .map((e) => DropdownMenuItem(
                value: e['code']!,
                child: Text('${e['name']} (${e['code']})'),
              ))
          .toList(),
      onChanged: (v) => setState(() => _estadoNac = v),
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
            Expanded(
                child: Text('¿Necesitas ayuda?',
                    style: TextStyle(fontWeight: FontWeight.bold))),
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

String generarCurp({
  required String nombre,
  required String apPat,
  required String apMat,
  required String sexo,        // 'H' o 'M'
  required DateTime fechaNac,
  required String estadoNac,   // código: 'PL', 'DF', etc.
}) {
  // 🔹 Normalizar (quitar acentos y pasar a mayúsculas)
  String clean(String s) => s
      .toUpperCase()
      .replaceAll(RegExp(r'[^A-ZÑ ]'), '')
      .trim();

  nombre = clean(nombre);
  apPat = clean(apPat);
  apMat = clean(apMat);

  // 🔹 Primeras 4 letras
  String l1 = apPat.isNotEmpty ? apPat[0] : 'X';
  String l2 = apPat.length > 1
      ? apPat.substring(1).replaceAll(RegExp(r'[AEIOU]'), '').isNotEmpty
          ? apPat.substring(1).replaceAll(RegExp(r'[^AEIOU]'), '')[0]
          : 'X'
      : 'X';
  String l3 = apMat.isNotEmpty ? apMat[0] : 'X';
  String l4 = nombre.isNotEmpty ? nombre[0] : 'X';

  // 🔹 Fecha YYMMDD
  String yy = fechaNac.year.toString().substring(2);
  String mm = fechaNac.month.toString().padLeft(2, '0');
  String dd = fechaNac.day.toString().padLeft(2, '0');

  // 🔹 Armar CURP inicial
  String curp = '$l1$l2$l3$l4$yy$mm$dd$sexo$estadoNac';

  // 🔹 Consonantes internas (simplificado)
  String consApPat = apPat.length > 2
      ? apPat.substring(1).replaceAll(RegExp(r'[AEIOU]'), '')
      : 'X';
  String consApMat = apMat.length > 2
      ? apMat.substring(1).replaceAll(RegExp(r'[AEIOU]'), '')
      : 'X';
  String consNom = nombre.length > 2
      ? nombre.substring(1).replaceAll(RegExp(r'[AEIOU]'), '')
      : 'X';

  curp += '${consApPat.isNotEmpty ? consApPat[0] : 'X'}'
          '${consApMat.isNotEmpty ? consApMat[0] : 'X'}'
          '${consNom.isNotEmpty ? consNom[0] : 'X'}';

  // 🔹 Homoclave y dígito verificador (simulados)
  curp += '00';

  return curp;
}
