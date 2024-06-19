import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Produto {
  
  String nomeProduto;
  double preco;
  int quantidade;

  Produto({this.nomeProduto = '', this.preco = 0.0, this.quantidade = 0});
}

double TotalPreco(List<Produto> produtos) {
  double soma = 0;

  for (var produto in produtos) {
    soma += produto.preco * produto.quantidade;
  }
  return soma;
}

class HomePage extends StatefulWidget {
  final String nomeLista;
  final String precoLista;

  HomePage({Key? key, required this.nomeLista, required this.precoLista})
      : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Produto> _compras = [];
  double _totalPreco = 0;

  @override
  void initState() {
    super.initState();
    _loadCompras();
  }

  void _loadCompras() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? produtosSalvos =
        prefs.getStringList('compras_${widget.nomeLista}');
    if (produtosSalvos != null) {
      setState(() {
        _compras = produtosSalvos.map((produtoString) {
          List<String> dados = produtoString.split(':');
          return Produto(
            nomeProduto: dados[0],
            preco: double.parse(dados[1]),
            quantidade: int.parse(dados[2]),
          );
        }).toList();
        _totalPreco = TotalPreco(_compras);
      });
    }
  }

  void _saveCompras() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  
  // Salvar produtos
  List<String> produtosParaSalvar = _compras
      .map((produto) =>
          "${produto.nomeProduto}:${produto.preco.toString()}:${produto.quantidade.toString()}")
      .toList();
  await prefs.setStringList('compras_${widget.nomeLista}', produtosParaSalvar);

  // Calcular e salvar o preço total
  double precoTotal = TotalPreco(_compras);
  await prefs.setDouble('precoTotal_${widget.nomeLista}', precoTotal);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nomeLista),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, true); // Quando retorna a list_page, é enviado um sinal para que a página atualize
          },
        ),
      ),
      body: ListView.builder(
        itemCount: _compras.length,
        itemBuilder: (BuildContext context, int index) {
          return Dismissible(
            key: Key(_compras[index].nomeProduto),
            child: Card(
              child: ListTile(
                title: Text(_compras[index].nomeProduto),
                subtitle: Text(
                  'Preço: \$${_compras[index].preco.toStringAsFixed(2)} | Quantidade: ${_compras[index].quantidade.toString()}',
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _compras.removeAt(index);
                      _totalPreco = TotalPreco(_compras);
                      _saveCompras();
                    });
                  },
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              Produto novoProduto = Produto();

              return AlertDialog(
                title: Text('Adicionar Produto'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Nome do Produto',
                      ),
                      onChanged: (value) {
                        novoProduto.nomeProduto = value;
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Preço',
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (value) {
                        novoProduto.preco = double.parse(value);
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Quantidade',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        novoProduto.quantidade = int.parse(value);
                      },
                    ),
                  ],
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _compras.add(novoProduto);
                        _totalPreco = TotalPreco(_compras);
                        _saveCompras();
                      });
                      Navigator.of(context).pop();
                    },
                    child: Text('Adicionar'),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total:',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'R\$ ${_totalPreco.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
