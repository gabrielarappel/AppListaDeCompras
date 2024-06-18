import 'package:app_lista_de_compras/app/features/items_list.dart';
import 'package:flutter/material.dart';

class MainListView extends StatefulWidget {
  const MainListView({super.key});

  @override
  State<MainListView> createState() => _MainListViewState();
}

class _MainListViewState extends State<MainListView> {
  final List<Map<String, dynamic>> _listasDeCompras = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD2F8D6),
      appBar: AppBar(
        title: const Text(
          "Listas",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xffD2F8D6),
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: _listasDeCompras.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  Center(
                    key: Key(_listasDeCompras[index].toString()),
                    child: FractionallySizedBox(
                      widthFactor: 0.9,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white, // Cor de fundo do Container
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 0,
                              blurRadius: 8,
                              offset: const Offset(
                                  0, 2), // changes position of shadow
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text(
                            "Lista ${index + 1}",
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
                                _formatDate(DateTime
                                    .now()), // Exibe a data atual formatada
                                style: const TextStyle(
                                  color: Colors.black26,
                                  fontSize: 14,
                                ),
                              ),
                              const Divider(),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.attach_money,
                                    color: Colors.black54,
                                  ),
                                  Text(
                                    ": ${_listasDeCompras[index]['preco']}", // Preço vindo dos dados da lista
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete_forever_outlined,
                                color: Colors.red[900], size: 35),
                            onPressed: () {
                              setState(() {
                                _listasDeCompras.removeAt(
                                    index); // Remove o item da lista ao clicar no ícone de delete
                              });
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HomePage()),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          Positioned(
            bottom: 16, // Posição em relação à parte inferior da tela
            right: 16, // Posição em relação à parte direita da tela
            child: FloatingActionButton(
              backgroundColor: const Color(0xFF11E333),
              shape: const CircleBorder(),
              onPressed: () {
// Ação ao pressionar o botão
                setState(() {
// Adiciona um novo item à lista
                  _listasDeCompras.add({
                    'nome': 'Lista ${_listasDeCompras.length + 1}',
                    'preco': '90,00', // Valor exemplo, pode ser dinâmico
                  });
                });
              },
              child: const Icon(Icons.add, size: 40),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
  }
}
