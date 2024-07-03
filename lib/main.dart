import 'package:app_lista_de_compras/app/features/pages/splash.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_lista_de_compras/app/features/pages/login_page.dart';
import 'package:app_lista_de_compras/app/features/pages/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  String? username = prefs.getString('username');

  runApp(MyApp(isLoggedIn: isLoggedIn, username: username));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String? username;

  const MyApp({Key? key, required this.isLoggedIn, this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lista de compras',
      theme: ThemeData(
        fontFamily: 'Roboto',
      ),
      home: SplashView(
        nextPage: isLoggedIn && username != null
            ? MainListView(username: username!)
            : LoginPage(),
      ),
    );
  }
}
