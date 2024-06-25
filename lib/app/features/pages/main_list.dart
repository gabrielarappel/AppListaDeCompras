import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'items_list.dart';
import '../widgets/add_list_dialog.dart';
import 'user_manager.dart';
import 'package:app_lista_de_compras/app/features/model/listadecompra.dart';


class MainListView extends StatefulWidget {
  final String username;

  const MainListView({Key? key, required this.username}) : super(key: key);

  @override
  State<MainListView> createState() => _MainListViewState();
}

class _MainListViewState extends State<MainListView> {
  final List<ListaDeCompra> _listasDeCompras = [];
  double _somaPrecoLista = 0.0;
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _loadListasDeCompras();
  }

  Future<void> _loadListasDeCompras() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? listasDeComprasString =
        prefs.getStringList('listasDeCompras_${widget.username}');
    if (listasDeComprasString != null) {
      setState(() {
        _listasDeCompras.clear();
        _listasDeCompras.addAll(listasDeComprasString.map((item) {
          final parts = item.split(';');
          return ListaDeCompra(
            id: parts[0],
            nome: parts[1],
            preco: double.parse(parts[2]),
          );
        }).toList());
        _updateSomaPrecoLista();
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
    final prefs = await SharedPreferences.getInstance();
    final List<String> listasDeComprasString =
        _listasDeCompras.map((item) => '${item.id};${item.nome};${item.preco}').toList();
    prefs.setStringList('listasDeCompras_${widget.username}', listasDeComprasString);
  }

  Future<void> _deleteLista(String id) async {
    setState(() {
      _listasDeCompras.removeWhere((lista) => lista.id == id);
      _saveListasDeCompras();
      _updateSomaPrecoLista();
    });
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
            ));
            await UserManager.addListaDeCompras(widget.username, id); // Adiciona lista ao usuário
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
        backgroundColor: const Color(0xffD2F8D6),
      ),
      body: _listasDeCompras.isEmpty
          ? const Center(
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
                                await _deleteLista(_listasDeCompras[index].id);
                              },
                            ),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ItemsList(
                                    idLista: _listasDeCompras[index].id,
                                    nomeLista: _listasDeCompras[index].nome,
                                    precoLista: _listasDeCompras[index].preco.toString(),
                                    somaPrecoLista: _somaPrecoLista,
                                    updateSomaPrecoLista: (double novoTotal) {
                                      setState(() {
                                        _listasDeCompras[index].preco = novoTotal;
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
