import 'package:app_lista_de_compras/app/features/splash.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Lista de compras',
        theme: ThemeData.light(),
        home: SplashView());
  }
}
