import 'dart:io';

import 'services/hotel.dart';
import 'models/huesped.dart';
import 'enums/tipo_habitacion.dart';

// Clase encargada SOLO de la interacción con el usuario por consola:
// mostrar menús, leer datos y llamar a Hotel para que tome las
// decisiones. No contiene reglas de negocio.
class SistemaHotel {
  final Hotel hotel = Hotel();

  void iniciar() {
    print('=== Bienvenido al Hotel Cartagena ===');
    _menuInicial();
  }

  // ---------------------------------------------------------------
  // Lectura de datos con validación básica (evita entradas vacías)
  // ---------------------------------------------------------------

  String _leerTexto(String mensaje) {
    String? valor;
    do {
      stdout.write(mensaje);
      valor = stdin.readLineSync();
      if (valor == null || valor.trim().isEmpty) {
        print('El dato no puede estar vacío. Intente de nuevo.');
      }
    } while (valor == null || valor.trim().isEmpty);
    return valor.trim();
  }

  int _leerEntero(String mensaje) {
    int? valor;
    do {
      stdout.write(mensaje);
      final texto = stdin.readLineSync();
      valor = int.tryParse(texto ?? '');
      if (valor == null) {
        print('Debe ingresar un número válido. Intente de nuevo.');
      }
    } while (valor == null);
    return valor;
  }

  // ---------------------------------------------------------------
  // Menú inicial: registro / login / salir
  // ---------------------------------------------------------------

  void _menuInicial() {
    bool salir = false;

    while (!salir) {
      print('\n--- MENÚ INICIAL ---');
      print('1. Registrar recepcionista');
      print('2. Iniciar sesión');
      print('3. Salir');
      final opcion = _leerEntero('Seleccione una opción: ');

      switch (opcion) {
        case 1:
          _registrarRecepcionista();
          break;
        case 2:
          _iniciarSesion();
          break;
        case 3:
          salir = true;
          print('Gracias por usar el sistema del Hotel Cartagena.');
          break;
        default:
          print('Opción no válida.');
      }
    }
  }

  void _registrarRecepcionista() {
    final usuario = _leerTexto('Nuevo usuario: ');
    final contrasena = _leerTexto('Nueva contraseña: ');

    final exito = hotel.registrarRecepcionista(usuario, contrasena);
    if (exito) {
      print('Recepcionista registrado con éxito.');
    } else {
      print('Error: ese usuario ya existe.');
    }
  }

  void _iniciarSesion() {
    final usuario = _leerTexto('Usuario: ');
    final contrasena = _leerTexto('Contraseña: ');

    final valido = hotel.iniciarSesion(usuario, contrasena);
    if (valido) {
      print('Acceso concedido. Bienvenido, $usuario.');
      _menuRecepcionista();
    } else {
      print('Usuario o contraseña incorrectos.');
    }
  }

  // ---------------------------------------------------------------
  // Menú del recepcionista: operaciones del día a día
  // ---------------------------------------------------------------

  void _menuRecepcionista() {
    bool volver = false;

    while (!volver) {
      print('\n--- MENÚ RECEPCIONISTA ---');
      print('1. Consultar habitaciones disponibles');
      print('2. Reservar habitación');
      print('3. Check-in');
      print('4. Check-out');
      print('5. Cerrar sesión');
      final opcion = _leerEntero('Seleccione una opción: ');

      switch (opcion) {
        case 1:
          _consultarDisponibles();
          break;
        case 2:
          _reservar();
          break;
        case 3:
          _checkIn();
          break;
        case 4:
          _checkOut();
          break;
        case 5:
          volver = true;
          print('Sesión cerrada.');
          break;
        default:
          print('Opción no válida.');
      }
    }
  }

  void _consultarDisponibles() {
    final agrupadas = hotel.habitacionesDisponiblesPorTipo();

    print('\n--- HABITACIONES DISPONIBLES ---');
    agrupadas.forEach((tipo, lista) {
      print('${tipo.nombre}:');
      if (lista.isEmpty) {
        print('  (sin habitaciones disponibles)');
      } else {
        for (final h in lista) {
          print('  - Habitación ${h.numero}');
        }
      }
    });
  }

  void _reservar() {
    final nombre = _leerTexto('Nombre del huésped: ');
    final cedula = _leerTexto('Cédula del huésped: ');
    final numero = _leerEntero('Número de habitación: ');
    final dias = _leerEntero('Cantidad de días: ');

    final huesped = Huesped(nombre: nombre, cedula: cedula);
    final resultado = hotel.reservarHabitacion(
      huesped: huesped,
      numeroHabitacion: numero,
      dias: dias,
    );

    print(resultado);
  }

  void _checkIn() {
    final numero = _leerEntero('Número de habitación: ');
    final personas = _leerEntero('Cantidad de personas: ');

    final resultado = hotel.hacerCheckIn(
      numeroHabitacion: numero,
      personas: personas,
    );

    print(resultado);
  }

  void _checkOut() {
    final numero = _leerEntero('Número de habitación: ');
    final resultado = hotel.hacerCheckOut(numero);
    print(resultado);
  }
}
