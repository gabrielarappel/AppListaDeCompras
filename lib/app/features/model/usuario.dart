class Usuario {
  String username;
  String password;
  List<String> listasDeCompras; // Exemplo de listas de compras do usuário

  Usuario({
    required this.username,
    required this.password,
    this.listasDeCompras = const [], // Inicializa como uma lista vazia
  });

  // Método para converter usuário para JSON
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'listasDeCompras': listasDeCompras,
    };
  }

  // Método para criar usuário a partir de JSON
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      username: json['username'],
      password: json['password'],
      listasDeCompras: List<String>.from(json['listasDeCompras'] ?? []),
    );
  }
}