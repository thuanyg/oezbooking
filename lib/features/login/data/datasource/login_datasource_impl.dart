import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oezbooking/features/login/data/datasource/login_datasource.dart';
import 'package:oezbooking/features/login/data/model/organizer.dart';

class LoginDatasourceImpl extends LoginDatasource {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Future<Organizer?> loginWithEmailAndPassword(
      String email, String password) async {
    final docs = await firebaseFirestore
        .collection("organizers")
        .where("email", isEqualTo: email)
        .where("passwordHash", isEqualTo: password)
        .limit(1)
        .get();
    if (docs.docs.isNotEmpty) {
      // Extract the document and map it to the Organizer model.
      final doc = docs.docs.first;
      return Organizer.fromJson(doc.data());
    } else {
      // Return null if no matching organizer was found.
      return null;
    }
  }
}
