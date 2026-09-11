import 'dart:io';

import 'services/hotel.dart';
import 'models/huesped.dart';

// Clase encargada SOLO de la interacción con el usuario por consola:
// mostrar menús, leer datos y llamar a Hotel para que tome las
// decisiones. No contiene reglas de negocio; toda la lógica y las
// validaciones viven en `Hotel` (services/hotel.dart).
class SistemaHotel {
  final Hotel hotel = Hotel();

  void iniciar() {
    print('=== Sistema de Gestión - Hotel Cartagena ===');
    _menuAutenticacion();
    print('\nGracias por usar el sistema del Hotel Cartagena. ¡Hasta pronto!');
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
        print('Debe ingresar un número entero válido. Intente de nuevo.');
      }
    } while (valor == null);
    return valor;
  }

  // ---------------------------------------------------------------
  // Menú de autenticación inicial
  // 1. Iniciar Sesión (Login)
  // 2. Registrarse (Crear una nueva cuenta de recepcionista)
  // 3. Salir del programa
  // ---------------------------------------------------------------

  void _menuAutenticacion() {
    bool autenticado = false;
    bool salir = false;

    do {
      print('\n--- AUTENTICACIÓN ---');
      print('1. Iniciar Sesión');
      print('2. Registrarse');
      print('3. Salir del programa');
      final opcion = _leerEntero('Seleccione una opción: ');

      switch (opcion) {
        case 1:
          autenticado = _iniciarSesion();
          break;
        case 2:
          _registrarse();
          break;
        case 3:
          salir = true;
          break;
        default:
          print('Opción no válida.');
      }
    } while (!autenticado && !salir);

    if (autenticado) {
      _menuOperativo();
    }
  }

  bool _iniciarSesion() {
    final usuario = _leerTexto('Usuario: ');
    final contrasena = _leerTexto('Contraseña: ');

    final valido = hotel.login(usuario, contrasena);
    if (valido) {
      print('Acceso concedido. Bienvenido, $usuario.');
      return true;
    } else {
      print('Usuario o contraseña incorrectos.');
      return false;
    }
  }

  void _registrarse() {
    final usuario = _leerTexto('Nuevo usuario: ');
    final contrasena = _leerTexto('Nueva contraseña: ');

    final exito = hotel.registrarRecepcionista(usuario, contrasena);
    if (exito) {
      print('Cuenta creada con éxito. Ya puede iniciar sesión.');
    } else {
      print('Error: ese usuario ya existe.');
    }
  }

  // ---------------------------------------------------------------
  // Menú operativo (una vez autenticado)
  // 1. Ver estado del hotel
  // 2. Registrar reserva
  // 3. Realizar Check-In
  // 4. Realizar Check-Out
  // 5. Buscar reservas por cédula
  // 6. Cancelar reserva
  // 7. Salir del sistema
  // ---------------------------------------------------------------

  void _menuOperativo() {
    int opcion;

    do {
      print('\n--- MENÚ HOTEL CARTAGENA ---');
      print('1. Ver estado del hotel');
      print('2. Registrar reserva');
      print('3. Realizar Check-In');
      print('4. Realizar Check-Out');
      print('5. Buscar reservas por cédula');
      print('6. Cancelar reserva');
      print('7. Salir del sistema');
      opcion = _leerEntero('Seleccione una opción: ');

      switch (opcion) {
        case 1:
          hotel.mostrarEstadoHotel();
          break;
        case 2:
          _registrarReserva();
          break;
        case 3:
          _realizarCheckIn();
          break;
        case 4:
          _realizarCheckOut();
          break;
        case 5:
          _buscarReservasPorCedula();
          break;
        case 6:
          _cancelarReserva();
          break;
        case 7:
          print('Cerrando sesión...');
          break;
        default:
          print('Opción no válida.');
      }
    } while (opcion != 7);
  }

  void _registrarReserva() {
    print('\n--- REGISTRAR RESERVA ---');
    final nombre = _leerTexto('Nombre del huésped: ');
    final cedula = _leerTexto('Cédula del huésped: ');
    final numero = _leerEntero('Número de habitación: ');
    final dias = _leerEntero('Cantidad de días: ');

    final huesped = Huesped(nombre: nombre, cedula: cedula);
    final resultado = hotel.registrarReserva(huesped, numero, dias);
    print(resultado);
  }

  void _realizarCheckIn() {
    print('\n--- CHECK-IN ---');
    final numero = _leerEntero('Número de habitación: ');
    final personas = _leerEntero('Cantidad de personas: ');

    final resultado = hotel.realizarCheckIn(numero, personas);
    print(resultado);
  }

  void _realizarCheckOut() {
    print('\n--- CHECK-OUT ---');
    final numero = _leerEntero('Número de habitación: ');
    final resultado = hotel.realizarCheckOut(numero);
    print(resultado);
  }

  void _buscarReservasPorCedula() {
    print('\n--- BUSCAR RESERVAS POR CÉDULA ---');
    final cedula = _leerTexto('Cédula del huésped: ');
    final resultados = hotel.buscarReservasPorCedula(cedula);

    if (resultados.isEmpty) {
      print('No se encontraron reservas para la cédula $cedula.');
    } else {
      print('Reservas encontradas para la cédula $cedula:');
      for (final r in resultados) {
        print('  - $r');
      }
    }
  }

  void _cancelarReserva() {
    print('\n--- CANCELAR RESERVA ---');
    final numero = _leerEntero('Número de habitación: ');
    final resultado = hotel.cancelarReserva(numero);
    print(resultado);
  }
}
