import '../models/habitacion.dart';
import '../models/huesped.dart';
import '../models/recepcionista.dart';
import '../models/reserva.dart';
import '../models/check_in.dart';
import '../models/check_out.dart';
import '../enums/tipo_habitacion.dart';
import '../enums/estado_habitacion.dart';

// Clase Hotel: contiene TODA la lógica de negocio (reglas, validaciones,
// cambios de estado). No pregunta ni imprime nada por consola: solo
// recibe datos, decide y devuelve un resultado. Esto permite que la
// interfaz de consola (sistema_hotel.dart) y las pruebas (test/) puedan
// usarla sin duplicar reglas.
class Hotel {
  final List<Habitacion> habitaciones = [];
  final List<Recepcionista> recepcionistas = [];
  final List<Reserva> reservas = [];
  final List<CheckIn> checkIns = [];
  final List<CheckOut> checkOuts = [];

  Hotel() {
    _crearHabitacionesIniciales();
  }

  // Carga inicial de habitaciones del hotel. Ajusten cantidad/números
  // libremente; esto no afecta el resto del sistema.
  void _crearHabitacionesIniciales() {
    habitaciones.add(Habitacion(numero: 101, tipo: TipoHabitacion.sencilla));
    habitaciones.add(Habitacion(numero: 102, tipo: TipoHabitacion.sencilla));
    habitaciones.add(Habitacion(numero: 201, tipo: TipoHabitacion.doble));
    habitaciones.add(Habitacion(numero: 202, tipo: TipoHabitacion.doble));
    habitaciones.add(Habitacion(numero: 301, tipo: TipoHabitacion.suite));
  }

  // ---------------------------------------------------------------
  // RF01 y RF02: Registro de recepcionistas e inicio de sesión
  // ---------------------------------------------------------------

  // Devuelve true si el registro fue exitoso.
  // Falla si ya existe un usuario con el mismo nombre.
  bool registrarRecepcionista(String usuario, String contrasena) {
    final yaExiste = recepcionistas.any((r) => r.usuario == usuario);
    if (yaExiste) return false;

    recepcionistas.add(Recepcionista(usuario: usuario, contrasena: contrasena));
    return true;
  }

  // Devuelve true si las credenciales son correctas.
  bool iniciarSesion(String usuario, String contrasena) {
    return recepcionistas.any(
      (r) => r.usuario == usuario && r.contrasena == contrasena,
    );
  }

  // ---------------------------------------------------------------
  // RF03: Consultar habitaciones disponibles
  // ---------------------------------------------------------------

  List<Habitacion> habitacionesDisponibles() {
    return habitaciones.where((h) => h.estaDisponible).toList();
  }

  // Agrupa las habitaciones disponibles por tipo, tal como pide RF03.
  Map<TipoHabitacion, List<Habitacion>> habitacionesDisponiblesPorTipo() {
    final Map<TipoHabitacion, List<Habitacion>> agrupadas = {};
    for (final tipo in TipoHabitacion.values) {
      agrupadas[tipo] = habitacionesDisponibles()
          .where((h) => h.tipo == tipo)
          .toList();
    }
    return agrupadas;
  }

  // ---------------------------------------------------------------
  // RF04 y RF05: Reservar habitación con validaciones
  // ---------------------------------------------------------------

  // Busca una habitación por su número. Devuelve null si no existe.
  Habitacion? buscarHabitacion(int numero) {
    for (final h in habitaciones) {
      if (h.numero == numero) return h;
    }
    return null;
  }

  // Intenta crear una reserva. Devuelve un mensaje de resultado para
  // que la interfaz de consola lo muestre (así Hotel no depende de print).
  String reservarHabitacion({
    required Huesped huesped,
    required int numeroHabitacion,
    required int dias,
  }) {
    final habitacion = buscarHabitacion(numeroHabitacion);

    if (habitacion == null) {
      return 'Error: la habitación $numeroHabitacion no existe.';
    }
    if (!habitacion.estaDisponible) {
      return 'Error: la habitación $numeroHabitacion no está disponible.';
    }
    if (dias <= 0) {
      return 'Error: la cantidad de días debe ser mayor que cero.';
    }

    habitacion.estado = EstadoHabitacion.reservada;
    reservas.add(Reserva(
      huesped: huesped,
      numeroHabitacion: numeroHabitacion,
      dias: dias,
    ));

    return 'Reserva creada con éxito para ${huesped.nombre} en la habitación $numeroHabitacion.';
  }

  // Busca la reserva activa de una habitación (si existe).
  Reserva? buscarReservaActiva(int numeroHabitacion) {
    for (final r in reservas) {
      if (r.numeroHabitacion == numeroHabitacion && r.activa) return r;
    }
    return null;
  }

  // ---------------------------------------------------------------
  // RF06: Check-in con validaciones
  // ---------------------------------------------------------------

  String hacerCheckIn({
    required int numeroHabitacion,
    required int personas,
  }) {
    final habitacion = buscarHabitacion(numeroHabitacion);

    if (habitacion == null) {
      return 'Error: la habitación $numeroHabitacion no existe.';
    }
    if (!habitacion.estaReservada) {
      return 'Error: la habitación $numeroHabitacion no tiene una reserva activa.';
    }

    final reserva = buscarReservaActiva(numeroHabitacion);
    if (reserva == null) {
      return 'Error: no se encontró la reserva de la habitación $numeroHabitacion.';
    }
    if (personas <= 0) {
      return 'Error: el número de personas debe ser mayor que cero.';
    }
    if (personas > habitacion.capacidad) {
      return 'Error: el número de personas supera la capacidad (${habitacion.capacidad}).';
    }

    habitacion.estado = EstadoHabitacion.ocupada;
    checkIns.add(CheckIn(numeroHabitacion: numeroHabitacion, personas: personas));

    return 'Check-in realizado con éxito en la habitación $numeroHabitacion.';
  }

  // ---------------------------------------------------------------
  // RF07: Check-out
  // ---------------------------------------------------------------

  String hacerCheckOut(int numeroHabitacion) {
    final habitacion = buscarHabitacion(numeroHabitacion);

    if (habitacion == null) {
      return 'Error: la habitación $numeroHabitacion no existe.';
    }
    if (!habitacion.estaOcupada) {
      return 'Error: la habitación $numeroHabitacion no está ocupada.';
    }

    habitacion.estado = EstadoHabitacion.disponible;

    // Decisión de diseño del grupo: la reserva se cierra (queda como
    // historial) en lugar de eliminarse, para poder consultarla después.
    final reserva = buscarReservaActiva(numeroHabitacion);
    if (reserva != null) {
      reserva.activa = false;
    }

    checkOuts.add(CheckOut(numeroHabitacion: numeroHabitacion));

    return 'Check-out realizado con éxito en la habitación $numeroHabitacion.';
  }
}
