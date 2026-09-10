import '../enums/tipo_habitacion.dart';
import '../enums/estado_habitacion.dart';

// Representa una habitación física del hotel.
// Responsabilidad única: guardar sus datos y su estado actual.
class Habitacion {
  final int numero;
  final TipoHabitacion tipo;
  EstadoHabitacion estado;

  Habitacion({
    required this.numero,
    required this.tipo,
    this.estado = EstadoHabitacion.disponible, // toda habitación nueva inicia disponible
  });

  int get capacidad => tipo.capacidadMaxima;

  bool get estaDisponible => estado == EstadoHabitacion.disponible;
  bool get estaReservada => estado == EstadoHabitacion.reservada;
  bool get estaOcupada => estado == EstadoHabitacion.ocupada;

  @override
  String toString() {
    return 'Habitación $numero (${tipo.nombre}) - ${estado.nombre} - Capacidad: $capacidad';
  }
}
