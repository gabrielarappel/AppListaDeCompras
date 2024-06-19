import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'items_list.dart'; // Importe a HomePage

class Listas {
  String nomeLista;
  double precoTotal;

  Listas({this.nomeLista = '', this.precoTotal = 0.0});

  // Método para converter objeto Listas para string (para salvar no SharedPreferences)
  String toString() {
    return nomeLista; // Nesse exemplo, estamos convertendo apenas o nome da lista para string
  }
}

class ListaPage extends StatefulWidget {
  @override
  _ListaPageState createState() => _ListaPageState();
}

class _ListaPageState extends State<ListaPage> {
  List<Listas> _listas = []; // Lista de objetos Listas

  @override
  void initState() {
    super.initState();
    _loadListas(); // Carrega as listas salvas ao iniciar a tela
  }

  void _loadListas() async {
    // Carrega as listas salvas do SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> stringListas = prefs.getStringList('listas') ?? [];
    
    setState(() {
      _listas = stringListas.map((item) {
        List<String> parts = item.split(';'); // Separar nomeLista e precoTotal
        return Listas(nomeLista: parts[0], precoTotal: double.parse(parts[1]));
      }).toList();
    });
  }

  void _saveListas() async {
    // Salva as listas no SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> stringListas = _listas.map((lista) => "${lista.nomeLista};${lista.precoTotal}").toList();
    await prefs.setStringList('listas', stringListas);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Minhas Listas')),
      ),
      body: ListView.builder(
        itemCount: _listas.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(_listas[index].nomeLista),
            subtitle: Text('Preço Total: R\$ ${_listas[index].precoTotal.toStringAsFixed(2)}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(
                    nomeLista: _listas[index].nomeLista,
                    precoLista: _listas[index].precoTotal.toStringAsFixed(2),
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
                          _listas.add(Listas(nomeLista: nomeLista, precoTotal: 0.0));
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
