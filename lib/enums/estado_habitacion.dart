// Estados posibles de una habitación.
// El flujo obligatorio es:
// disponible -> reservada -> ocupada -> disponible
enum EstadoHabitacion {
  disponible,
  reservada,
  ocupada,
}

extension EstadoHabitacionInfo on EstadoHabitacion {
  String get nombre {
    switch (this) {
      case EstadoHabitacion.disponible:
        return 'Disponible';
      case EstadoHabitacion.reservada:
        return 'Reservada';
      case EstadoHabitacion.ocupada:
        return 'Ocupada';
    }
  }
}
