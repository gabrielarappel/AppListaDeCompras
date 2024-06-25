import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_lista_de_compras/app/features/model/usuario.dart';

class UserManager {
  static const String _userKey = 'users';

  // Método para registrar um novo usuário
  static Future<void> registerUser(Usuario user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> usersMap = prefs.getString(_userKey) != null
        ? jsonDecode(prefs.getString(_userKey)!)
        : {};

    usersMap[user.username] = user.toJson();
    await prefs.setString(_userKey, jsonEncode(usersMap));
  }

  // Método para verificar se as credenciais de login estão corretas
  static Future<bool> loginUser(String username, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> usersMap = prefs.getString(_userKey) != null
        ? jsonDecode(prefs.getString(_userKey)!)
        : {};

    if (usersMap.containsKey(username)) {
      Map<String, dynamic> userData = usersMap[username];
      return userData['password'] == password;
    }
    return false;
  }

  // Método para obter informações de um usuário
  static Future<Usuario?> getUser(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> usersMap = prefs.getString(_userKey) != null
        ? jsonDecode(prefs.getString(_userKey)!)
        : {};

    if (usersMap.containsKey(username)) {
      Map<String, dynamic> userData = usersMap[username];
      return Usuario.fromJson(userData);
    }
    return null;
  }

  // Método para adicionar uma nova lista de compras ao usuário
  static Future<void> addListaDeCompras(String username, String listaId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> usersMap = prefs.getString(_userKey) != null
        ? jsonDecode(prefs.getString(_userKey)!)
        : {};

    if (usersMap.containsKey(username)) {
      Map<String, dynamic> userData = usersMap[username];
      List<String> listasDeCompras =
          List<String>.from(userData['listasDeCompras'] ?? []);
      if (!listasDeCompras.contains(listaId)) {
        listasDeCompras.add(listaId);
        userData['listasDeCompras'] = listasDeCompras;
        usersMap[username] = userData;
        await prefs.setString(_userKey, jsonEncode(usersMap));
      }
    }
  }
}
