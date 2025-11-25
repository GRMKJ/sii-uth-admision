import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:siiadmision/admision/models/bachillerato_form_data.dart';
import 'package:siiadmision/config/api_client.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
    this.formData,
    this.sessionIdFromQuery,
    this.statusFromQuery,
  });

  final BachilleratoFormData? formData;
  final String? sessionIdFromQuery;
  final String? statusFromQuery;
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _storage = const FlutterSecureStorage();
  bool _launchingStripe = false;
  Map<String, dynamic>? _stripeStatus;
  String? _lastSessionId;
  String? _statusFlag;
  bool _checkingStripeStatus = false;
  BachilleratoFormData? _remoteFormData;
  bool _loadingProfile = false;
  String? _profileError;

  @override
  void initState() {
    super.initState();
    _initializeFromQuery();
    _loadAcademicDataIfNeeded();
  }

  @override
  void didUpdateWidget(covariant PaymentScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.sessionIdFromQuery != oldWidget.sessionIdFromQuery &&
        (widget.sessionIdFromQuery ?? '').isNotEmpty) {
      _lastSessionId = widget.sessionIdFromQuery;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _refreshStripeStatus(widget.sessionIdFromQuery);
      });
    }
    if (widget.statusFromQuery != oldWidget.statusFromQuery) {
      _statusFlag = widget.statusFromQuery;
    }

    if (oldWidget.formData != widget.formData && widget.formData == null) {
      _loadAcademicDataIfNeeded(force: true);
    }
  }

  void _initializeFromQuery() {
    _lastSessionId = widget.sessionIdFromQuery;
    _statusFlag = widget.statusFromQuery;
    if ((_lastSessionId ?? '').isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _refreshStripeStatus(_lastSessionId);
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final contentWidth = screenWidth.clamp(320.0, 1280.0);
                final isMobile = screenWidth < 640;

                return Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: Container(
                          width: contentWidth,
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
                              ? Column(
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
                                        child: _formContent(context),
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
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
                                      child: SingleChildScrollView(
                                        padding: const EdgeInsets.all(32),
                                        child: _formContent(context),
                                      ),
                                    ),
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
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 16, right: 16),
        child: FloatingActionButton(
          onPressed: _showHelpDialog,
          tooltip: 'Ayuda',
          child: const Icon(Icons.help_outline),
        ),
      ),
    );
  }

  Widget _formContent(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final summaryData = widget.formData ?? _remoteFormData;
    final selectionMissing = summaryData == null;
    final hasStripeSession = (_lastSessionId ?? '').isNotEmpty;
    final banner = _statusBanner(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pago de examen',
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          'Confirma tus datos y elige cómo realizar tu pago. Puedes iniciar un cobro seguro con Stripe o acudir a ventanilla.',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        if (banner != null) ...[
          banner,
          const SizedBox(height: 16),
        ],
        _buildSummarySection(context, summaryData),
        if (hasStripeSession) ...[
          const SizedBox(height: 16),
          _stripeStatusCard(context),
        ],
        const SizedBox(height: 24),
        _paymentOptions(context, selectionMissing),
      ],
    );
  }

  Widget _buildSummarySection(BuildContext context, BachilleratoFormData? summaryData) {
    if (summaryData != null) {
      return _selectionSummaryCard(context, summaryData);
    }

    if (_loadingProfile) {
      return _loadingSummaryCard(context);
    }

    if (_profileError != null) {
      return _summaryErrorCard(context);
    }

    return _missingSelectionCard(context);
  }

  Widget _loadingSummaryCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(color: colors.primary),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text('Recuperando tus datos guardados…'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryErrorCard(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No pudimos recuperar tus datos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_profileError ?? 'Error desconocido'),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _loadingProfile ? null : () => _loadAcademicDataIfNeeded(force: true),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _missingSelectionCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: colors.errorContainer,
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Falta información',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Antes de registrar tu pago debes elegir tu bachillerato de procedencia y la carrera a la que deseas aplicar.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _selectionSummaryCard(BuildContext context, BachilleratoFormData data) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: colors.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen de selección',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.school),
              title: const Text('Bachillerato'),
              subtitle: Text(data.bachilleratoDescripcion ?? data.bachilleratoId),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.school_outlined),
              title: const Text('Carrera'),
              subtitle: Text(data.carreraNombre ?? data.carreraId),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.grade),
              title: const Text('Promedio general'),
              subtitle: Text(data.promedio),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentOptions(BuildContext context, bool selectionMissing) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: colors.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.credit_card, size: 28, color: colors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Opción 1: Pago en línea (Stripe)",
                        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20, thickness: 1),
                const Text("Paga con tarjeta de crédito o débito mediante Stripe."),
                const SizedBox(height: 8),
                Text(
                  "Stripe aplica una comisión del 3.6 % sobre el monto de \$500.00, la cual se suma automáticamente antes de confirmar tu pago.",
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  "Después de completar el pago recibirás tu comprobante digital y podrás continuar con el registro sin acudir a la universidad.",
                  style: textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: selectionMissing
                      ? FilledButton(
                          onPressed: () => context.go('/admision/bachillerato'),
                          child: const Text('Capturar datos previos'),
                        )
                      : FilledButton.icon(
                          onPressed: _launchingStripe ? null : _startStripePayment,
                          icon: _launchingStripe
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colors.onPrimary,
                                  ),
                                )
                              : const Icon(Icons.credit_card),
                          label: Text(_launchingStripe ? 'Conectando…' : 'Pagar en Stripe (3.6 %)'),
                        ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.storefront, size: 28, color: colors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Opción 2: Pago en ventanilla",
                        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20, thickness: 1),
                const Text(
                  "Acude a la caja del edificio A de la Universidad Tecnológica de Huejotzingo para cubrir la cuota de \$500.00.",
                ),
                const SizedBox(height: 8),
                const Text("Lleva tu identificación y solicita registrar tu pago del examen de admisión."),
                const SizedBox(height: 8),
                const Text('Conserva tu comprobante sellado para seguimiento y validación en el sistema.'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _startStripePayment() async {
    final data = widget.formData ?? _remoteFormData;
    if (data == null) {
      if (!_loadingProfile) {
        _loadAcademicDataIfNeeded(force: true);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa primero tus datos de bachillerato.')),
      );
      context.go('/admision/bachillerato');
      return;
    }

    setState(() => _launchingStripe = true);
    try {
      final token = await _storage.read(key: 'auth_token');
      final response = await ApiClient.postJson(
        '/pagos/stripe/session',
        token: token,
        body: {
        },
      );
      final payload = _unwrapResponse(response);
      final checkoutUrl = _extractCheckoutUrl(payload);
      if (checkoutUrl == null) {
        throw Exception('No se recibió el enlace de Stripe.');
      }
      final createdSessionId = payload['session_id'] as String?;
      if (createdSessionId != null && mounted) {
        setState(() {
          _lastSessionId = createdSessionId;
          _stripeStatus = null;
          _statusFlag = null;
        });
      }
      final launched = await launchUrlString(
        checkoutUrl,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        throw Exception('No se pudo abrir la ventana de pago.');
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stripe se abrió en otra ventana. Completa el pago y regresa para consultar el estado.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo iniciar el pago: $e')),
      );
    } finally {
      if (mounted) setState(() => _launchingStripe = false);
    }
  }

  String? _extractCheckoutUrl(Map<String, dynamic> payload) {
    final candidates = <String?>[
      payload['url'] as String?,
      payload['checkout_url'] as String?,
      payload['redirect_url'] as String?,
      payload['checkoutUrl'] as String?,
    ];
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      candidates.addAll([
        data['url'] as String?,
        data['checkout_url'] as String?,
        data['redirect_url'] as String?,
        data['checkoutUrl'] as String?,
      ]);
    }
    for (final candidate in candidates) {
      if (candidate != null && candidate.isNotEmpty) {
        return candidate;
      }
    }
    return null;
  }

  Map<String, dynamic> _unwrapResponse(Map<String, dynamic> payload) {
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    return payload;
  }

  Future<void> _refreshStripeStatus([String? sessionId]) async {
    final targetSession = (sessionId ?? _lastSessionId);
    if (targetSession == null || targetSession.isEmpty) {
      return;
    }

    final wasPaid = _asInt(_stripeStatus?['estado_validacion']) == 1;

    setState(() => _checkingStripeStatus = true);
    try {
      final token = await _storage.read(key: 'auth_token');
      final response = await ApiClient.getJson('/pagos/stripe/session/$targetSession', token: token);
      final data = _unwrapResponse(response);
      final nowPaid = _asInt(data['estado_validacion']) == 1;

      if (!mounted) return;
      setState(() {
        _stripeStatus = data;
        _lastSessionId = data['session_id'] as String? ?? targetSession;
        if (nowPaid) {
          _statusFlag = 'success';
        }
      });

      if (nowPaid && !wasPaid && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pago confirmado. Puedes continuar con tus documentos.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo verificar tu pago: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _checkingStripeStatus = false);
      }
    }
  }

  Future<void> _loadAcademicDataIfNeeded({bool force = false}) async {
    if (!force) {
      if (widget.formData != null || _remoteFormData != null || _loadingProfile) {
        return;
      }
    } else if (_loadingProfile) {
      return;
    }

    final token = await _storage.read(key: 'auth_token');
    if (token == null) {
      if (mounted) {
        setState(() {
          _profileError = 'No se encontró la sesión. Inicia sesión nuevamente.';
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _loadingProfile = true;
        if (force) {
          _profileError = null;
        }
      });
    }

    try {
      final response = await ApiClient.getJson('/aspirantes/me', token: token);
      final payload = _unwrapResponse(response);
      final fetched = _mapAspiranteToFormData(payload);
      if (!mounted) return;
      setState(() {
        _remoteFormData = fetched;
        if (fetched != null) {
          _profileError = null;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _profileError = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _loadingProfile = false;
      });
    }
  }

  BachilleratoFormData? _mapAspiranteToFormData(Map<String, dynamic>? payload) {
    if (payload == null) return null;
    final bach = _asMap(payload['bachillerato']);
    final carrera = _asMap(payload['carrera']);
    final String? bachId = bach?['id']?.toString() ?? bach?['id_bachillerato']?.toString();
    final String? carreraId = carrera?['id']?.toString() ?? carrera?['id_carreras']?.toString();
    final promedioRaw = payload['promedio_general'];

    if (bachId == null || carreraId == null) {
      return null;
    }

    return BachilleratoFormData(
      bachilleratoId: bachId,
      bachilleratoDescripcion: _formatBachilleratoDescripcion(bach),
      carreraId: carreraId,
      carreraNombre: carrera?['carrera']?.toString(),
      promedio: promedioRaw?.toString() ?? '--',
    );
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, dynamic val) => MapEntry(key.toString(), val));
    }
    return null;
  }

  String? _formatBachilleratoDescripcion(Map<String, dynamic>? bach) {
    if (bach == null) return null;
    final nombre = bach['nombre']?.toString();
    if (nombre == null) return null;
    final municipio = bach['municipio']?.toString();
    final estado = bach['estado']?.toString();
    if (municipio == null || estado == null) {
      return nombre;
    }
    return '$nombre ($municipio, $estado)';
  }

  Widget? _statusBanner(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final status = _statusFlag;
    final paid = _asInt(_stripeStatus?['estado_validacion']) == 1;

    if (status == 'cancelled') {
      return _buildBanner(
        background: colors.errorContainer,
        foreground: colors.onErrorContainer,
        icon: Icons.warning_amber_rounded,
        title: 'Pago cancelado',
        body: 'Cancelaste la operación en Stripe. Puedes intentarlo de nuevo cuando estés listo.',
      );
    }

    if (status == 'success' && !paid) {
      return _buildBanner(
        background: colors.surfaceContainerHighest,
        foreground: colors.onSurfaceVariant,
        icon: Icons.hourglass_bottom,
        title: 'Regresaste de Stripe',
        body: 'Estamos esperando la confirmación final. Pulsa "Verificar mi pago" para actualizar el estado.',
      );
    }

    if (paid && status != 'success') {
      return _buildBanner(
        background: colors.tertiaryContainer,
        foreground: colors.onTertiaryContainer,
        icon: Icons.verified,
        title: 'Pago validado',
        body: 'Tu pago fue reconocido correctamente. En breve podrás avanzar al siguiente paso.',
      );
    }

    return null;
  }

  Widget _buildBanner({
    required Color background,
    required Color foreground,
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Card(
      color: background,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: foreground),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: foreground)),
                  const SizedBox(height: 4),
                  Text(body, style: TextStyle(color: foreground)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stripeStatusCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final status = _stripeStatus;
    final sessionId = _lastSessionId ?? '--';
    final hasData = status != null;
    final paid = hasData && _asInt(status['estado_validacion']) == 1;
    final cardColor = paid ? colors.tertiaryContainer : colors.surfaceContainerHighest;
    final icon = paid ? Icons.task_alt : Icons.receipt_long;
    final onColor = paid ? colors.onTertiaryContainer : colors.onSurface;

    final resolvedStatus = status ?? const <String, dynamic>{};
    final reference = (resolvedStatus['referencia'] as String?) ?? 'En proceso';
    final amount = hasData ? _formatCurrency(resolvedStatus['monto_pagado'], resolvedStatus['currency']) : '--';
    final updated = hasData ? _formatTimestamp(resolvedStatus['updated_at']) : '--';

    final description = hasData
        ? (paid
            ? 'Stripe confirmó tu pago y lo asignó a tu expediente.'
            : 'Stripe recibió tu solicitud y está validándola con el banco. Puede tardar un par de minutos.')
        : 'Regresaste del portal de Stripe. Verifica tu sesión para conocer el resultado.';

    return Card(
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: onColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    paid ? 'Pago confirmado' : 'Pago en validación',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: onColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: textTheme.bodyMedium?.copyWith(color: onColor.withOpacity(0.9)),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 24,
              runSpacing: 12,
              children: [
                _statusMetric(context, label: 'ID de sesión', value: sessionId, foreground: onColor),
                _statusMetric(context, label: 'Referencia', value: reference, foreground: onColor),
                _statusMetric(context, label: 'Monto pagado', value: amount, foreground: onColor),
                _statusMetric(context, label: 'Última actualización', value: updated, foreground: onColor),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonalIcon(
                onPressed: _checkingStripeStatus ? null : () => _refreshStripeStatus(),
                icon: _checkingStripeStatus
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: onColor),
                      )
                    : const Icon(Icons.refresh),
                label: Text(_checkingStripeStatus ? 'Verificando…' : 'Verificar mi pago'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusMetric(
    BuildContext context, {
    required String label,
    required String value,
    Color? foreground,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final labelStyle = textTheme.labelSmall?.copyWith(color: foreground?.withOpacity(0.8));
    final valueStyle = textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w600,
      color: foreground,
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 160),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: labelStyle),
          const SizedBox(height: 4),
          SelectableText(value, style: valueStyle),
        ],
      ),
    );
  }

  String _formatCurrency(dynamic amount, dynamic currency) {
    if (amount == null) return '--';
    final double? value = amount is num ? amount.toDouble() : double.tryParse(amount.toString());
    if (value == null) return '--';
    final code = (currency ?? 'MXN').toString().toUpperCase();
    final amountText = value.toStringAsFixed(2);
    return '\$' + amountText + ' ' + code;
  }

  String _formatTimestamp(dynamic isoString) {
    if (isoString == null) return '--';
    final date = DateTime.tryParse(isoString.toString());
    if (date == null) return '--';
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)}/${date.year} ${two(date.hour)}:${two(date.minute)}';
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
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
              child: Text(
                '¿Necesitas ayuda?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
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
