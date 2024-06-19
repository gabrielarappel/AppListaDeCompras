import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Produto {
  double preco;
  String nomeProduto;
  int quantidade;
  bool isChecked;

  Produto({
    this.nomeProduto = '',
    this.preco = 0.0,
    this.quantidade = 1,
    this.isChecked = false,
  });
}

double totalPreco(List<Produto> produtos) {
  double soma = 0;
  for (var produto in produtos) {
    soma += produto.preco * produto.quantidade;
  }
  return soma;
}

class ItemsList extends StatefulWidget {
  final String nomeLista;
  final String precoLista;
  final double somaPrecoLista;
  final void Function(double)
      updateSomaPrecoLista; // Função para atualizar _somaPrecoLista em MainListView

  const ItemsList({
    super.key,
    required this.nomeLista,
    required this.precoLista,
    required this.somaPrecoLista,
    required this.updateSomaPrecoLista,
  });

  @override
  State<ItemsList> createState() => _ItemsListState();
}

class _ItemsListState extends State<ItemsList> {
  List<Produto> _compras = [];
  double _totalPreco = 0;

  @override
  void initState() {
    super.initState();
    _totalPreco = double.parse(widget.precoLista);
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
            isChecked: false,
          );
        }).toList();
        _totalPreco = totalPreco(_compras);
      });
    }
  }

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
      appBar: AppBar(
        backgroundColor: const Color(0xFF11e333),
        title: Text(
          widget.nomeLista,
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 20),
        itemCount: _compras.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              key: Key(_compras[index].nomeProduto),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _compras[index].isChecked,
                        onChanged: (value) {
                          setState(() {
                            _compras[index].isChecked = value ?? false;
                            _totalPreco = totalPreco(_compras);
                            _saveCompras();
                            widget.updateSomaPrecoLista(
                                _totalPreco); // Atualiza o valor em MainListView
                          });
                        },
                      ),
                      const SizedBox(width: 20),
                      Text(
                        '${_compras[index].nomeProduto}  -  ${_compras[index].quantidade.toStringAsFixed(0)}x',
                        style: TextStyle(
                          decoration: _compras[index].isChecked
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                  Text(' \$ ${_compras[index].preco.toStringAsFixed(2)}'),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                color: Colors.red[900],
                onPressed: () {
                  setState(() {
                    _compras.removeAt(index);
                    _totalPreco = totalPreco(_compras);
                    _saveCompras();
                    widget.updateSomaPrecoLista(
                        _totalPreco); // Atualiza o valor em MainListView
                  });
                },
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
              Produto novoProduto = Produto();

              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: const Text("Adicione um produto"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const SizedBox(
                      height: 12,
                      width: 400,
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Nome do produto',
                      ),
                      onChanged: (String value) {
                        novoProduto.nomeProduto = value;
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 180,
                          child: TextField(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Preço',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            onChanged: (String value) {
                              novoProduto.preco = double.tryParse(value) ?? 0.0;
                            },
                          ),
                        ),
                        SizedBox(
                          width: 180,
                          child: TextField(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Quantidade',
                            ),
                            onChanged: (String value) {
                              novoProduto.quantidade = int.tryParse(value) ?? 0;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            "Cancelar",
                            style: TextStyle(color: Colors.red[900]),
                          )),
                          TextButton(
                    onPressed: () {
                      setState(() {
                        novoProduto.isChecked = false;
                        _compras.add(novoProduto);
                        _totalPreco = totalPreco(_compras);
                        _saveCompras();
                        widget.updateSomaPrecoLista(
                            _totalPreco); // Atualiza o valor em MainListView
                      });
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Adicionar',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                    ],
                  ),
                  
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
