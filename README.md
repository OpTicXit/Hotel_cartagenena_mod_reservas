# Hotel_cartagenena_mod_reservas

#ESTUDIANTES: Jesús Castilla, Willer Rivero, Miguel Martinez, Luis Reyes, Andres Diaz

## Objetivo
Sistema de consola en Dart, modularizado con Programación Orientada a Objetos, para
que los recepcionistas del Hotel Cartagena administren habitaciones y huéspedes:
registro de recepcionistas, inicio de sesión, gestión de reservas (crear, buscar por
cédula y cancelar), check-in y check-out.

## Descripción breve del funcionamiento
El sistema arranca en un **menú de autenticación** donde se puede registrar un
recepcionista o iniciar sesión:
1. Iniciar Sesión (Login)
2. Registrarse (crear una nueva cuenta de recepcionista)
3. Salir del programa

El sistema siempre incluye un usuario administrador por defecto (`admin` / `1234`),
además de cualquier recepcionista que se registre en tiempo de ejecución.

Al iniciar sesión correctamente, se accede al **menú del recepcionista**, donde se
puede consultar el estado del hotel, crear reservas, hacer check-in, hacer check-out,
buscar reservas por cédula y cancelar una reserva:
1. Ver estado del hotel
2. Registrar reserva
3. Realizar Check-In
4. Realizar Check-Out
5. Buscar reservas por cédula
6. Cancelar reserva
7. Salir del sistema

Cada habitación sigue el ciclo obligatorio de estados:

```
disponible -> reservada -> ocupada -> disponible
```

## Estructura de carpetas
```
Hotel_cartagenena_mod_reservas/
├── bin/
│   └── main.dart                 # Punto de entrada, solo inicia la app
├── lib/
│   ├── models/                   # Clases de datos (sin lógica de negocio)
│   │   ├── habitacion.dart
│   │   ├── huesped.dart
│   │   ├── recepcionista.dart
│   │   ├── reserva.dart
│   │   ├── check_in.dart          # Evento histórico de check-in (fecha automática)
│   │   └── check_out.dart         # Evento histórico de check-out (fecha automática)
│   ├── enums/
│   │   ├── tipo_habitacion.dart   # sencilla / doble / suite + capacidadMaxima
│   │   └── estado_habitacion.dart # disponible -> reservada -> ocupada -> disponible
│   ├── services/
│   │   └── hotel.dart             # Toda la lógica de negocio y validaciones
│   └── sistema_hotel.dart         # Interfaz de consola (menús, lectura de datos)
├── test/
│   └── hotel_test.dart            # Pruebas automatizadas (casos T01-T17)
├── pubspec.yaml
└── README.md
```

