import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:oezbooking/core/utils/encryption_helper.dart';
import 'package:oezbooking/features/login/data/datasource/login_datasource.dart';
import 'package:oezbooking/features/login/data/model/organizer.dart';

class LoginDatasourceImpl extends LoginDatasource {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Future<Organizer?> loginWithEmailAndPassword(
      String email, String password) async {
    try {
      final docs = await firebaseFirestore
          .collection("organizers")
          .where("email", isEqualTo: email)
          .limit(1)
          .get();

      if (docs.docs.isNotEmpty) {
        final doc = docs.docs.first;
        final data = doc.data();

        // Lấy hash mật khẩu từ Firestore
        final passwordHash = data['passwordHash'] as String;

        final passwordDecrypted = EncryptionHelper.decryptData(
          passwordHash,
          EncryptionHelper.secretKey,
        );
print(passwordDecrypted);
        if (passwordDecrypted == password) {
          return Organizer.fromJson(data);
        }
      }
      return null;
    } on Exception catch (e) {
      rethrow;
    }
  }
}
