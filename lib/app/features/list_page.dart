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
  void _showDeleteDialog(int index) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirmar exclusão'),
        content: Text('Deseja excluir a lista "${_listas[index].nomeLista}"?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              _deleteLista(index);
              Navigator.of(context).pop();
            },
            child: Text('Sim'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancelar'),
          ),
        ],
      );
    },
  );
}
void _deleteLista(int index) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  
  // Remove do SharedPreferences
  await prefs.remove('precoTotal_${_listas[index].nomeLista}');
  
  // Remove da lista em memória
  setState(() {
    _listas.removeAt(index);
    _saveListas(); // Salva as alterações restantes
  });
}

  void _loadListas() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> stringListas = prefs.getStringList('listas') ?? [];
  
  setState(() {
    _listas = stringListas.map((item) {
      List<String> parts = item.split(';');
      String nomeLista = parts[0];
      double precoTotal = double.parse(parts[1]);

      // Carregar o preço total salvo para cada lista
      double? precoTotalSalvo = prefs.getDouble('precoTotal_$nomeLista');

      return Listas(nomeLista: nomeLista, precoTotal: precoTotalSalvo ?? precoTotal);
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
            trailing: IconButton(
    icon: Icon(Icons.delete),
    onPressed: () {
      _showDeleteDialog(index);
    },
  ),
            onTap: () async {
  bool atualizou = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => HomePage(
        nomeLista: _listas[index].nomeLista,
        precoLista: _listas[index].precoTotal.toStringAsFixed(2),
      ),
    ),
  );

  if (atualizou != null && atualizou) {
    // Se atualizou for true, recarregar as listas
    _loadListas();
  }
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