## Cómo instalar/ejecutar el proyecto
1. Instalar el [SDK de Dart](https://dart.dev/get-dart).
2. Ubicarse en la carpeta raíz del proyecto (`Hotel_cartagenena_mod_reservas/`).
3. Ejecutar:
   ```
   dart pub get
   dart run bin/main.dart
   ```
4. Para correr las pruebas automatizadas:
   ```
   dart test
   ```

## API principal de la clase `Hotel` (lib/services/hotel.dart)
| Método | Descripción |
|---|---|
| `registrarRecepcionista(usuario, contrasena)` | Registra un nuevo recepcionista. Devuelve `false` si el usuario ya existe. |
| `login(usuario, contrasena)` | Valida credenciales contra los recepcionistas registrados (incluye `admin`/`1234` por defecto). |
| `registrarReserva(huesped, numeroHabitacion, dias)` | Crea una reserva si la habitación existe, está disponible y `dias > 0`. Pasa la habitación a `reservada`. |
| `realizarCheckIn(numeroHabitacion, personas)` | Valida que exista reserva activa y que `personas` no supere la capacidad. Pasa la habitación a `ocupada`. |
| `realizarCheckOut(numeroHabitacion)` | Libera la habitación (`disponible`) y cierra la reserva activa asociada. |
| `buscarReservasPorCedula(cedula)` | Devuelve todas las reservas (activas o cerradas) de un huésped por su cédula. |
| `cancelarReserva(numeroHabitacion)` | Cancela la reserva activa de una habitación `reservada` (aún sin check-in) y la libera. |
| `mostrarEstadoHotel()` | Imprime en consola el estado actual de todas las habitaciones. |

## Reglas de negocio implementadas
- Toda habitación nueva inicia en estado **disponible**.
- Una habitación solo puede reservarse si está **disponible**.
- Al reservar, la habitación pasa a estado **reservada**.
- El check-in solo es válido si la habitación está **reservada** y existe una reserva activa.
- El número de personas en el check-in debe ser mayor que cero y no puede superar la
  capacidad de la habitación (sencilla: 1, doble: 2, suite: 4).
- Al hacer check-in, la habitación pasa a estado **ocupada**.
- El check-out solo es válido si la habitación está **ocupada**.
- Al hacer check-out, la habitación vuelve a estado **disponible**.
- Una reserva solo puede **cancelarse** mientras la habitación está en estado
  **reservada** (antes del check-in); si ya está **ocupada**, debe cerrarse con
  check-out en lugar de cancelarse.
- **Decisión del grupo:** al hacer check-out o al cancelar una reserva, esta no se
  elimina; se marca como `activa = false` y queda guardada como historial (junto con
  el registro `CheckOut` cuando aplica), para poder consultarla más adelante —por
  ejemplo, mediante `buscarReservasPorCedula`.

## Casos de prueba realizados
Se implementaron pruebas automatizadas en `test/hotel_test.dart` cubriendo 17
casos (T01 a T17): registro de usuario nuevo y duplicado, login correcto e
incorrecto (incluyendo el usuario `admin` por defecto), reserva correcta/inexistente/
no disponible/con días inválidos, check-in correcto y excediendo capacidad, check-out
correcto e incorrecto, cancelación de reserva válida e inválida, y búsqueda de
reservas por cédula existente e inexistente.

## Integrantes y responsabilidad de cada uno

| Integrante | Responsabilidad |
|---|---|
| Jesús Castilla | Modelos y enumeraciones (clases de dominio y enums) |
| Willer Rivero | Lógica de negocio (clase `Hotel`, reglas de reservas, check-in y check-out) |
| Luis Reyes | Lógica de negocio (clase `Hotel`, reglas de reservas, check-in y check-out) |
| Andrés | Interfaz de consola (menús, captura de datos y navegación) |
| Miguel Ángel Martínez | Implementación de nuevas funcionalidades: cancelación de reservas y búsqueda de reservas por cédula. Creación de pruebas automatizadas para verificar el correcto funcionamiento e integración de estas funcionalidades. |

*(Todos los integrantes participaron en el diseño, las pruebas y la sustentación del proyecto completo).*

## Dificultades encontradas y cómo fueron solucionadas
- **Organizar los archivos sin generar dependencias circulares:** se solucionó
  definiendo primero los enums, luego los modelos, y dejando toda la lógica
  concentrada únicamente en `Hotel`, para que los demás archivos solo lo importen a él.
- **Decidir qué pasa con la reserva después del check-out o de una cancelación:** se
  decidió no borrarla, sino marcarla como cerrada, para conservar el historial de
  reservas del hotel y poder consultarlo por cédula.
- **Evitar cancelar una reserva que ya tuvo check-in:** `cancelarReserva` solo actúa
  sobre habitaciones en estado `reservada`; si la habitación ya está `ocupada`, se
  debe usar `realizarCheckOut` en su lugar.
- **Validar entradas de consola sin bloquear el programa:** se crearon métodos
  auxiliares (`_leerTexto`, `_leerEntero`) en `SistemaHotel` que repiten la pregunta
  hasta recibir un dato válido, evitando errores por texto vacío o no numérico.
