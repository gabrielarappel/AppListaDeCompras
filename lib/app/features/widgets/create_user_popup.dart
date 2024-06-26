import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


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
  final docSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(username)
      .get();

  return docSnapshot.exists;
}

Future<void> _saveUser(String username, String password) async {
  await FirebaseFirestore.instance
      .collection('users')
      .doc(username)
      .set({
    'username': username,
    'password': password,
  });
}
}
