import 'package:app_lista_de_compras/app/features/pages/notification_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_lista_de_compras/app/features/model/listadecompra.dart';
import 'package:app_lista_de_compras/app/features/model/produto.dart';
import 'package:app_lista_de_compras/app/features/pages/items_page.dart';
import 'package:app_lista_de_compras/app/features/widgets/add_list_dialog.dart';
import 'package:app_lista_de_compras/app/features/widgets/remove_list_dialog.dart';
import 'package:app_lista_de_compras/app/features/widgets/add_user_in_list_dialog.dart';
import 'package:uuid/uuid.dart';
import 'package:app_lista_de_compras/app/features/pages/login_page.dart';
import 'package:app_lista_de_compras/app/features/manager/notification_service.dart';
import 'package:app_lista_de_compras/app/features/manager/user_manager.dart';


class MainListView extends StatefulWidget {
  final String username;

  const MainListView({Key? key, required this.username}) : super(key: key);

  @override
  State<MainListView> createState() => _MainListViewState();
}

class _MainListViewState extends State<MainListView> {
  final List<ListaDeCompra> _listasDeCompras = [];
  double _somaPrecoLista = 0.0;
  bool _isLoading = false;
  final Uuid _uuid = const Uuid();
  int _currentIndex = 1; // Alterado para iniciar na aba de listas

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _loadListasDeCompras();
  }

  Future<void> _loadListasDeCompras() async {
    try {
      print('Carregando listas para o usuário: ${widget.username}');
      final userLists = await FirebaseFirestore.instance
          .collection('listas_de_compras')
          .where('username', isEqualTo: widget.username)
          .get();

      final sharedLists = await FirebaseFirestore.instance
          .collection('convites_pendentes')
          .where('toUsername', isEqualTo: widget.username)
          .where('status', isEqualTo: 'aceito')
          .get();

      List<ListaDeCompra> loadedLists = [];
      for (var doc in userLists.docs) {
        final data = doc.data();
        _addListaFromFirestoreData(doc.id, data, loadedLists);
      }
      for (var invite in sharedLists.docs) {
        final listaDoc = await FirebaseFirestore.instance
            .collection('listas_de_compras')
            .doc(invite['idLista'])
            .get();
        final data = listaDoc.data();
        if (data != null) {
          _addListaFromFirestoreData(invite['idLista'], data, loadedLists);
        }
      }

      setState(() {
        _listasDeCompras.clear();
        _listasDeCompras.addAll(loadedLists);
        _updateSomaPrecoLista();
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar listas: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

void _addListaFromFirestoreData(String id, Map<String, dynamic> data, List<ListaDeCompra> loadedLists) {
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

    loadedLists.add(ListaDeCompra(
      id: id,
      nome: data['nome'] ?? 'Lista Sem Nome',
      preco: (data['preco'] ?? 0.0).toDouble(),
      produtos: produtosList,
    ));
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

  void _deleteLista(String id) async {
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
      return AddUserInListDialog(
        onAdd: (username) async {
          try {
            await FirebaseFirestore.instance.collection('convites_pendentes').add({
              'fromUsername': widget.username,
              'toUsername': username,
              'idLista': _uuid.v4(), // ou use o ID da lista real
              'status': 'pendente',
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Convite enviado para $username')),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erro ao enviar convite: $e')),
            );
          }
        },
      );
    },
  );
}


  void _showEditListDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AddListDialog(
          dialogTitle: 'Editar Nome da Lista',
          initialText: _listasDeCompras[index].nome,
          onAdd: (newName) {
            setState(() {
              _listasDeCompras[index].nome = newName;
              _saveListasDeCompras();
            });
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
          "iBuy",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 32,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 88, 156, 95),
        actions: [
          IconButton(
  icon: Stack(
    children: <Widget>[
      Icon(Icons.notifications),
      if (NotificationService.unreadNotificationsCount > 0)
        Positioned(
          right: 0,
          child: Container(
            padding: EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(6),
            ),
            constraints: BoxConstraints(
              minWidth: 12,
              minHeight: 12,
            ),
            child: Text(
              '${NotificationService.unreadNotificationsCount}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        )
    ],
  ),
  onPressed: () {
    // Abrir uma nova tela com as notificações
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NotificationPage()),
    );
  },
),

        ],
      ),
      body: _isLoading
          ? Center(
              child:
                  CircularProgressIndicator(), // Mostra um indicador de carregamento
            )
          : _currentIndex == 0
              ? UserProfile(username: widget.username)
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
                                    leading: IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        size: 30,
                                      ),
                                      onPressed: () {
                                        _showEditListDialog(index);
                                      },
                                    ),
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            _listasDeCompras[index].nome.isEmpty
                                                ? "Lista ${index + 1}"
                                                : _listasDeCompras[index].nome,
                                            style: const TextStyle(
                                              color: Colors.black87,
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return RemoveListDialog(
                                              listName:
                                                  _listasDeCompras[index].nome,
                                            );
                                          },
                                        ).then((value) {
                                          if (value != null && value) {
                                            // Verifica se a exclusão foi confirmada
                                            _deleteLista(
                                                _listasDeCompras[index].id);
                                          }
                                        });
                                      },
                                    ),
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ItemsList(
                                            idLista: _listasDeCompras[index].id,
                                            nomeLista:
                                                _listasDeCompras[index].nome,
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
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF11E333),
              shape: const CircleBorder(),
              onPressed: _showAddListDialog,
              child: const Icon(
                Icons.add,
                size: 40,
                color: Colors.white,
              ),
            )
          : null, // Adicionado para mostrar apenas na aba de listas
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Listas',
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
  }
}

class UserProfile extends StatelessWidget {
  final String username;

  UserProfile({required this.username});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Bem vindo, $username !'),
          SizedBox(height: 10.0),
          ElevatedButton(
            onPressed: () {
              // Implemente a lógica de logout aqui
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
                (Route<dynamic> route) => false,
              );
            },
            child: Text('Sair'),
          ),
        ],
      ),
    );
  }
}
