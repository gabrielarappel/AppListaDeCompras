import 'package:flutter/material.dart';

class RemoveListDialog extends StatelessWidget {
  final String listName;
  final VoidCallback onConfirm;

  const RemoveListDialog({
    required this.listName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AlertDialog(
        title: Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja excluir a lista "$listName"?'),
        actions: <Widget>[
          TextButton(
            child: Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Excluir'),
            onPressed: () {
              Navigator.of(context).pop(); // Fecha o diálogo de confirmação
              onConfirm(); // Chama a função de confirmação
            },
          ),
        ],
      ),
    );
  }
}
