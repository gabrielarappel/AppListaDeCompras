import 'package:app_lista_de_compras/app/features/main_list.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lista de compras',
      theme: ThemeData(
        // Configurando a fonte Roboto como a fonte padrão do aplicativo
        fontFamily: 'Roboto',
        // Você pode adicionar mais customizações de tema aqui se necessário
        // Por exemplo, para definir um esquema de cores:
        // primarySwatch: Colors.blue,
      ),
      home: MainListView(),
    );
  }
}

void main() {
  runApp(const MyApp());
}
