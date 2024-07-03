import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateUserPopup extends StatefulWidget {
  @override
  _CreateUserPopupState createState() => _CreateUserPopupState();
}

class _CreateUserPopupState extends State<CreateUserPopup> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cadastre-se'),
      content: SingleChildScrollView(
        child: Column(
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
              decoration: InputDecoration(
                prefixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  child: Icon(
                    _isPasswordVisible ? Icons.lock_open : Icons.lock,
                  ),
                ),
                labelText: 'Senha',
                border: OutlineInputBorder(),
              ),
              obscureText: !_isPasswordVisible,
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                prefixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                  child: Icon(
                    _isConfirmPasswordVisible ? Icons.lock_open : Icons.lock,
                  ),
                ),
                labelText: 'Confirme a Senha',
                border: OutlineInputBorder(),
              ),
              obscureText: !_isConfirmPasswordVisible,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancelar'),
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(Colors.red),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: Text('Criar'),
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
          ),
          onPressed: () async {
            String username = _usernameController.text;
            String password = _passwordController.text;
            String confirmPassword = _confirmPasswordController.text;

            if (password != confirmPassword) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Erro'),
                    content: const Text('As senhas não correspondem.'),
                    actions: <Widget>[
                      TextButton(
                        child: Text('OK'),
                        style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
              return;
            }

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
                          foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
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
              // Salvar novo usuário usando Firestore
              await _saveUser(username, password);
              Navigator.of(context).pop(); // Fechar o popup após criar usuário
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Sucesso'),
                    content: const Text('Usuário criado com sucesso.'),
                    actions: <Widget>[
                      TextButton(
                        child: Text('OK'),
                        style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
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
