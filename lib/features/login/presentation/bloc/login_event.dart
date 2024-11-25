abstract class LoginEvent {}
class PressedLogin extends LoginEvent {
  final String email;
  final String password;

  PressedLogin(this.email, this.password);
}