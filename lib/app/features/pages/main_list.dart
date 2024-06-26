import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_lista_de_compras/app/features/model/listadecompra.dart';
import 'package:app_lista_de_compras/app/features/pages/items_list.dart';
import 'package:app_lista_de_compras/app/features/widgets/add_list_dialog.dart';

class MainListView extends StatefulWidget {
  final String username;

  const MainListView({Key? key, required this.username}) : super(key: key);

  @override
  _MainListViewState createState() => _MainListViewState();
}

class _MainListViewState extends State<MainListView> {
  late CollectionReference _usersCollection;
  late CollectionReference _listasCollection;

  @override
  void initState() {
    super.initState();
    _usersCollection = FirebaseFirestore.instance.collection('users');
    _listasCollection = FirebaseFirestore.instance.collection('listasDeCompras');
  }

  void _addLista(String nome) async {
    DocumentReference docRef = await _listasCollection.add({
      'nome': nome,
      'preco': 0.0,
    });
    await _usersCollection.doc(widget.username).update({
      'listasDeCompras': FieldValue.arrayUnion([docRef.id])
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listas de Compras'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _usersCollection.doc(widget.username).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar listas'));
          }

          Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;
          List<String> listasDeCompras = List<String>.from(userData['listasDeCompras'] ?? []);

          return ListView.builder(
            itemCount: listasDeCompras.length,
            itemBuilder: (context, index) {
              return FutureBuilder<DocumentSnapshot>(
                future: _listasCollection.doc(listasDeCompras[index]).get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(title: Text('Carregando...'));
                  }
                  if (snapshot.hasError) {
                    return const ListTile(title: Text('Erro ao carregar lista'));
                  }

                  ListaDeCompra lista = ListaDeCompra.fromJson(snapshot.data!.data() as Map<String, dynamic>);
                  return ListTile(
                    title: Text(lista.nome),
                    subtitle: Text('Total: R\$ ${lista.preco.toStringAsFixed(2)}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ItemsListPage(
                            listaId: listasDeCompras[index],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AddListDialog(onAdd: _addLista);
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
