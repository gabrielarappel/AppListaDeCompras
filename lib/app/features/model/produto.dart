class Produto {
  String nomeProduto;
  double preco;
  int quantidade;
  String categoria;
  bool isChecked;

  Produto({
    this.nomeProduto = '',
    this.preco = 0.0,
    this.quantidade = 1,
    this.categoria = '',
    this.isChecked = false,
  });

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      nomeProduto: json['nomeProduto'] as String,
      preco: (json['preco'] as num).toDouble(),
      quantidade: json['quantidade'] as int,
      categoria: json['categoria'] as String,
      isChecked: json['isChecked'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nomeProduto': nomeProduto,
      'preco': preco,
      'quantidade': quantidade,
      'categoria': categoria,
      'isChecked': isChecked,
    };
  }
}
