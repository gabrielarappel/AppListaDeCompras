import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


class Usuario {
  String username;
  String password;
  List<String> listasDeCompras; // Exemplo de listas de compras do usuário

  Usuario({
    required this.username,
    required this.password,
    this.listasDeCompras = const [], // Inicializa como uma lista vazia
  });

  // Método para converter usuário para JSON
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'listasDeCompras': listasDeCompras,
    };
  }

  // Método para criar usuário a partir de JSON
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      username: json['username'],
      password: json['password'],
      listasDeCompras: List<String>.from(json['listasDeCompras'] ?? []),
    );
  }
}

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
