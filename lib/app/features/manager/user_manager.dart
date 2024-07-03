import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_lista_de_compras/app/features/model/usuario.dart';

class UserManager {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'users';

  // Método para registrar um novo usuário
  static Future<void> registerUser(Usuario user) async {
    await _firestore.collection(_collection).doc(user.username).set(user.toJson());
  }

  // Método para verificar se as credenciais de login estão corretas
  static Future<bool> loginUser(String username, String password) async {
    DocumentSnapshot doc = await _firestore.collection(_collection).doc(username).get();
    if (doc.exists) {
      Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
      return userData['password'] == password;
    }
    return false;
  }

  // Método para obter informações de um usuário
  static Future<Usuario?> getUser(String username) async {
    DocumentSnapshot doc = await _firestore.collection(_collection).doc(username).get();
    if (doc.exists) {
      return Usuario.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Método para adicionar uma nova lista de compras ao usuário
  static Future<void> addListaDeCompras(String username, String listaId) async {
    DocumentReference userDoc = _firestore.collection(_collection).doc(username);
    DocumentSnapshot doc = await userDoc.get();

    if (doc.exists) {
      Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
      List<String> listasDeCompras = List<String>.from(userData['listasDeCompras'] ?? []);
      if (!listasDeCompras.contains(listaId)) {
        listasDeCompras.add(listaId);
        await userDoc.update({'listasDeCompras': listasDeCompras});
      }
    }
  }

  // Adicionar convite pendente ao usuário
  static Future<void> addConvitePendente(String username, String listaId) async {
    DocumentReference userDoc = _firestore.collection(_collection).doc(username);
    DocumentSnapshot doc = await userDoc.get();

    if (doc.exists) {
      Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
      List<String> convitesPendentes = List<String>.from(userData['convitesPendentes'] ?? []);
      if (!convitesPendentes.contains(listaId)) {
        convitesPendentes.add(listaId);
        await userDoc.update({'convitesPendentes': convitesPendentes});
      }
    }
  }

  // Aceitar convite pendente e adicionar lista compartilhada
  static Future<void> aceitarConvite(String username, String listaId) async {
    DocumentReference userDoc = _firestore.collection(_collection).doc(username);
    DocumentSnapshot doc = await userDoc.get();

    if (doc.exists) {
      Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
      List<String> listasDeCompras = List<String>.from(userData['listasDeCompras'] ?? []);
      List<String> convitesPendentes = List<String>.from(userData['convitesPendentes'] ?? []);

      if (convitesPendentes.contains(listaId)) {
        convitesPendentes.remove(listaId);
        if (!listasDeCompras.contains(listaId)) {
          listasDeCompras.add(listaId);
          await userDoc.update({'listasDeCompras': listasDeCompras});
        }
        await userDoc.update({'convitesPendentes': convitesPendentes});
      }
    }
  }

}

