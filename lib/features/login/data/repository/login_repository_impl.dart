import 'package:oezbooking/features/login/data/datasource/login_datasource.dart';
import 'package:oezbooking/features/login/data/model/organizer.dart';
import 'package:oezbooking/features/login/domain/repository/login_repository.dart';

class LoginRepositoryImpl extends LoginRepository {
  final LoginDatasource datasource;

  LoginRepositoryImpl(this.datasource);

  @override
  Future<Organizer?> loginWithEmailAndPassword(
      String email, String password) async {
    return await datasource.loginWithEmailAndPassword(email, password);
  }
}
