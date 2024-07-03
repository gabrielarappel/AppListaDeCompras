import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_lista_de_compras/app/features/model/produto.dart';
import 'package:app_lista_de_compras/app/features/widgets/add_product_dialog.dart';
import 'package:app_lista_de_compras/app/features/widgets/bottom_total_price.dart';

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
    final docSnapshot = await FirebaseFirestore.instance
        .collection('produtos_salvar')
        .doc(widget.idLista)
        .get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data() as Map<String, dynamic>;
      final produtosList = data['produtos'] as List<dynamic>;

      setState(() {
        _compras = produtosList.map((produtoMap) {
          return Produto(
            nomeProduto: produtoMap['nomeProduto'],
            preco: produtoMap['preco'],
            quantidade: produtoMap['quantidade'],
            categoria: produtoMap['categoria'],
            isChecked: produtoMap['isChecked'],
          );
        }).toList();
        _totalPreco = totalPreco(_compras);
      });
    }
  }

  void _saveCompras() async {
    final produtosParaSalvar = _compras.map((produto) {
      return {
        'nomeProduto': produto.nomeProduto,
        'preco': produto.preco,
        'quantidade': produto.quantidade,
        'categoria': produto.categoria,
        'isChecked': produto.isChecked,
      };
    }).toList();

    await FirebaseFirestore.instance
        .collection('produtos_salvar')
        .doc(widget.idLista)
        .set({
          'produtos': produtosParaSalvar,
        });
  }

  void _removeProduto(int index) {
    setState(() {
      _compras.removeAt(index);
      _totalPreco = totalPreco(_compras);
      _saveCompras();
      widget.updateSomaPrecoLista(_totalPreco);
    });
  }

  void _editProduto(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddProductDialog(
          initialProduto: _compras[index],
          onAddProduct: (Produto produtoEditado) {
            setState(() {
              _compras[index] = produtoEditado;
              _totalPreco = totalPreco(_compras);
              _saveCompras();
              widget.updateSomaPrecoLista(_totalPreco); // Atualiza o preço total na MainListView
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 88, 156, 95),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
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
              _removeProduto(index);
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
                      activeColor: Colors.green,
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
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _editProduto(index);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _removeProduto(index);
                      },
                    ),
                  ],
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
