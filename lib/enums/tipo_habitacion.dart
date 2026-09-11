// Tipos de habitación que maneja el hotel.
// Cada tipo tiene una capacidad máxima de personas asociada.
enum TipoHabitacion {
  sencilla,
  doble,
  suite,
}

// Extensión para obtener datos útiles del enum sin llenar otras clases
// de "if" repetidos. Aquí centralizamos la capacidad por tipo.
extension TipoHabitacionInfo on TipoHabitacion {
  int get capacidadMaxima {
    switch (this) {
      case TipoHabitacion.sencilla:
        return 1;
      case TipoHabitacion.doble:
        return 2;
      case TipoHabitacion.suite:
        return 4;
    }
  }

  String get nombre {
    switch (this) {
      case TipoHabitacion.sencilla:
        return 'Sencilla';
      case TipoHabitacion.doble:
        return 'Doble';
      case TipoHabitacion.suite:
        return 'Suite';
    }
  }
}
