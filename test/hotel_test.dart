import 'package:test/test.dart';
import 'package:hotel_cartagenena_mod_reservas/services/hotel.dart';
import 'package:hotel_cartagenena_mod_reservas/models/huesped.dart';

// Pruebas basadas en la tabla de "Casos de prueba mínimos" del enunciado
// (T01 a T17). Cada test crea su propio Hotel nuevo para no arrastrar
// estado entre pruebas.
void main() {
  group('Registro de recepcionistas', () {
    test('T01 - Registrar usuario nuevo debe ser exitoso', () {
      final hotel = Hotel();
      final resultado = hotel.registrarRecepcionista('ana', '1234');
      expect(resultado, true);
    });

    test('T02 - Registrar usuario duplicado debe rechazarse', () {
      final hotel = Hotel();
      hotel.registrarRecepcionista('ana', '1234');
      final resultado = hotel.registrarRecepcionista('ana', 'otraClave');
      expect(resultado, false);
    });
  });

  group('Inicio de sesión', () {
    test('T03 - Login correcto debe permitir el acceso', () {
      final hotel = Hotel();
      hotel.registrarRecepcionista('ana', '1234');
      final resultado = hotel.login('ana', '1234');
      expect(resultado, true);
    });

    test('T04 - Login incorrecto debe ser rechazado', () {
      final hotel = Hotel();
      hotel.registrarRecepcionista('ana', '1234');
      final resultado = hotel.login('ana', 'incorrecta');
      expect(resultado, false);
    });

    test('T05 - El usuario admin/1234 existe por defecto', () {
      final hotel = Hotel();
      final resultado = hotel.login('admin', '1234');
      expect(resultado, true);
    });
  });

  group('Reservas', () {
    test('T06 - Reserva correcta crea la reserva y cambia el estado', () {
      final hotel = Hotel();
      final huesped = Huesped(nombre: 'Carlos', cedula: '111');
      final resultado = hotel.registrarReserva(huesped, 101, 2);
      final habitacion = hotel.buscarHabitacion(101)!;

      expect(resultado.contains('éxito'), true);
      expect(habitacion.estaReservada, true);
    });

    test('T07 - Reserva de habitación inexistente debe rechazarse', () {
      final hotel = Hotel();
      final huesped = Huesped(nombre: 'Carlos', cedula: '111');
      final resultado = hotel.registrarReserva(huesped, 999, 2);
      expect(resultado.contains('Error'), true);
    });

    test('T08 - Reserva de habitación no disponible debe rechazarse', () {
      final hotel = Hotel();
      final huesped = Huesped(nombre: 'Carlos', cedula: '111');
      hotel.registrarReserva(huesped, 101, 2);

      // Se intenta reservar de nuevo la misma habitación (ya reservada)
      final resultado = hotel.registrarReserva(huesped, 101, 1);
      expect(resultado.contains('Error'), true);
    });

    test('T09 - Días en cero o negativos deben rechazarse', () {
      final hotel = Hotel();
      final huesped = Huesped(nombre: 'Carlos', cedula: '111');
      final resultado = hotel.registrarReserva(huesped, 101, 0);
      expect(resultado.contains('Error'), true);
    });
  });

  group('Check-in', () {
    test('T10 - Check-in correcto cambia el estado a ocupada', () {
      final hotel = Hotel();
      final huesped = Huesped(nombre: 'Carlos', cedula: '111');
      hotel.registrarReserva(huesped, 101, 2);

      final resultado = hotel.realizarCheckIn(101, 1);
      final habitacion = hotel.buscarHabitacion(101)!;

      expect(resultado.contains('éxito'), true);
      expect(habitacion.estaOcupada, true);
    });

    test('T11 - Check-in que excede capacidad debe rechazarse', () {
      final hotel = Hotel();
      final huesped = Huesped(nombre: 'Carlos', cedula: '111');
      // Habitación 101 es sencilla -> capacidad 1
      hotel.registrarReserva(huesped, 101, 2);

      final resultado = hotel.realizarCheckIn(101, 5);
      expect(resultado.contains('Error'), true);
    });
  });

  group('Check-out', () {
    test('T12 - Check-out correcto libera la habitación', () {
      final hotel = Hotel();
      final huesped = Huesped(nombre: 'Carlos', cedula: '111');
      hotel.registrarReserva(huesped, 101, 2);
      hotel.realizarCheckIn(101, 1);

      final resultado = hotel.realizarCheckOut(101);
      final habitacion = hotel.buscarHabitacion(101)!;

      expect(resultado.contains('éxito'), true);
      expect(habitacion.estaDisponible, true);
    });

    test('T13 - Check-out de habitación disponible debe rechazarse', () {
      final hotel = Hotel();
      // La habitación 101 empieza disponible, sin check-in previo
      final resultado = hotel.realizarCheckOut(101);
      expect(resultado.contains('Error'), true);
    });
  });

  group('Cancelación de reservas', () {
    test('T14 - Cancelar una reserva activa libera la habitación', () {
      final hotel = Hotel();
      final huesped = Huesped(nombre: 'Carlos', cedula: '111');
      hotel.registrarReserva(huesped, 101, 2);

      final resultado = hotel.cancelarReserva(101);
      final habitacion = hotel.buscarHabitacion(101)!;

      expect(resultado.contains('éxito'), true);
      expect(habitacion.estaDisponible, true);
    });

    test('T15 - Cancelar una habitación sin reserva debe rechazarse', () {
      final hotel = Hotel();
      final resultado = hotel.cancelarReserva(101);
      expect(resultado.contains('Error'), true);
    });
  });

  group('Búsqueda de reservas por cédula', () {
    test('T16 - Buscar por cédula existente devuelve las reservas', () {
      final hotel = Hotel();
      final huesped = Huesped(nombre: 'Carlos', cedula: '111');
      hotel.registrarReserva(huesped, 101, 2);

      final resultados = hotel.buscarReservasPorCedula('111');
      expect(resultados.length, 1);
      expect(resultados.first.numeroHabitacion, 101);
    });

    test('T17 - Buscar por cédula inexistente devuelve lista vacía', () {
      final hotel = Hotel();
      final resultados = hotel.buscarReservasPorCedula('000');
      expect(resultados.isEmpty, true);
    });
  });
}
