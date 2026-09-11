import 'package:test/test.dart';
import '../lib/sistema_hotel.dart';
import '../lib/models/huesped.dart';
import '../lib/models/reserva.dart';

void main() {
  group('Funcionalidades: Búsqueda y Cancelación', () {
    late SistemaHotel sistema; 
    late Huesped huespedMock;
    late Reserva reservaMock;

    setUp(() {
      sistema = SistemaHotel();
      // Instancias básicas
      huespedMock = Huesped(cedula: '1047000000'); 
      reservaMock = Reserva(id: 'RES-001', huesped: huespedMock);
      
      sistema.reservas.add(reservaMock);
    });

    test('buscarReservasPorCedula - no existe', () {
      final resultados = sistema.buscarReservasPorCedula('999999999');
      expect(resultados, isEmpty);
    });

    test('buscarReservasPorCedula - existe', () {
      final resultados = sistema.buscarReservasPorCedula('1047000000');
      expect(resultados.length, equals(1));
      expect(resultados.first.id, equals('RES-001'));
    });

    test('cancelarReserva - ID falso', () {
      final resultado = sistema.cancelarReserva('ID-FALSO');
      expect(resultado, isFalse);
      // Validamos que la reserva original siga intacta
      expect(sistema.reservas.length, equals(1));
    });

    test('cancelarReserva - éxito', () {
      final resultado = sistema.cancelarReserva('RES-001');
      expect(resultado, isTrue);
      expect(sistema.reservas, isEmpty);
    });
  });
}