import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_lista_de_compras/app/features/model/produto.dart';
import 'package:app_lista_de_compras/app/features/widgets/bottom_total_price.dart';
import 'package:app_lista_de_compras/app/features/widgets/add_product_dialog.dart'; // Importe o novo widget

double totalPreco(List<Produto> produtos) {
  double soma = 0;
  for (var produto in produtos) {
    soma += produto.preco * produto.quantidade;
  }
  return soma;
}

class ItemsList extends StatefulWidget {
  final String idLista;
  final String nomeLista;
  final String precoLista;
  final double somaPrecoLista;
  final void Function(double) updateSomaPrecoLista;

  const ItemsList({
    super.key,
    required this.idLista,
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
    List<String>? produtosSalvos = prefs.getStringList('compras_${widget.idLista}');
    if (produtosSalvos != null) {
      setState(() {
        _compras = produtosSalvos.map((produtoString) {
          List<String> dados = produtoString.split(':');
          return Produto(
            nomeProduto: dados[0],
            preco: double.parse(dados[1]),
            quantidade: int.parse(dados[2]),
            categoria: dados[3],
            isChecked: dados[4] == 'true',
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
            "${produto.nomeProduto}:${produto.preco}:${produto.quantidade}:${produto.categoria}:${produto.isChecked}")
        .toList();
    await prefs.setStringList('compras_${widget.idLista}', produtosParaSalvar);
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
        itemCount: _compras.length,
        itemBuilder: (BuildContext context, int index) {
          return Dismissible(
            key: Key(_compras[index].nomeProduto), // Chave única para cada item
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              setState(() {
                _compras.removeAt(index);
                _totalPreco = totalPreco(_compras);
                _saveCompras();
                widget.updateSomaPrecoLista(_totalPreco); // Atualiza o preço total na MainListView
              });
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20.0),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: Card(
              child: ListTile(
                title: Row(
                  children: [
                    Checkbox(
                      value: _compras[index].isChecked,
                      onChanged: (value) {
                        setState(() {
                          _compras[index].isChecked = value ?? false;
                          _saveCompras();
                        });
                      },
                    ),
                    Text(
                      _compras[index].nomeProduto,
                      style: TextStyle(
                        decoration: _compras[index].isChecked
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                  ],
                ),
                subtitle: Row(
                  children: [
                    Text("Preço: \$${_compras[index].preco.toStringAsFixed(2)} | "),
                    Text("Quantidade: ${_compras[index].quantidade.toString()} | "),
                    Text("Categoria: ${_compras[index].categoria}"),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _compras.removeAt(index);
                      _totalPreco = totalPreco(_compras);
                      _saveCompras();
                      widget.updateSomaPrecoLista(_totalPreco); // Atualiza o preço total na MainListView
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
              return AddProductDialog(
                onAddProduct: (Produto novoProduto) {
                  setState(() {
                    _compras.add(novoProduto);
                    _totalPreco = totalPreco(_compras);
                    _saveCompras();
                    widget.updateSomaPrecoLista(_totalPreco); // Atualiza o preço total na MainListView
                  });
                },
              );
            },
          );
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      bottomNavigationBar: BottomTotalPrice(totalPreco: _totalPreco),
    );
  }
}
