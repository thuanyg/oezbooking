import 'package:oezbooking/features/login/data/model/organizer.dart';

abstract class LoginRepository {
  Future<Organizer?> loginWithEmailAndPassword(String email, String password);
}