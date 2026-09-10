 
  List<Reserva> buscarReservasPorCedula(String cedula) {
    if (cedula.isEmpty) return [];
    
    try {
      return reservas.where((r) => r.huesped.cedula == cedula).toList();
    } catch (e) {
      
      return [];
    }
  }


  bool cancelarReserva(String idReserva) {
    try {
      final reserva = reservas.firstWhere((r) => r.id == idReserva);
      
      reservas.remove(reserva);
      
      return true;
    } on StateError {
      // firstWhere lanza un StateError si no encuentra nada.
      return false; 
    } catch (e) {
      return false;
    }
  }