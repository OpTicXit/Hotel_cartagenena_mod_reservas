// Representa el usuario que puede iniciar sesión y operar el sistema.
// Solo guarda las credenciales; la validación de login la hace Hotel.
class Recepcionista {
  final String usuario;
  final String contrasena;

  Recepcionista({
    required this.usuario,
    required this.contrasena,
  });
}
