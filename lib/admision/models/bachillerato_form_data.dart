class BachilleratoFormData {
  final String bachilleratoId;
  final String carreraId;
  final String promedio;
  final String? bachilleratoDescripcion;
  final String? carreraNombre;

  const BachilleratoFormData({
    required this.bachilleratoId,
    required this.carreraId,
    required this.promedio,
    this.bachilleratoDescripcion,
    this.carreraNombre,
  });
}
