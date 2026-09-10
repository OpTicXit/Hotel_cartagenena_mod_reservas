import 'package:test/test.dart';
import 'package:hotel_cartagenena_mod_reservas/services/hotel.dart';
import 'package:hotel_cartagenena_mod_reservas/models/huesped.dart';

// Pruebas basadas en la tabla de "Casos de prueba mínimos" del enunciado
// (T01 a T12). Cada test crea su propio Hotel nuevo para no arrastrar
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
      final resultado = hotel.iniciarSesion('ana', '1234');
      expect(resultado, true);
    });

    test('T04 - Login incorrecto debe ser rechazado', () {
      final hotel = Hotel();
      hotel.registrarRecepcionista('ana', '1234');
      final resultado = hotel.iniciarSesion('ana', 'incorrecta');
      expect(resultado, false);
    });
  });

  group('Reservas', () {
    test('T05 - Reserva correcta crea la reserva y cambia el estado', () {
      final hotel = Hotel();
      final huesped = Huesped(nombre: 'Carlos', cedula: '111');
      final resultado = hotel.reservarHabitacion(
        huesped: huesped,
        numeroHabitacion: 101,
        dias: 2,
      );
      final habitacion = hotel.buscarHabitacion(101)!;

      expect(resultado.contains('éxito'), true);
      expect(habitacion.estaReservada, true);
    });

    test('T06 - Reserva de habitación inexistente debe rechazarse', () {
      final hotel = Hotel();
      final huesped = Huesped(nombre: 'Carlos', cedula: '111');
      final resultado = hotel.reservarHabitacion(
        huesped: huesped,
        numeroHabitacion: 999,
        dias: 2,
      );
      expect(resultado.contains('Error'), true);
    });

    test('T07 - Reserva de habitación no disponible debe rechazarse', () {
      final hotel = Hotel();
      final huesped = Huesped(nombre: 'Carlos', cedula: '111');
      hotel.reservarHabitacion(huesped: huesped, numeroHabitacion: 101, dias: 2);

      // Se intenta reservar de nuevo la misma habitación (ya reservada)
      final resultado = hotel.reservarHabitacion(
        huesped: huesped,
        numeroHabitacion: 101,
        dias: 1,
      );
      expect(resultado.contains('Error'), true);
    });
  });

  group('Check-in', () {
    test('T08 - Check-in correcto cambia el estado a ocupada', () {
      final hotel = Hotel();
      final huesped = Huesped(nombre: 'Carlos', cedula: '111');
      hotel.reservarHabitacion(huesped: huesped, numeroHabitacion: 101, dias: 2);

      final resultado = hotel.hacerCheckIn(numeroHabitacion: 101, personas: 1);
      final habitacion = hotel.buscarHabitacion(101)!;

      expect(resultado.contains('éxito'), true);
      expect(habitacion.estaOcupada, true);
    });

    test('T09 - Check-in que excede capacidad debe rechazarse', () {
      final hotel = Hotel();
      final huesped = Huesped(nombre: 'Carlos', cedula: '111');
      // Habitación 101 es sencilla -> capacidad 1
      hotel.reservarHabitacion(huesped: huesped, numeroHabitacion: 101, dias: 2);

      final resultado = hotel.hacerCheckIn(numeroHabitacion: 101, personas: 5);
      expect(resultado.contains('Error'), true);
    });
  });

  group('Check-out', () {
    test('T10 - Check-out correcto libera la habitación', () {
      final hotel = Hotel();
      final huesped = Huesped(nombre: 'Carlos', cedula: '111');
      hotel.reservarHabitacion(huesped: huesped, numeroHabitacion: 101, dias: 2);
      hotel.hacerCheckIn(numeroHabitacion: 101, personas: 1);

      final resultado = hotel.hacerCheckOut(101);
      final habitacion = hotel.buscarHabitacion(101)!;

      expect(resultado.contains('éxito'), true);
      expect(habitacion.estaDisponible, true);
    });

    test('T11 - Check-out de habitación disponible debe rechazarse', () {
      final hotel = Hotel();
      // La habitación 101 empieza disponible, sin check-in previo
      final resultado = hotel.hacerCheckOut(101);
      expect(resultado.contains('Error'), true);
    });
  });

  group('Validación de entradas', () {
    test('T12 - Días en cero o negativos deben rechazarse (equivalente a entrada inválida)', () {
      final hotel = Hotel();
      final huesped = Huesped(nombre: 'Carlos', cedula: '111');
      final resultado = hotel.reservarHabitacion(
        huesped: huesped,
        numeroHabitacion: 101,
        dias: 0,
      );
      expect(resultado.contains('Error'), true);
    });
  });
}
