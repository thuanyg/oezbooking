import 'package:oezbooking/features/login/data/model/organizer.dart';
import 'package:oezbooking/features/login/domain/repository/login_repository.dart';

class LoginUseCase {
  final LoginRepository repository;

  LoginUseCase(this.repository);

  Future<Organizer?> call(String email, String password) async {
    return await repository.loginWithEmailAndPassword(email, password);
  }
}
