import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:siiadmision/config/aspirante_progress.dart';
import 'package:siiadmision/config/api_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dropdown_search/dropdown_search.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _referenceController = TextEditingController();
  final _bachilleratoCtrl = TextEditingController();
  final _municipioCtrl = TextEditingController();
  final _estadoCtrl = TextEditingController();
  final _promedioCtrl = TextEditingController();

  final storage = FlutterSecureStorage();

  String? _selectedCarrera;
  List<Map<String, dynamic>> _carreras = [];
  bool _loadingCarreras = true;
  String? _errorMessage;

  String? _selectedBachillerato;
  List<Map<String, dynamic>> _bachilleratos = [];
  bool _loadingBachilleratos = true;

  @override
  void initState() {
    super.initState();
    _fetchCarreras();
    _fetchBachilleratos();
  }

  Future<void> _fetchCarreras() async {
    final token = await storage.read(key: 'auth_token');

    try {
      final data = await ApiClient.getJson("/catalogos/carreras", token: token);

      final List carrerasData = (data.containsKey("data"))
          ? data["data"]
          : data;

      setState(() {
        _carreras = carrerasData
            .map((c) => {"id": c["id_carreras"], "nombre": c["carrera"]})
            .toList();
        _loadingCarreras = false;
      });
    } catch (e) {
      setState(() {
        _loadingCarreras = false;
        _errorMessage =
            "No se pudieron cargar las carreras. Intenta más tarde.\n$e";
      });
    }
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _bachilleratoCtrl.dispose();
    _municipioCtrl.dispose();
    _estadoCtrl.dispose();
    _promedioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Builder(
      builder: (context) {
        return Scaffold(
          backgroundColor: colors.surfaceContainerLowest,
          body: Row(
            children: [
              Expanded(
                child: SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final screenWidth = constraints.maxWidth;
                      final margin = screenWidth * 0.05;
                      final contentWidth = screenWidth.clamp(320.0, 1280.0);
                      final isMobile = screenWidth < 640;

                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: margin),
                        child: Column(
                          children: [
                            const SizedBox(height: 24),
                            Expanded(
                              child: Center(
                                child: Container(
                                  width: contentWidth,
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
                                      ? Column(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                    topLeft: Radius.circular(
                                                      24,
                                                    ),
                                                    topRight: Radius.circular(
                                                      24,
                                                    ),
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
                                                padding: const EdgeInsets.all(
                                                  24,
                                                ),
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
                                                borderRadius:
                                                    const BorderRadius.only(
                                                      topLeft: Radius.circular(
                                                        24,
                                                      ),
                                                      bottomLeft:
                                                          Radius.circular(24),
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
                                                padding: const EdgeInsets.all(
                                                  24,
                                                ),
                                                child: _formContent(context),
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showHelpDialog,
            tooltip: 'Ayuda',
            child: const Icon(Icons.help_outline),
          ),
        );
      },
    );
  }

  Widget _formContent(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (_loadingCarreras || _loadingBachilleratos) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
      );
    }

    return SingleChildScrollView(
      // 🔹 Aquí envolvemos todo para evitar overflow
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Admisión 2025',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Antes de continuar, necesitamos los datos de tu Bachillerato de procedencia:',
          ),
          const SizedBox(height: 16),

          DropdownSearch<Map<String, dynamic>>(
            items: [
              ..._bachilleratos,
              {
                "id": "otro",
                "nombre": "➕ Otro (Agregar nuevo)",
              }, // 👈 añadimos opción "Otro"
            ],
            selectedItem: _bachilleratos.firstWhere(
              (b) => b['id'].toString() == _selectedBachillerato,
              orElse: () => <String, dynamic>{},
            ),
            itemAsString: (Map<String, dynamic>? item) {
              if (item == null) return "";
              final nombre = item["nombre"];
              return nombre != null ? nombre.toString() : "";
            },
            onChanged: (value) async {
              if (value?["id"] == "otro") {
                final nuevo = await _showAddBachilleratoDialog();
                if (nuevo != null) {
                  setState(() {
                    // 👇 añadimos con el mismo formato que el API
                    final nuevoBachillerato = {
                      "id": nuevo["id_bachillerato"].toString(),
                      "nombre":
                          "${nuevo["nombre"]} (${nuevo["municipio"]}, ${nuevo["estado"]})",
                    };
                    _bachilleratos.add(nuevoBachillerato);

                    // 👇 seleccionamos inmediatamente el nuevo
                    _selectedBachillerato = nuevoBachillerato["id"];
                  });
                }
              } else {
                setState(() {
                  _selectedBachillerato = value?["id"]?.toString();
                });
              }
            },

            dropdownDecoratorProps: const DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                labelText: "Bachillerato",
                prefixIcon: Icon(Icons.school),
                border: OutlineInputBorder(),
              ),
            ),
            popupProps: const PopupProps.menu(showSearchBox: true),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: _promedioCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Promedio General',
              prefixIcon: Icon(Icons.grade),
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 24),

          // 🔹 Card con datos de depósito
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Row(
                    children: [
                      Icon(Icons.account_balance, size: 28),
                      SizedBox(width: 8),
                      Text(
                        'Datos de Depósito',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 20, thickness: 1),
                  Text('Banco: SANTANDER'),
                  Text('Nombre: UNIVERSIDAD TECNOLÓGICA DE HUEJOTZINGO'),
                  Text('Número de Cuenta: 6551 0840 686'),
                  Text('CLABE: 0146 5065 5108 4068 63'),
                  Text('Cantidad: 500.00'),
                  SizedBox(height: 8),
                  Text(
                    'NOTA: Verifique y realice correctamente su pago ya que no aplica devolución o reembolso por cualquier motivo.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Text('Selecciona la carrera a la que deseas aplicar:'),
          const SizedBox(height: 8),

          DropdownButtonFormField<String>(
            value: _selectedCarrera,
            items: _carreras
                .map(
                  (carrera) => DropdownMenuItem<String>(
                    value: carrera["id"].toString(),
                    child: Text(
                      carrera["nombre"],
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                )
                .toList(),
            decoration: const InputDecoration(
              labelText: 'Carrera',
              prefixIcon: Icon(Icons.school_outlined),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() => _selectedCarrera = value),
            isExpanded: true,
          ),

          const SizedBox(height: 16),
          const Text(
            'Una vez realizado el pago, registra tu referencia de pago',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _referenceController,
            decoration: const InputDecoration(
              labelText: 'Referencia de Pago',
              prefixIcon: Icon(Icons.confirmation_number),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),

          Align(
            alignment: Alignment.bottomRight,
            child: FilledButton(
              onPressed: _submitForm,
              child: const Text('Siguiente'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_referenceController.text.isEmpty ||
        _selectedCarrera == null ||
        _selectedBachillerato == null || // 👈 usamos variable de selección
        _promedioCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos obligatorios')),
      );
      return;
    }

    try {
      final token = await storage.read(key: 'auth_token');


      await ApiClient.postJson(
        "/aspirantes/pago",
        token: token,
        body: {
          "bachillerato_id": _selectedBachillerato,
          "promedio": _promedioCtrl.text,
          "carrera_id": _selectedCarrera,
          "referencia": _referenceController.text,
        },
      );

      _showConfirmationDialog();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al registrar: $e")));
    }
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

  Future<void> _fetchBachilleratos() async {
    final token = await storage.read(key: 'auth_token');
    try {
      final response = await ApiClient.getJson(
        "/catalogos/bachilleratos",
        token: token,
      );

      final List<dynamic> lista = response["data"]; // 👈 aquí tomamos el array

      setState(() {
        _bachilleratos = lista
            .map(
              (b) => {
                "id":
                    b["id"], // ⚠️ en tu respuesta viene "id", no "id_bachillerato"
                "nombre": "${b["nombre"]} (${b["municipio"]}, ${b["estado"]})",
              },
            )
            .toList();
        _loadingBachilleratos = false;
      });
    } catch (e) {
      setState(() {
        _loadingBachilleratos = false;
      });
    }
  }

  void _showConfirmationDialog() {
    bool accepted = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              contentPadding: const EdgeInsets.all(24),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.receipt_long_rounded, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Confirmación de Pago',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Como confirmación de este paso, 5 días hábiles posteriores debes recibir\ncorreo electrónico de confirmación de pre registro con\nla instrucción para registro al examen de admisión.\n\nDe lo contrario, comunícate a:',
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 8),
                  const SelectableText('aspirante@uth.edu.mx'),
                  const Text('Tels. 227 275 9311'),
                  const Text('Tels. 227 275 9313'),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Acepto que los datos proporcionados son correctos',
                    ),
                    value: accepted,
                    onChanged: (val) => setState(() => accepted = val ?? false),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: accepted
                      ? () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Registro confirmado'),
                            ),
                          );
                          ProgressService.saveStep(3);
                          context.push('/admision/pagoexamen/status');
                        }
                      : null,
                  child: const Text('Acepto'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _showAddBachilleratoDialog() async {
    final nombreCtrl = TextEditingController();
    String? selectedEstado;
    String? selectedMunicipio;

    // 🔹 Datos simulados (reemplázalos por API si ya tienes endpoint)
    final estados = ["Puebla", "Tlaxcala", "CDMX"];
    final municipios = {
      "Puebla": ["Huejotzingo", "San Martín", "Cholula", "Puebla"],
      "Tlaxcala": ["Apizaco", "Huamantla"],
      "CDMX": ["Coyoacán", "Iztapalapa"],
    };

    return await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text("Agregar Bachillerato"),
              content: SizedBox(
                width:
                    MediaQuery.of(context).size.width * 0.85, // 👈 ancho mayor
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nombreCtrl,
                        decoration: const InputDecoration(
                          labelText: "Nombre",
                          prefixIcon: Icon(Icons.school),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedEstado,
                        decoration: const InputDecoration(
                          labelText: "Estado",
                          prefixIcon: Icon(Icons.map),
                          border: OutlineInputBorder(),
                        ),
                        items: estados
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedEstado = val;
                            selectedMunicipio = null; // reset al cambiar estado
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedMunicipio,
                        decoration: const InputDecoration(
                          labelText: "Municipio",
                          prefixIcon: Icon(Icons.location_city),
                          border: OutlineInputBorder(),
                        ),
                        items:
                            (selectedEstado != null
                                    ? municipios[selectedEstado] ?? []
                                    : [])
                                .map(
                                  (m) => DropdownMenuItem<String>(
                                    value: m,
                                    child: Text(m),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedMunicipio = val;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar"),
                ),
                FilledButton(
                  onPressed: () async {
                    if (nombreCtrl.text.isEmpty ||
                        selectedEstado == null ||
                        selectedMunicipio == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Completa todos los campos"),
                        ),
                      );
                      return;
                    }

                    try {
                      final token = await storage.read(key: 'auth_token');
                      final nuevo = await ApiClient.postJson(
                        "/catalogos/bachilleratos",
                        token: token,
                        body: {
                          "nombre": nombreCtrl.text,
                          "estado": selectedEstado,
                          "municipio": selectedMunicipio,
                        },
                      );
                      Navigator.pop(context, nuevo["data"]);
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text("Error: $e")));
                    }
                  },
                  child: const Text("Guardar"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
