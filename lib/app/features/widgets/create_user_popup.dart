import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateUserPopup extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Criar Novo Usuário'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: 20.0),
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.person),
              labelText: 'Nome de Usuário',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20.0),
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.lock),
              labelText: 'Senha',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancelar'),
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.all<Color>(Colors.red),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: Text('Criar'),
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
          ),
          onPressed: () async {
            String username = _usernameController.text;
            String password = _passwordController.text;

            // Verificar se o usuário já existe
            bool userExists = await _checkIfUserExists(username);

            if (userExists) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Erro ao Criar Usuário'),
                    content: const Text('Este nome de usuário já está em uso.'),
                    actions: <Widget>[
                      TextButton(
                        child: Text('OK'),
                        style: ButtonStyle(
                          foregroundColor:
                              WidgetStateProperty.all<Color>(Colors.black),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            } else {
              // Salvar novo usuário usando SharedPreferences
              await _saveUser(username, password);
              Navigator.of(context).pop(); // Fechar o popup após criar usuário
            }
          },
        ),
      ],
    );
  }

  // Método para verificar se o usuário já existe
  Future<bool> _checkIfUserExists(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> usersMap = prefs.getString('users') != null
        ? jsonDecode(prefs.getString('users')!)
        : {};

    return usersMap.containsKey(username);
  }

  // Método para salvar novo usuário usando SharedPreferences
  Future<void> _saveUser(String username, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> usersMap = prefs.getString('users') != null
        ? jsonDecode(prefs.getString('users')!)
        : {};

    usersMap[username] = {
      'username': username,
      'password': password,
    };

    await prefs.setString('users', jsonEncode(usersMap));
  }
}
