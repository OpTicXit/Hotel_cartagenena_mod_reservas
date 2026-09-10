// Representa al huésped que hace la reserva.
// Clase simple: solo guarda datos, no toma decisiones de negocio.
class Huesped {
  final String nombre;
  final String cedula;

  Huesped({
    required this.nombre,
    required this.cedula,
  });

  @override
  String toString() => '$nombre (CC: $cedula)';
}
