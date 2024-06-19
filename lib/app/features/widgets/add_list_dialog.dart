import 'package:flutter/material.dart';

class AddListDialog extends StatelessWidget {
  final TextEditingController _textFieldController = TextEditingController();
  final Function(String) onAdd;

  AddListDialog({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar Nova Lista'),
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
              child: const Text('Adicionar',
                  style: TextStyle(color: Colors.black)),
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
