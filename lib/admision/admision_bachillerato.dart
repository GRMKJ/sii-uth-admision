import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:siiadmision/admision/models/bachillerato_form_data.dart';
import 'package:siiadmision/config/api_client.dart';

class BachilleratoScreen extends StatefulWidget {
	const BachilleratoScreen({super.key});

	@override
	State<BachilleratoScreen> createState() => _BachilleratoScreenState();
}

class _BachilleratoScreenState extends State<BachilleratoScreen> {
	final _promedioCtrl = TextEditingController();
	final _storage = const FlutterSecureStorage();

	String? _selectedCarreraId;
	String? _selectedCarreraNombre;
	String? _selectedBachilleratoId;
	String? _selectedBachilleratoNombre;

	List<Map<String, dynamic>> _carreras = [];
	List<Map<String, dynamic>> _bachilleratos = [];
	bool _loadingCarreras = true;
	bool _loadingBachilleratos = true;
	String? _error;
	bool _savingAcademic = false;

	@override
	void initState() {
		super.initState();
		_fetchCarreras();
		_fetchBachilleratos();
	}

	@override
	void dispose() {
		_promedioCtrl.dispose();
		super.dispose();
	}

	Future<void> _fetchCarreras() async {
		final token = await _storage.read(key: 'auth_token');
		try {
			final data = await ApiClient.getJson('/catalogos/carreras', token: token);
			final List carrerasData = data.containsKey('data') ? data['data'] : data;
			setState(() {
				_carreras = carrerasData
						.map((c) => {
									'id': c['id_carreras'],
									'nombre': c['carrera'],
								})
						.cast<Map<String, dynamic>>()
						.toList();
				_loadingCarreras = false;
			});
		} catch (e) {
			setState(() {
				_loadingCarreras = false;
				_error = 'No se pudieron cargar las carreras. Intenta más tarde.\n$e';
			});
		}
	}

	Future<void> _fetchBachilleratos() async {
		final token = await _storage.read(key: 'auth_token');
		try {
			final response = await ApiClient.getJson('/catalogos/bachilleratos', token: token);
			final List<dynamic> lista = response['data'];
			setState(() {
				_bachilleratos = lista
						.map((b) => {
									'id': b['id'],
									'nombre': '${b['nombre']} (${b['municipio']}, ${b['estado']})',
								})
						.cast<Map<String, dynamic>>()
						.toList();
				_loadingBachilleratos = false;
			});
		} catch (e) {
			setState(() {
				_loadingBachilleratos = false;
				_error = 'No se pudieron cargar los bachilleratos. Intenta más tarde.\n$e';
			});
		}
	}

