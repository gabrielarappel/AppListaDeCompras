import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'items_list.dart'; // Importe a HomePage

class ListaPage extends StatefulWidget {
  @override
  _ListaPageState createState() => _ListaPageState();
}

class _ListaPageState extends State<ListaPage> {
  List<String> _listas = []; // Lista de nomes das listas

  @override
  void initState() {
    super.initState();
    _loadListas(); // Carrega as listas salvas ao iniciar a tela
  }

  void _loadListas() async {
    // Carrega as listas salvas do SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _listas = prefs.getStringList('listas') ?? [];
    });
  }

  void _saveListas() async {
    // Salva as listas no SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('listas', _listas);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Minhas Listas'),
      ),
      body: ListView.builder(
        itemCount: _listas.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(_listas[index]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(
                    nomeLista: _listas[index],
                    precoLista: '0.00', // Pode adicionar um preço inicial aqui se necessário
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              TextEditingController _controller = TextEditingController();

              return AlertDialog(
                title: Text('Criar Nova Lista'),
                content: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: 'Nome da Lista',
                    border: OutlineInputBorder(),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      String nomeLista = _controller.text.trim();
                      if (nomeLista.isNotEmpty) {
                        setState(() {
                          _listas.add(nomeLista);
                          _saveListas();
                        });
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text('Criar'),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
