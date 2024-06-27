import 'package:app_lista_de_compras/app/features/model/produto.dart';
class ListaDeCompra {
  String id;
  String nome;
  double preco;
  List<Produto> produtos;

  ListaDeCompra({
    required this.id,
    required this.nome,
    required this.preco,
    required this.produtos,
  });

  factory ListaDeCompra.fromJson(Map<String, dynamic> json) {
    var produtosList = json['produtos'] as List<dynamic>;
    List<Produto> produtos = produtosList.map((item) => Produto.fromJson(item as Map<String, dynamic>)).toList();

    return ListaDeCompra(
      id: json['id'] as String,
      nome: json['nome'] as String,
      preco: (json['preco'] as num).toDouble(),
      produtos: produtos,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'preco': preco,
      'produtos': produtos.map((produto) => produto.toJson()).toList(),
    };
  }
}
