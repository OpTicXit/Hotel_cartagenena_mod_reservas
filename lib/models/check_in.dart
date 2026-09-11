// Registra el evento de check-in de una habitación.
// No contiene lógica de validación (eso vive en Hotel), solo guarda la evidencia de que el evento ocurrió, para historial/consultas.
class CheckIn {
  final int numeroHabitacion;
  final int personas;
  final DateTime fecha;

  CheckIn({
    required this.numeroHabitacion,
    required this.personas,
    DateTime? fecha,
  }) : fecha = fecha ?? DateTime.now();

  @override
  String toString() {
    return 'Check-in Hab. $numeroHabitacion - $personas persona(s) - $fecha';
  }
}
