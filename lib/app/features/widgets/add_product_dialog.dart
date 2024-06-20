import 'package:flutter/material.dart';
import 'package:app_lista_de_compras/app/features/model/produto.dart';

class AddProductDialog extends StatefulWidget {
  final void Function(Produto) onAddProduct;

  const AddProductDialog({super.key, required this.onAddProduct});

  @override
  AddProductDialogState createState() => AddProductDialogState();
}

class AddProductDialogState extends State<AddProductDialog> {
  Produto novoProduto = Produto();
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: const Text("Adicione um produto"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 12,
            width: 400,
          ),
          TextField(
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: 'Nome do produto',
              errorText: _errorText,
            ),
            onChanged: (String value) {
              setState(() {
                novoProduto.nomeProduto = value;
                _errorText = null;
              });
            },
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 180,
                child: TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Preço',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (String value) {
                    novoProduto.preco = double.tryParse(value) ?? 0.0;
                  },
                ),
              ),
              SizedBox(
                width: 180,
                child: TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Quantidade',
                  ),
                  onChanged: (String value) {
                    novoProduto.quantidade = int.tryParse(value) ?? 1;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Categoria',
            ),
            onChanged: (String value) {
              novoProduto.categoria = value;
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Cancelar",
                style: TextStyle(color: Colors.red[900]),
              ),
            ),
            TextButton(
              onPressed: () {
                if (novoProduto.nomeProduto.isEmpty) {
                  setState(() {
                    _errorText = 'O nome do produto não pode estar vazio';
                  });
                } else {
                  novoProduto.isChecked = false;
                  widget.onAddProduct(novoProduto);
                  Navigator.of(context).pop();
                }
              },
              child: const Text(
                'Adicionar',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
