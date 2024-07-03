class Usuario {
  String username;
  String password;
  List<String> listasDeCompras; 
  List<String> convitesPendentes; 

  Usuario({
    required this.username,
    required this.password,
    this.listasDeCompras = const [],
    this.convitesPendentes = const [], 
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