import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_lista_de_compras/app/features/model/listadecompra.dart';
import 'package:app_lista_de_compras/app/features/model/produto.dart'; // Importe a classe Produto
import 'package:app_lista_de_compras/app/features/pages/items_list.dart';
import 'package:app_lista_de_compras/app/features/widgets/add_list_dialog.dart';


import 'package:uuid/uuid.dart';

import 'user_manager.dart';

class MainListView extends StatefulWidget {
  final String username;

  const MainListView({Key? key, required this.username}) : super(key: key);

  @override
  State<MainListView> createState() => _MainListViewState();
}

class _MainListViewState extends State<MainListView> {
  final List<ListaDeCompra> _listasDeCompras = [];
  double _somaPrecoLista = 0.0;
  bool _isLoading = false; // Adicionei uma flag de carregamento
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _isLoading = true; // Inicia o estado de carregamento
    _loadListasDeCompras();
  }

  Future<void> _loadListasDeCompras() async {
    try {
      print('Carregando listas para o usuário: ${widget.username}');
      final querySnapshot = await FirebaseFirestore.instance
          .collection('listas_de_compras')
          .where('username', isEqualTo: widget.username)
          .get();

      setState(() {
        _listasDeCompras.clear();
        for (var doc in querySnapshot.docs) {
          final data = doc.data();
          print('Documento carregado: ${doc.id} com dados: $data');

          // Converte a lista de produtos do Firestore em objetos Produto
          List<Produto> produtosList = [];
          if (data['produtos'] != null) {
            produtosList = (data['produtos'] as List<dynamic>)
                .map((item) => Produto(
                      nomeProduto: item['nomeProduto'],
                      preco: item['preco'],
                      quantidade: item['quantidade'],
                      categoria: item['categoria'],
                      isChecked: item['isChecked'],
                    ))
                .toList();
          }

          _listasDeCompras.add(ListaDeCompra(
            id: doc.id,
            nome: data['nome'] ?? 'Lista Sem Nome', // Trate o caso de nome nulo
            preco:
                (data['preco'] ?? 0.0).toDouble(), // Trate o caso de preço nulo
            produtos: produtosList,
          ));
        }
        _updateSomaPrecoLista();
        _isLoading = false; // Finaliza o estado de carregamento
      });
    } catch (e) {
      print('Erro ao carregar listas: $e');
      setState(() {
        _isLoading = false; // Finaliza o estado de carregamento em caso de erro
      });
    }
  }

  void _updateSomaPrecoLista() {
    double total = 0;
    for (var lista in _listasDeCompras) {
      total += lista.preco;
    }
    setState(() {
      _somaPrecoLista = total;
    });
  }

  Future<void> _saveListasDeCompras() async {
    final batch = FirebaseFirestore.instance.batch();

    for (var item in _listasDeCompras) {
      final docRef = FirebaseFirestore.instance
          .collection('listas_de_compras')
          .doc(item.id);

      batch.set(docRef, {
        'nome': item.nome,
        'preco': item.preco,
        'username': widget.username,
        'produtos': item.produtos
            .map((produto) => produto.toJson())
            .toList(), // Converte produtos para JSON
      });
    }

    await batch.commit();
  }

  Future<void> _deleteLista(String id) async {
    try {
      // Remove localmente
      setState(() {
        _listasDeCompras.removeWhere((lista) => lista.id == id);
        _updateSomaPrecoLista();
      });

      // Remove no Firestore
      await FirebaseFirestore.instance
          .collection('listas_de_compras')
          .doc(id)
          .delete();
    } catch (e) {
      print('Erro ao excluir lista: $e');
      // Se ocorrer um erro, reverta as alterações locais
      setState(() {
        _loadListasDeCompras(); // Recarrega as listas para restaurar o estado anterior
      });
    }
  }

  void _showAddListDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AddListDialog(
          onAdd: (nomeLista) async {
            String id = _uuid.v4();
            _listasDeCompras.add(ListaDeCompra(
              id: id,
              nome: nomeLista,
              preco: 0.0,
              produtos: [],
            ));
            await UserManager.addListaDeCompras(
                widget.username, id); // Adiciona lista ao usuário
            _saveListasDeCompras();
            _updateSomaPrecoLista();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD2F8D6),
      appBar: AppBar(
        title: const Text(
          "Minhas Listas",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 32,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 88, 156, 95),
      ),
      body: _isLoading
          ? Center(
              child:
                  CircularProgressIndicator(), // Mostra um indicador de carregamento
            )
          : _listasDeCompras.isEmpty
              ? Center(
                  child: Text(
                    "Crie suas listas de compras!",
                    style: TextStyle(fontSize: 24),
                  ),
                )
              : ListView.builder(
                  itemCount: _listasDeCompras.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        const SizedBox(
                          height: 30,
                        ),
                        Center(
                          key: Key(_listasDeCompras[index].id),
                          child: FractionallySizedBox(
                            widthFactor: 0.9,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 0,
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                title: Text(
                                  _listasDeCompras[index].nome.isEmpty
                                      ? "Lista ${index + 1}"
                                      : _listasDeCompras[index].nome,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _formatDate(DateTime.now()),
                                      style: const TextStyle(
                                        color: Colors.black26,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const Divider(),
                                    Text(
                                      '\$ ${_listasDeCompras[index].preco.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 35,
                                  ),
                                  onPressed: () async {
                                    await _deleteLista(
                                        _listasDeCompras[index].id);
                                  },
                                ),
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ItemsList(
                                        idLista: _listasDeCompras[index].id,
                                        nomeLista: _listasDeCompras[index].nome,
                                        precoLista: _listasDeCompras[index]
                                            .preco
                                            .toString(),
                                        somaPrecoLista: _somaPrecoLista,
                                        updateSomaPrecoLista:
                                            (double novoTotal) {
                                          setState(() {
                                            _listasDeCompras[index].preco =
                                                novoTotal;
                                            _saveListasDeCompras();
                                            _updateSomaPrecoLista();
                                          });
                                        },
                                      ),
                                    ),
                                  );
                                  _updateSomaPrecoLista();
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF11E333),
        shape: const CircleBorder(),
        onPressed: _showAddListDialog,
        child: const Icon(
          Icons.add,
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
  }
}
