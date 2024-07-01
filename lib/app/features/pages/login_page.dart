import 'package:app_lista_de_compras/app/features/widgets/create_user_popup.dart';
import 'package:flutter/material.dart';
import 'main_list.dart';
import 'user_manager.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('iBuy'),
        backgroundColor: Color.fromARGB(255, 88, 156, 95),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      backgroundColor: const Color(0xFFD2F8D6),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'lib/app/assets/logo_app.png',
                  height: 300,
                ),
                const SizedBox(height: 30.0),
                Container(
                  padding: EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 20.0),
                      Container(
                        constraints: BoxConstraints(maxWidth: 400),
                        child: TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Usuário',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Container(
                        constraints: BoxConstraints(maxWidth: 400),
                        child: TextField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            border: OutlineInputBorder(),
                            prefixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                              child: Icon(
                                _isPasswordVisible
                                    ? Icons.lock_open
                                    : Icons.lock,
                              ),
                            ),
                          ),
                          textInputAction: TextInputAction.done,
                          obscureText: !_isPasswordVisible,
                        ),
                      ),
                      SizedBox(height: 20.0),
                      ElevatedButton(
                        onPressed: () async {
                          String username = _usernameController.text;
                          String password = _passwordController.text;

                          bool loggedIn =
                              await UserManager.loginUser(username, password);

                          if (loggedIn) {
                            // Navegue para a próxima tela (MainListView)
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      MainListView(username: username)),
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF11E333),
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        child: Text(
                          'Entrar',
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                      ),
                      SizedBox(height: 10.0),
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return CreateUserPopup(); // Mostra o popup de criação de usuário
                            },
                          );
                        },
                        child: Text(
                          'Cadastre-se',
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Container(
          height: 56.0,
          alignment: Alignment.center,
          child: Text(
            'Autores do Projeto: Álvaro Souza, Emiliano Calado, Gabriela Rappel, Lucas Oitabem',
            style: TextStyle(color: Colors.black, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
