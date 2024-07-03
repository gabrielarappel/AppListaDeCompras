import 'package:flutter/material.dart';

class AddUserInListDialog extends StatelessWidget {
  final Function(String) onAdd;

  const AddUserInListDialog({Key? key, required this.onAdd}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Adicionar Usuário à Lista'),
      content: TextField(
        decoration: InputDecoration(
          hintText: 'Nome do usuário',
        ),
        onChanged: (value) {
          // Implemente lógica para buscar o usuário pelo nome, se necessário
        },
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancelar'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Adicionar'),
          onPressed: () {
            // Implemente lógica para adicionar o usuário à lista
            onAdd('Usuário adicionado'); // Exemplo simples, passando o nome do usuário
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
