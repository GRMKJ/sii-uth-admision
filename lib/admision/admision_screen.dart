import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:siiadmision/config/aspirante_progress.dart';
import 'package:siiadmision/config/api_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

enum _FormTier { mobile, compact, wide }

class _AdjustFechaIntent extends Intent {
  const _AdjustFechaIntent(this.delta);
  final int delta;
}

class AdmissionScreen extends StatefulWidget {
  const AdmissionScreen({super.key});

  @override
  State<AdmissionScreen> createState() => _AdmissionScreenState();
}

class _AdmissionScreenState extends State<AdmissionScreen> {
  bool _acceptedConditions = false;
  bool _submitting = false;
  bool _autoCurpGenerated = false;
  final TextEditingController _fechaTextCtrl = TextEditingController();
  final FocusNode _fechaFocusNode = FocusNode();
  bool _updatingFechaText = false;

  // 🔹 Controladores mínimos necesarios para el registro
  final _nombreCtrl = TextEditingController();
  final _apPatCtrl = TextEditingController();
  final _apMatCtrl = TextEditingController();
  final _curpCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();

  // 🔹 Campos agregados: sexo, fecha y estado de nacimiento
  String? _sexo; // 'H' o 'M'
  DateTime? _fechaNac;
  String? _estadoNac; // código entidad: 'PL', 'DF', etc.
  static const Map<String, String> _sexoOptions = {
    'H': 'Hombre',
    'M': 'Mujer',
    'N': 'No binario',
  };

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
          RegExp(r'^[A-Z]{4}\d{6}[HM][A-Z]{5}[A-Z0-9]\d$').hasMatch(curp)) {
        if (_autoCurpGenerated) {
          setState(() => _autoCurpGenerated = false);
        }
        _applyFromCurp(curp);
      } else if (_autoCurpGenerated && curp.length != 18) {
        setState(() => _autoCurpGenerated = false);
      }
    });

    for (final ctrl in [_nombreCtrl, _apPatCtrl, _apMatCtrl]) {
      ctrl.addListener(_tryAutoFillCurp);
    }

    _fechaTextCtrl.addListener(_handleFechaTextChange);
    _updateFechaTextController();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apPatCtrl.dispose();
    _apMatCtrl.dispose();
    _curpCtrl.dispose();
    _emailCtrl.dispose();
    _telefonoCtrl.dispose();
    _fechaTextCtrl.dispose();
    _fechaFocusNode.dispose();
    super.dispose();
  }

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
    ]..shuffle(rnd);
    return base.join();
  }

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
    _updateFechaTextController();
  }

  void _tryAutoFillCurp() {
    final nombre = _nombreCtrl.text.trim();
    final apPat = _apPatCtrl.text.trim();
    final apMat = _apMatCtrl.text.trim();
    final sexo = _sexo;
    final fecha = _fechaNac;
    final estado = _estadoNac;

    if (nombre.isEmpty || apPat.isEmpty || apMat.isEmpty) {
      if (_autoCurpGenerated) {
        setState(() => _autoCurpGenerated = false);
      }
      return;
    }
    if (sexo != 'H' && sexo != 'M') {
      if (_autoCurpGenerated) {
        setState(() => _autoCurpGenerated = false);
      }
      return;
    }
    if (fecha == null || estado == null) {
      if (_autoCurpGenerated) {
        setState(() => _autoCurpGenerated = false);
      }
      return;
    }

    final generated = generarCurp(
      nombre: nombre,
      apPat: apPat,
      apMat: apMat,
      sexo: sexo!,
      fechaNac: fecha,
      estadoNac: estado,
    );

    final current = _curpCtrl.text.trim().toUpperCase();
    if (current == generated) {
      if (!_autoCurpGenerated) {
        setState(() => _autoCurpGenerated = true);
      }
      return;
    }

    setState(() {
      _curpCtrl.value = TextEditingValue(
        text: generated,
        selection: TextSelection.collapsed(offset: generated.length),
      );
      _autoCurpGenerated = true;
    });
  }

  void _handleFechaTextChange() {
    if (_updatingFechaText) return;
    final parsed = _parseFechaFromText(_fechaTextCtrl.text);
    if (parsed != null && parsed != _fechaNac) {
      setState(() => _fechaNac = parsed);
      _tryAutoFillCurp();
    }
  }

  void _updateFechaTextController() {
    final text = _fechaNac == null
        ? ''
        : '${_fechaNac!.day.toString().padLeft(2, '0')}/${_fechaNac!.month.toString().padLeft(2, '0')}/${_fechaNac!.year}';
    if (_fechaTextCtrl.text == text) return;
    _updatingFechaText = true;
    _fechaTextCtrl.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    _updatingFechaText = false;
  }

  void _shiftFecha(int days) {
    final now = DateTime.now();
    final fallback = DateTime(now.year - 18, now.month, now.day);
    final current = _fechaNac ?? fallback;
    var updated = current.add(Duration(days: days));
    final minDate = DateTime(now.year - 80, now.month, now.day);
    final maxDate = DateTime(now.year - 12, now.month, now.day);
    if (updated.isBefore(minDate)) updated = minDate;
    if (updated.isAfter(maxDate)) updated = maxDate;
    setState(() => _fechaNac = updated);
    _updateFechaTextController();
    _tryAutoFillCurp();
  }

  DateTime? _parseFechaFromText(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      if (_fechaNac != null) {
        setState(() => _fechaNac = null);
        _tryAutoFillCurp();
      }
      return null;
    }

    DateTime? parsed;
    final slashMatch = RegExp(r'^(\d{2})[\/](\d{2})[\/](\d{4})$').firstMatch(trimmed);
    final dashMatch = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(trimmed);
    try {
      if (slashMatch != null) {
        final day = int.parse(slashMatch.group(1)!);
        final month = int.parse(slashMatch.group(2)!);
        final year = int.parse(slashMatch.group(3)!);
        parsed = DateTime(year, month, day);
      } else if (dashMatch != null) {
        final year = int.parse(dashMatch.group(1)!);
        final month = int.parse(dashMatch.group(2)!);
        final day = int.parse(dashMatch.group(3)!);
        parsed = DateTime(year, month, day);
      }
    } catch (_) {
      parsed = null;
    }

    if (parsed == null) return null;

    final now = DateTime.now();
    final minDate = DateTime(now.year - 80, now.month, now.day);
    final maxDate = DateTime(now.year - 12, now.month, now.day);
    if (parsed.isBefore(minDate) || parsed.isAfter(maxDate)) {
      return null;
    }
    return parsed;
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
      _updateFechaTextController();
      _tryAutoFillCurp();
    }
  }

    Future<void> _registerAspirante() async {
    if (_submitting) return;

    final nombre = _nombreCtrl.text.trim();
    final apPat = _apPatCtrl.text.trim();
    final apMat = _apMatCtrl.text.trim();
    final curp = _curpCtrl.text.trim().toUpperCase();
    final email = _emailCtrl.text.trim();
    final telefono = _telefonoCtrl.text.trim();

    // Validaciones estrictas
    if (nombre.isEmpty || apPat.isEmpty || apMat.isEmpty) {
      _showError('Nombre y apellidos son obligatorios');
      return;
    }
    if (_sexo == null || _fechaNac == null || _estadoNac == null) {
      _showError('Sexo, fecha y estado de nacimiento son obligatorios');
      return;
    }
    if (email.isEmpty ||
        !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      _showError('El correo electrónico es obligatorio y debe ser válido');
      return;
    }
    if (telefono.isEmpty || telefono.length < 10) {
      _showError('El teléfono es obligatorio y debe tener al menos 10 dígitos');
      return;
    }

    if (curp.isEmpty) {
      _showError('Completa tu CURP llenando los campos solicitados.');
      return;
    }

    if (!RegExp(r'^[A-Z]{4}\d{6}[HM][A-Z]{5}[A-Z0-9]\d$').hasMatch(curp)) {
      _showError('CURP inválida. Debe tener 18 caracteres y formato correcto.');
      return;
    }


    setState(() => _submitting = true);

    try {
      final body = {
        'nombre': nombre,
        'ap_paterno': apPat,
        'ap_materno': apMat,
        'curp': curp,
        'password': _genTempPassword(),
        'sexo': _sexo,
        'fecha_nacimiento':
            '${_fechaNac!.year}-${_fechaNac!.month.toString().padLeft(2, '0')}-${_fechaNac!.day.toString().padLeft(2, '0')}',
        'estado_nacimiento': _estadoNac,
        'email': email,
        'telefono': telefono,
        'step': 2,
      };

      final resp = await ApiClient.postJson('/aspirantes/start', body: body);

      final token = (resp['data']?['token'] ?? resp['token']) as String?;
      final user = (resp['data']?['user'] ?? resp['user']) as Map<String, dynamic>?;

      if (token == null || user == null) {
        throw Exception('Respuesta inválida del servidor');
      }

      final secure = const FlutterSecureStorage();
      await secure.write(key: 'auth_token', value: token);
      await secure.write(
        key: 'token_type',
        value: (resp['data']?['token_type'] ?? resp['token_type'] ?? 'Bearer')
            .toString(),
      );

      ProgressService.saveStep(2);

        final redirect =
          user['redirect_to']?.toString() ?? '/admision/bachillerato';
      if (!mounted) return;
      context.push(redirect);
    } catch (e) {
      if (!mounted) return;
      _showError('Error al registrar: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final tier = screenWidth < 640
                ? _FormTier.mobile
                : (screenWidth < 1100 ? _FormTier.compact : _FormTier.wide);
            final isMobile = tier == _FormTier.mobile;

            return Column(
              children: [
                Expanded(
                  child: Center(
                    child: Container(
                      width: constraints.maxWidth,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                                    BoxShadow(
                                      color: colors.shadow.withAlpha((0.1 * 255).round()),
                                      blurRadius: 12,
                                    ),
                        ],
                      ),
                      child: isMobile
                          ? _buildColumnLayout(context, tier)
                          : _buildRowLayout(context, tier),
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

  Widget _buildRowLayout(BuildContext context, _FormTier tier) {
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
              child: _formContent(context, tier: tier),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColumnLayout(BuildContext context, _FormTier tier) {
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
            child: _formContent(context, tier: tier),
          ),
        ),
      ],
    );
  }

  Widget _formContent(BuildContext context, {required _FormTier tier}) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final stacked = tier != _FormTier.wide;

    Widget curpNote() {
      if (!_autoCurpGenerated) return const SizedBox.shrink();
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: colors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'CURP generado, faltan los últimos caracteres asignados por la RENAPO',
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      );
    }

    final nombres = stacked
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

    final sexoFechaEstado = stacked
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

    final contacto = stacked
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _inputField(
                controller: _curpCtrl,
                label: 'CURP de 18 Dígitos',
                icon: Icons.password,
                keyboardType: TextInputType.visiblePassword,
                textCapitalization: TextCapitalization.characters,
                maxLength: 18,
              ),
              if (_autoCurpGenerated) ...[
                const SizedBox(height: 8),
                curpNote(),
              ],
              const SizedBox(height: 12),
              _inputField(
                controller: _emailCtrl,
                label: 'Correo Electrónico',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              _inputField(
                controller: _telefonoCtrl,
                label: 'Teléfono de contacto',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
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
                const SizedBox(width: 12),
                Expanded(
                  child: _inputField(
                    controller: _telefonoCtrl,
                    label: 'Teléfono de contacto',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ]),
              if (_autoCurpGenerated) ...[
                const SizedBox(height: 8),
                curpNote(),
              ],
            ],
          );

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
        Text('Necesitamos:\n1. Tus Datos Personales (CURP)\n2. Medios de Contacto (Correo y Teléfono)',
            style: textTheme.bodySmall),
        const SizedBox(height: 24),

        nombres,
        const SizedBox(height: 16),

        sexoFechaEstado,
        const SizedBox(height: 24),

        contacto,
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
    return SizedBox(
      width: double.infinity,
      child: DropdownButtonFormField<String>(
        key: ValueKey(_sexo),
        initialValue: _sexo,
        decoration: const InputDecoration(
          labelText: 'Sexo',
          prefixIcon: Icon(Icons.wc),
          border: OutlineInputBorder(),
        ),
        isExpanded: true,
        items: _sexoOptions.entries
            .map(
              (entry) => DropdownMenuItem<String>(
                value: entry.key,
                child: Text(entry.value),
              ),
            )
            .toList(),
        onChanged: (value) {
          setState(() => _sexo = value);
          _tryAutoFillCurp();
        },
      ),
    );
  }

  Widget _fechaNacField() {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.arrowUp): const _AdjustFechaIntent(1),
        LogicalKeySet(LogicalKeyboardKey.arrowDown): const _AdjustFechaIntent(-1),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _AdjustFechaIntent: CallbackAction<_AdjustFechaIntent>(
            onInvoke: (_AdjustFechaIntent intent) {
              _shiftFecha(intent.delta);
              return null;
            },
          ),
        },
        child: TextField(
          focusNode: _fechaFocusNode,
          controller: _fechaTextCtrl,
          keyboardType: TextInputType.datetime,
          decoration: InputDecoration(
            labelText: 'Fecha de nacimiento',
            prefixIcon: const Icon(Icons.cake_outlined),
            border: const OutlineInputBorder(),
            hintText: 'DD/MM/AAAA',
            suffixIcon: IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: _pickFechaNac,
            ),
          ),
        ),
      ),
    );
  }

Widget _estadoDropdown() {
  return SizedBox(
    width: double.infinity,
    child: DropdownButtonFormField<String>(
      key: ValueKey(_estadoNac),
      initialValue: _estadoNac,
      decoration: const InputDecoration(
        labelText: 'Estado de nacimiento',
        prefixIcon: Icon(Icons.location_on_outlined),
        border: OutlineInputBorder(),
      ),
      isExpanded: true,
      items: _estadosMx
          .map(
            (estado) => DropdownMenuItem<String>(
              value: estado['code']!,
              child: Text(estado['name']!),
            ),
          )
          .toList(),
      onChanged: (val) {
        setState(() => _estadoNac = val);
        _tryAutoFillCurp();
      },
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
  curp;

  return curp;
}
