import 'package:oezbooking/features/login/data/model/organizer.dart';

abstract class LoginDatasource {
  Future<Organizer?> loginWithEmailAndPassword(String email, String password);
}