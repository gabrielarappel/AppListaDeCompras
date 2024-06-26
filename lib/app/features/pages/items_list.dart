import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_lista_de_compras/app/features/model/produto.dart';
import 'package:app_lista_de_compras/app/features/widgets/add_product_dialog.dart';
import 'package:app_lista_de_compras/app/features/widgets/bottom_total_price.dart';

class ItemsListPage extends StatefulWidget {
  final String listaId;

  const ItemsListPage({Key? key, required this.listaId}) : super(key: key);

  @override
  _ItemsListPageState createState() => _ItemsListPageState();
}

class _ItemsListPageState extends State<ItemsListPage> {
  late CollectionReference _listasCollection;
  late CollectionReference _produtosCollection;

  @override
  void initState() {
    super.initState();
    _listasCollection = FirebaseFirestore.instance.collection('listasDeCompras');
    _produtosCollection = _listasCollection.doc(widget.listaId).collection('produtos');
  }

  void _addProduto(Produto produto) async {
    await _produtosCollection.add(produto.toJson());
    _updateTotalPreco();
  }

  void _updateTotalPreco() async {
    QuerySnapshot querySnapshot = await _produtosCollection.get();
    double totalPreco = querySnapshot.docs
        .map((doc) => Produto.fromJson(doc.data() as Map<String, dynamic>).preco)
        .fold(0.0, (previous, current) => previous + current);

    await _listasCollection.doc(widget.listaId).update({'preco': totalPreco});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _produtosCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar produtos'));
          }

          double totalPreco = snapshot.data!.docs
              .map((doc) => Produto.fromJson(doc.data() as Map<String, dynamic>).preco)
              .fold(0.0, (previous, current) => previous + current);

          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: snapshot.data!.docs.map((doc) {
                    Produto produto = Produto.fromJson(doc.data() as Map<String, dynamic>);
                    return ListTile(
                      title: Text(produto.nomeProduto),
                      subtitle: Text('R\$ ${produto.preco.toStringAsFixed(2)}'),
                      trailing: Text('Qtd: ${produto.quantidade}'),
                    );
                  }).toList(),
                ),
              ),
              BottomTotalPrice(totalPreco: totalPreco),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AddProductDialog(onAddProduct: _addProduto);
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
