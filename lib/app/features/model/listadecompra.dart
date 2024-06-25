class ListaDeCompra {
  String id;
  String nome;
  double preco;

  ListaDeCompra({
    required this.id,
    required this.nome,
    required this.preco,
  });

  ListaDeCompra.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        nome = json['nome'],
        preco = json['preco'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'preco': preco,
      };
}