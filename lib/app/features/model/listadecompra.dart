class ListaDeCompra {
  String id;
  String nome;
  double preco;

  ListaDeCompra({
    required this.id,
    required this.nome,
    required this.preco,
  });

  factory ListaDeCompra.fromJson(Map<String, dynamic> json) {
    return ListaDeCompra(
      id: json['id'] as String,
      nome: json['nome'] as String,
      preco: (json['preco'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'preco': preco,
    };
  }
}
