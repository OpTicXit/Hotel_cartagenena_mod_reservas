import '../models/habitacion.dart';
import '../models/huesped.dart';
import '../models/recepcionista.dart';
import '../models/reserva.dart';
import '../models/check_in.dart';
import '../models/check_out.dart';
import '../enums/tipo_habitacion.dart';
import '../enums/estado_habitacion.dart';

/// Clase Hotel: contiene TODA la lógica de negocio (reglas, validaciones,
/// cambios de estado). No pregunta ni imprime datos de entrada por consola
/// (salvo `mostrarEstadoHotel`, que es explícitamente un reporte): recibe
/// datos, decide y devuelve un resultado. Esto permite que la interfaz de
/// consola (bin/main.dart) y las pruebas (test/) puedan usarla sin duplicar
/// reglas de negocio.
class Hotel {
  final List<Habitacion> habitaciones = [];
  final List<Recepcionista> recepcionistas = [];
  final List<Reserva> reservas = [];
  final List<CheckIn> checkIns = [];
  final List<CheckOut> checkOuts = [];

  Hotel() {
    _crearHabitacionesIniciales();
    _crearUsuarioAdministradorPorDefecto();
  }

  // Carga inicial de habitaciones del hotel.
  void _crearHabitacionesIniciales() {
    habitaciones.add(Habitacion(numero: 101, tipo: TipoHabitacion.sencilla));
    habitaciones.add(Habitacion(numero: 102, tipo: TipoHabitacion.sencilla));
    habitaciones.add(Habitacion(numero: 201, tipo: TipoHabitacion.doble));
    habitaciones.add(Habitacion(numero: 202, tipo: TipoHabitacion.doble));
    habitaciones.add(Habitacion(numero: 301, tipo: TipoHabitacion.suite));
  }

  // El sistema siempre cuenta con un usuario administrador por defecto,
  // para que se pueda ingresar aunque no se haya registrado ningún
  // recepcionista todavía.
  void _crearUsuarioAdministradorPorDefecto() {
    recepcionistas.add(Recepcionista(usuario: 'admin', contrasena: '1234'));
  }

  // ---------------------------------------------------------------
  // Registro de recepcionistas e inicio de sesión
  // ---------------------------------------------------------------

  /// Registra un nuevo usuario en el sistema.
  /// Devuelve `true` si el registro fue exitoso.
  /// Falla si ya existe un usuario con el mismo nombre.
  bool registrarRecepcionista(String usuario, String contrasena) {
    final yaExiste = recepcionistas.any((r) => r.usuario == usuario);
    if (yaExiste) return false;

    recepcionistas.add(Recepcionista(usuario: usuario, contrasena: contrasena));
    return true;
  }

  /// Valida el acceso contra los usuarios registrados (incluyendo,
  /// por defecto, admin/1234). Devuelve `true` si las credenciales
  /// son correctas.
  bool login(String usuario, String contrasena) {
    return recepcionistas.any(
      (r) => r.usuario == usuario && r.contrasena == contrasena,
    );
  }

  // ---------------------------------------------------------------
  // Consultas de habitaciones
  // ---------------------------------------------------------------

  List<Habitacion> habitacionesDisponibles() {
    return habitaciones.where((h) => h.estaDisponible).toList();
  }

  // Agrupa las habitaciones disponibles por tipo.
  Map<TipoHabitacion, List<Habitacion>> habitacionesDisponiblesPorTipo() {
    final Map<TipoHabitacion, List<Habitacion>> agrupadas = {};
    for (final tipo in TipoHabitacion.values) {
      agrupadas[tipo] =
          habitacionesDisponibles().where((h) => h.tipo == tipo).toList();
    }
    return agrupadas;
  }

  // Busca una habitación por su número. Devuelve null si no existe.
  Habitacion? buscarHabitacion(int numero) {
    for (final h in habitaciones) {
      if (h.numero == numero) return h;
    }
    return null;
  }

