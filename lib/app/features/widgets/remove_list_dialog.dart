import 'package:flutter/material.dart';

class RemoveListDialog extends StatefulWidget {
  final String listName;

  const RemoveListDialog({
    required this.listName,
  });

  @override
  _RemoveListDialogState createState() => _RemoveListDialogState();
}

class _RemoveListDialogState extends State<RemoveListDialog> {
  bool _confirmouExclusaoLista = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Confirmar Exclusão'),
      content:
          Text('Tem certeza que deseja excluir a lista "${widget.listName}"?'),
      actions: <Widget>[
        TextButton(
          child: Text('Cancelar'),
          onPressed: () {
            Navigator.of(context).pop(); // Fecha o diálogo
          },
        ),
        TextButton(
          child: Text('Excluir'),
          onPressed: () {
            Navigator.of(context).pop(true); // Retorna true ao fechar o diálogo
          },
        ),
      ],
    );
  }
}
