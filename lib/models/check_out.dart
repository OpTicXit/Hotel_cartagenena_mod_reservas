// Registra el evento de check-out de una habitación.
// Igual que CheckIn: es solo evidencia/historial, sin lógica de negocio.
class CheckOut {
  final int numeroHabitacion;
  final DateTime fecha;

  CheckOut({
    required this.numeroHabitacion,
    DateTime? fecha,
  }) : fecha = fecha ?? DateTime.now();

  @override
  String toString() {
    return 'Check-out Hab. $numeroHabitacion - $fecha';
  }
}
