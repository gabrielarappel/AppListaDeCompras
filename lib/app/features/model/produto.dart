class Produto {
  double preco;
  String nomeProduto;
  int quantidade;
  String categoria;
  bool isChecked;

  Produto({
    this.nomeProduto = '',
    this.preco = 0.0,
    this.quantidade = 1,
    this.categoria= '',
    this.isChecked = false,
  });
}