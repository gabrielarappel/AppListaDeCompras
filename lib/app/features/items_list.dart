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
    Key? key,
    required this.nomeLista,
    required this.precoLista,
    required this.somaPrecoLista,
    required this.updateSomaPrecoLista,
  }) : super(key: key);

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
              padding: EdgeInsets.only(right: 20.0),
              child: Icon(Icons.delete, color: Colors.white),
            ),
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
final List<String> _categorias = [
  'Adicione categoria',
  'Ferramentas',
  'Comida',
  'Eletronicos',
  'Limpeza',
  'Jogos',
  'Bebidas'
];

final Map<String, Color> categoriaCores = {
  'Adicione categoria':Colors.black,
  'Ferramentas': Colors.blue,
  'Comida': Colors.red,
  'Eletronicos': Colors.green,
  'Limpeza': Colors.orange,
  'Jogos': Colors.purple,
  'Bebidas': Colors.brown,
};

class DropdownButtonWidget extends StatefulWidget {
  final List<String> categorias;

  const DropdownButtonWidget({super.key, required this.categorias});

  @override
  // ignore: library_private_types_in_public_api
  _DropdownButtonWidgetState createState() => _DropdownButtonWidgetState();
}

class _DropdownButtonWidgetState extends State<DropdownButtonWidget> {
  String dropdownValue = 'Adicione categoria'; // Valor inicial do dropdown

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
              child:
                  Text(value, style: TextStyle(color: categoriaCores[value])),
            );
          }).toList(),
        ),
      ),
    );
  }
}
