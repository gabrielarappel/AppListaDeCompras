import 'package:app_lista_de_compras/app/features/widgets/create_user_popup.dart';
import 'package:flutter/material.dart';
import 'main_list.dart'; 
import 'user_manager.dart'; 

class LoginPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Usuário',
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Senha',
              ),
              obscureText: true,
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                String username = _usernameController.text;
                String password = _passwordController.text;

                bool loggedIn = await UserManager.loginUser(username, password);

                if (loggedIn) {
                  // Navegue para a próxima tela (MainListView)
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MainListView(username: username)),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Erro de Login'),
                        content: Text('Usuário ou senha incorretos.'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('OK'),
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
              child: Text('Login'),
            ),
            SizedBox(height: 10.0),
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CreateUserPopup();
                  },
                );
              },
              child: Text('Criar Novo Usuário'),
            ),
          ],
        ),
      ),
    );
  }
}