	Map<String, dynamic>? _findById(List<Map<String, dynamic>> source, String? id) {
		if (id == null) return null;
		for (final item in source) {
			if (item['id'].toString() == id) return item;
		}
		return null;
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
          onPressed: () => _showHelpDialog(context),
          tooltip: 'Ayuda',
          child: const Icon(Icons.help_outline),
        ),
      ),
		);
	}

		void _showHelpDialog(BuildContext context) {
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

	Widget _formContent(BuildContext context) {
		final textTheme = Theme.of(context).textTheme;

		if (_loadingCarreras || _loadingBachilleratos) {
			return const Center(child: CircularProgressIndicator());
		}

		if (_error != null) {
			return Column(
				mainAxisSize: MainAxisSize.min,
				children: [
					Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
					const SizedBox(height: 12),
					Text(
						_error!,
						textAlign: TextAlign.center,
					),
					const SizedBox(height: 16),
					FilledButton(
						onPressed: () {
							setState(() {
								_error = null;
								_loadingCarreras = true;
								_loadingBachilleratos = true;
							});
							_fetchCarreras();
							_fetchBachilleratos();
						},
						child: const Text('Reintentar'),
					),
				],
			);
		}

		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Text(
					'Datos académicos',
					style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
				),
				const SizedBox(height: 12),
				const Text('Selecciona tu bachillerato de procedencia, promedio y carrera de interés.'),
				const SizedBox(height: 24),
				DropdownSearch<Map<String, dynamic>>(
					items: [
						..._bachilleratos,
						{
							'id': 'otro',
							'nombre': '➕ Otro (Agregar nuevo)',
						},
					],
					selectedItem: _findById(_bachilleratos, _selectedBachilleratoId),
					itemAsString: (item) {
						final nombre = item['nombre'];
						return nombre == null ? '' : nombre.toString();
					},
					onChanged: (value) async {
						if (value == null) return;
						if (value['id'] == 'otro') {
							final nuevo = await _showAddBachilleratoDialog();
							if (nuevo != null) {
								setState(() {
									final formatted = {
										'id': nuevo['id_bachillerato'].toString(),
										'nombre': '${nuevo['nombre']} (${nuevo['municipio']}, ${nuevo['estado']})',
									};
									_bachilleratos.add(formatted);
									_selectedBachilleratoId = formatted['id'];
									_selectedBachilleratoNombre = formatted['nombre'];
								});
							}
						} else {
							setState(() {
								_selectedBachilleratoId = value['id'].toString();
								_selectedBachilleratoNombre = value['nombre']?.toString();
							});
						}
					},
					dropdownDecoratorProps: const DropDownDecoratorProps(
						dropdownSearchDecoration: InputDecoration(
							labelText: 'Bachillerato',
							prefixIcon: Icon(Icons.school),
							border: OutlineInputBorder(),
						),
					),
					popupProps: const PopupProps.menu(showSearchBox: true),
				),
				const SizedBox(height: 16),
				TextField(
					controller: _promedioCtrl,
					keyboardType: const TextInputType.numberWithOptions(decimal: true),
					decoration: const InputDecoration(
						labelText: 'Promedio general',
						prefixIcon: Icon(Icons.grade),
						border: OutlineInputBorder(),
					),
				),
				const SizedBox(height: 16),
				DropdownButtonFormField<String>(
					initialValue: _selectedCarreraId,
					items: _carreras
							.map(
								(c) => DropdownMenuItem<String>(
									value: c['id'].toString(),
									child: Text(
										c['nombre'],
										overflow: TextOverflow.ellipsis,
									),
								),
							)
							.toList(),
					isExpanded: true,
					decoration: const InputDecoration(
						labelText: 'Carrera',
						prefixIcon: Icon(Icons.school_outlined),
						border: OutlineInputBorder(),
					),
					onChanged: (value) {
						if (value == null) return;
						final carrera = _findById(_carreras, value);
						setState(() {
							_selectedCarreraId = value;
							_selectedCarreraNombre = carrera?['nombre']?.toString();
						});
					},
				),
				const SizedBox(height: 24),
				Align(
					alignment: Alignment.bottomRight,
					child: FilledButton(
						onPressed: _savingAcademic ? null : _goToPayment,
						child: _savingAcademic
								? const SizedBox(
										width: 24,
										height: 24,
										child: CircularProgressIndicator(strokeWidth: 2),
								)
								: const Text('Continuar al pago'),
					),
				),
			],
		);
	}

			Future<void> _goToPayment() async {
				if (_savingAcademic) return;
				final messenger = ScaffoldMessenger.of(context);

				final promedio = _promedioCtrl.text.trim();
				if (_selectedBachilleratoId == null || _selectedCarreraId == null || promedio.isEmpty) {
					messenger.showSnackBar(
						const SnackBar(content: Text('Completa bachillerato, promedio y carrera.')),
					);
					return;
				}

				final promedioValue = double.tryParse(promedio.replaceAll(',', '.'));
				if (promedioValue == null || promedioValue < 0 || promedioValue > 10) {
					messenger.showSnackBar(
						const SnackBar(content: Text('Ingresa un promedio válido entre 0 y 10.')),
					);
					return;
				}

				final bachilleratoId = int.tryParse(_selectedBachilleratoId ?? '');
				final carreraId = int.tryParse(_selectedCarreraId ?? '');
				if (bachilleratoId == null || carreraId == null) {
					messenger.showSnackBar(
						const SnackBar(content: Text('Ocurrió un error al interpretar tus selecciones. Vuelve a elegirlas.')),
					);
					return;
				}

				final token = await _storage.read(key: 'auth_token');
				if (token == null) {
					messenger.showSnackBar(
						const SnackBar(content: Text('No se encontró la sesión. Inicia sesión nuevamente.')),
					);
					return;
				}

				setState(() => _savingAcademic = true);
				try {
					await ApiClient.postJson(
						'/aspirantes/academico',
						token: token,
						body: {
							'id_bachillerato': _selectedBachilleratoId,
							'promedio_general': promedioValue,
							'id_carrera': _selectedCarreraId,
						},
					);
          
					final data = BachilleratoFormData(
						bachilleratoId: _selectedBachilleratoId!,
						bachilleratoDescripcion: _selectedBachilleratoNombre,
						carreraId: _selectedCarreraId!,
						carreraNombre: _selectedCarreraNombre,
						promedio: promedio,
					);

					if (!mounted) return;
					context.push('/admision/pagoexamen', extra: data);
				} catch (e) {
					if (!mounted) return;
					messenger.showSnackBar(
						SnackBar(content: Text('Error al guardar tus datos: $e')),
					);
				} finally {
					if (mounted) {
						setState(() => _savingAcademic = false);
					}
				}
	}

	Future<Map<String, dynamic>?> _showAddBachilleratoDialog() async {
		final nombreCtrl = TextEditingController();
		String? selectedEstado;
		String? selectedMunicipio;
		const estados = ['Puebla', 'Tlaxcala', 'CDMX'];
		const municipios = {
			'Puebla': ['Huejotzingo', 'San Martín', 'Cholula', 'Puebla'],
			'Tlaxcala': ['Apizaco', 'Huamantla'],
			'CDMX': ['Coyoacán', 'Iztapalapa'],
		};

		return showDialog<Map<String, dynamic>>(
			context: context,
			builder: (context) {
				return StatefulBuilder(
					builder: (context, setState) {
						return AlertDialog(
							shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
							title: const Text('Agregar bachillerato'),
							content: SizedBox(
								width: MediaQuery.of(context).size.width * 0.8,
								child: SingleChildScrollView(
									child: Column(
										mainAxisSize: MainAxisSize.min,
										children: [
											TextField(
												controller: nombreCtrl,
												decoration: const InputDecoration(
													labelText: 'Nombre',
													prefixIcon: Icon(Icons.school),
													border: OutlineInputBorder(),
												),
											),
											const SizedBox(height: 16),
										DropdownButtonFormField<String>(
											initialValue: selectedEstado,
												decoration: const InputDecoration(
													labelText: 'Estado',
													prefixIcon: Icon(Icons.map),
													border: OutlineInputBorder(),
												),
												items: estados
														.map((e) => DropdownMenuItem(value: e, child: Text(e)))
														.toList(),
												onChanged: (val) => setState(() {
													selectedEstado = val;
													selectedMunicipio = null;
												}),
											),
											const SizedBox(height: 16),
										DropdownButtonFormField<String>(
											initialValue: selectedMunicipio,
												decoration: const InputDecoration(
													labelText: 'Municipio',
													prefixIcon: Icon(Icons.location_city),
													border: OutlineInputBorder(),
												),
												items: (selectedEstado != null ? municipios[selectedEstado] ?? [] : [])
														.map(
															(m) => DropdownMenuItem<String>(
																value: m,
																child: Text(m),
															),
														)
														.toList(),
												onChanged: (val) => setState(() => selectedMunicipio = val),
											),
										],
									),
								),
							),
							actions: [
								TextButton(
									onPressed: () => Navigator.pop(context),
									child: const Text('Cancelar'),
								),
								FilledButton(
									onPressed: () async {
										if (nombreCtrl.text.isEmpty || selectedEstado == null || selectedMunicipio == null) {
											ScaffoldMessenger.of(context).showSnackBar(
												const SnackBar(content: Text('Completa todos los campos.')),
											);
											return;
										}
										try {
											final token = await _storage.read(key: 'auth_token');
											final nuevo = await ApiClient.postJson(
												'/catalogos/bachilleratos',
												token: token,
												body: {
													'nombre': nombreCtrl.text,
													'estado': selectedEstado,
													'municipio': selectedMunicipio,
												},
											);
											if (!context.mounted) return;
											Navigator.pop(context, nuevo['data']);
										} catch (e) {
											if (!context.mounted) return;
											ScaffoldMessenger.of(context).showSnackBar(
												SnackBar(content: Text('Error: $e')),
											);
										}
									},
									child: const Text('Guardar'),
								),
							],
						);
					},
				);
			},
		);
	}
}
