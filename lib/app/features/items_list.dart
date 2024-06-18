import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Produto {
  double preco;
  String nomeProduto;
  int quantidade;

  Produto({this.nomeProduto = '', this.preco = 0.0, this.quantidade = 0});
}

// ignore: non_constant_identifier_names
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

  const HomePage(
      {super.key, required this.nomeLista, required this.precoLista});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Produto> _compras = [];
  double _totalPreco = 0;

  @override
  void initState() {
    super.initState();
    _loadCompras(); // Carrega os dados ao iniciar a tela
  }

  // Método para carregar os dados salvos
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

  // Método para salvar os dados
  void _saveCompras() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> produtosParaSalvar = _compras
        .map((produto) =>
            "${produto.nomeProduto}:${produto.preco.toString()}:${produto.quantidade.toString()}")
        .toList();
    await prefs.setStringList(
        'compras_${widget.nomeLista}', produtosParaSalvar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFd2f8d6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF11e333),
        title: Text(
          widget.nomeLista,
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: _compras.length,
        itemBuilder: (BuildContext context, int index) {
          return Dismissible(
            key: Key(_compras[index].nomeProduto),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_compras[index].nomeProduto),
                    Text('\$ ${_compras[index].preco.toStringAsFixed(2)}'),
                    Text(' ${_compras[index].quantidade.toStringAsFixed(0)}'),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  color: Colors.red[900],
                  onPressed: () {
                    setState(() {
                      _compras.removeAt(index);
                      _totalPreco = TotalPreco(_compras);
                      _saveCompras(); // Salva os dados após remover um item
                    });
                  },
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff11e333),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              Produto novoProduto = Produto(); // Criando um novo produto vazio

              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: const Text("Adicione um produto"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const SizedBox(height: 12),
                    TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Digite o NOME do produto',
                      ),
                      onChanged: (String value) {
                        novoProduto.nomeProduto =
                            value; // Atualiza o nome do produto
                      },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 200,
                      child: TextField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Digite o PREÇO',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        onChanged: (String value) {
                          novoProduto.preco = double.tryParse(value) ??
                              0.0; // Atualiza o preço do produto
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 200,
                      child: TextField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Digite a QUANTIDADE',
                        ),
                        onChanged: (String value) {
                          novoProduto.quantidade = int.tryParse(value) ??
                              0; // Atualiza a quantidade do produto
                        },
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _compras.add(
                            novoProduto); // Adiciona o novo produto à lista
                        _totalPreco = TotalPreco(
                            _compras); // Atualiza o preço total da lista
                        _saveCompras(); // Salva os dados após adicionar um item
                      });
                      Navigator.of(context).pop();
                    },
                    child: const Text('Adicionar'),
                  )
                ],
              );
            },
          );
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.grey[800],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'R\$ ${_totalPreco.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
