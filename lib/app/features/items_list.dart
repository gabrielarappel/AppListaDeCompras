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
  final String nomeLista;
  final String precoLista;
  final double somaPrecoLista;
  final void Function(double) updateSomaPrecoLista;

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
            isChecked: dados[3] == 'true',
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
            "${produto.nomeProduto}:${produto.preco}:${produto.quantidade}:${produto.isChecked}")
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
                            _saveCompras();
                          });
                        },
                      ),
                      const SizedBox(width: 20),
                      Text(
                        '${_compras[index].nomeProduto}  -  ${_compras[index].quantidade}x',
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
                    widget.updateSomaPrecoLista(_totalPreco);
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
              return AddProductDialog(
                onAddProduct: (Produto novoProduto) {
                  setState(() {
                    _compras.add(novoProduto);
                    _totalPreco = totalPreco(_compras);
                    _saveCompras();
                    widget.updateSomaPrecoLista(_totalPreco);
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

final List<String> _categorias = [
  'Ferramentas',
  'Comida',
  'Eletronicos',
  'Limpeza',
  'Jogos',
  'Bebidas'
];

class DropdownButtonWidget extends StatefulWidget {
  final List<String> categorias;

  const DropdownButtonWidget({super.key, required this.categorias});

  @override
  // ignore: library_private_types_in_public_api
  _DropdownButtonWidgetState createState() => _DropdownButtonWidgetState();
}

class _DropdownButtonWidgetState extends State<DropdownButtonWidget> {
  String dropdownValue = 'Ferramentas'; // Valor inicial do dropdown

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Categorias',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: dropdownValue,
          icon: const Icon(Icons.arrow_drop_down),
          iconSize: 24,
          elevation: 16,
          style: const TextStyle(color: Colors.deepPurple),
          onChanged: (String? newValue) {
            setState(() {
              dropdownValue = newValue!;
            });
          },
          items: _categorias.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }
}
