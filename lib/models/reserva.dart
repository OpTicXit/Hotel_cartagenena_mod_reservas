import 'huesped.dart';

// Representa una reserva activa o cerrada de una habitación.
// Guarda quién reservó, qué habitación y por cuántos días.
class Reserva {
  final Huesped huesped;
  final int numeroHabitacion;
  final int dias;
  bool activa; // true mientras la reserva no se cierre con check-out

  Reserva({
    required this.huesped,
    required this.numeroHabitacion,
    required this.dias,
    this.activa = true,
  });

  @override
  String toString() {
    final estado = activa ? 'Activa' : 'Cerrada';
    return 'Reserva Hab. $numeroHabitacion - $huesped - $dias día(s) - $estado';
  }
}
