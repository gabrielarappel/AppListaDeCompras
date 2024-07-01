import 'package:flutter/material.dart';

class AddListDialog extends StatelessWidget {
  final TextEditingController _textFieldController = TextEditingController();
  final Function(String) onAdd;
  final String dialogTitle;
  final String initialText;

  AddListDialog({
    super.key,
    required this.onAdd,
    this.dialogTitle = 'Adicionar Nova Lista',
    this.initialText = '',
  }) {
    _textFieldController.text = initialText;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(dialogTitle),
      content: TextField(
        controller: _textFieldController,
        decoration: const InputDecoration(hintText: "Nome da lista"),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              child: Text('Cancelar', style: TextStyle(color: Colors.red[900])),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(dialogTitle.contains('Adicionar') ? 'Adicionar' : 'Salvar',
                  style: const TextStyle(color: Colors.black)),
              onPressed: () {
                final String nomeLista = _textFieldController.text;
                onAdd(nomeLista);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ],
    );
  }
}