  /// Imprime en consola el estado actual de todas las habitaciones
  /// del hotel, ordenadas por número.
  void mostrarEstadoHotel() {
    print('\n--- ESTADO ACTUAL DEL HOTEL ---');
    final ordenadas = [...habitaciones]
      ..sort((a, b) => a.numero.compareTo(b.numero));
    for (final h in ordenadas) {
      print('  $h');
    }
  }

  // ---------------------------------------------------------------
  // Reservas
  // ---------------------------------------------------------------

  /// Busca la reserva activa de una habitación (si existe).
  Reserva? buscarReservaActiva(int numeroHabitacion) {
    for (final r in reservas) {
      if (r.numeroHabitacion == numeroHabitacion && r.activa) return r;
    }
    return null;
  }

  /// Intenta crear una reserva para [huesped] en la habitación
  /// [numeroHabitacion] durante [dias] días. Valida disponibilidad de la
  /// habitación y que los días sean mayores a cero. Si todo es correcto,
  /// la habitación pasa a estado `reservada`.
  /// Devuelve un mensaje de resultado para que la interfaz lo muestre.
  String registrarReserva(Huesped huesped, int numeroHabitacion, int dias) {
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

    return 'Reserva creada con éxito para ${huesped.nombre} '
        'en la habitación $numeroHabitacion.';
  }

  /// Devuelve las reservas (activas o cerradas) asociadas a la
  /// cédula del huésped consultado.
  List<Reserva> buscarReservasPorCedula(String cedula) {
    return reservas.where((r) => r.huesped.cedula == cedula).toList();
  }

  /// Cancela la reserva activa de la habitación [numeroHabitacion] y
  /// libera la habitación (vuelve a `disponible`). Solo puede
  /// cancelarse una reserva que aún no tuvo check-in (habitación en
  /// estado `reservada`).
  String cancelarReserva(int numeroHabitacion) {
    final habitacion = buscarHabitacion(numeroHabitacion);

    if (habitacion == null) {
      return 'Error: la habitación $numeroHabitacion no existe.';
    }
    if (!habitacion.estaReservada) {
      return 'Error: la habitación $numeroHabitacion no tiene una reserva activa para cancelar.';
    }

    final reserva = buscarReservaActiva(numeroHabitacion);
    if (reserva == null) {
      return 'Error: no se encontró la reserva de la habitación $numeroHabitacion.';
    }

    reserva.activa = false;
    habitacion.estado = EstadoHabitacion.disponible;

    return 'Reserva de la habitación $numeroHabitacion cancelada con éxito.';
  }

  // ---------------------------------------------------------------
  // Check-in
  // ---------------------------------------------------------------

  /// Realiza el check-in de la habitación [numeroHabitacion] para
  /// [personas]. Valida que exista una reserva activa y que la
  /// cantidad de personas no supere la capacidad de la habitación.
  /// Si todo es correcto, la habitación pasa a estado `ocupada`.
  String realizarCheckIn(int numeroHabitacion, int personas) {
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
  // Check-out
  // ---------------------------------------------------------------

  /// Realiza el check-out de la habitación [numeroHabitacion]: la
  /// libera (vuelve a `disponible`) y cierra la reserva activa
  /// asociada (queda marcada como no activa, para historial).
  String realizarCheckOut(int numeroHabitacion) {
    final habitacion = buscarHabitacion(numeroHabitacion);

    if (habitacion == null) {
      return 'Error: la habitación $numeroHabitacion no existe.';
    }
    if (!habitacion.estaOcupada) {
      return 'Error: la habitación $numeroHabitacion no está ocupada.';
    }

    habitacion.estado = EstadoHabitacion.disponible;

    // Decisión de diseño: la reserva se cierra (queda como historial)
    // en lugar de eliminarse, para poder consultarla después.
    final reserva = buscarReservaActiva(numeroHabitacion);
    if (reserva != null) {
      reserva.activa = false;
    }

    checkOuts.add(CheckOut(numeroHabitacion: numeroHabitacion));

    return 'Check-out realizado con éxito en la habitación $numeroHabitacion.';
  }
}
