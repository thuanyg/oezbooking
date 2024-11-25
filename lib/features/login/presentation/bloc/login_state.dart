import 'package:oezbooking/features/login/data/model/organizer.dart';

abstract class LoginState {}
class LoginInitial extends LoginState {}
class LoginLoading extends LoginState {}
class LoginSuccess extends LoginState {
  final Organizer organizer;

  LoginSuccess(this.organizer);
}
class LoginFailed extends LoginState {
  String error;

  LoginFailed(this.error);
}
