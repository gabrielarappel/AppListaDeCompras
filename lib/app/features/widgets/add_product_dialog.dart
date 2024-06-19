import 'package:flutter/material.dart';
import 'package:app_lista_de_compras/app/features/model/produto.dart';

class AddProductDialog extends StatelessWidget {
  final void Function(Produto) onAddProduct;

  const AddProductDialog({Key? key, required this.onAddProduct}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Produto novoProduto = Produto();

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
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Nome do produto',
            ),
            onChanged: (String value) {
              novoProduto.nomeProduto = value;
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
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
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
                novoProduto.isChecked = false;
                onAddProduct(novoProduto);
                Navigator.of(context).pop();
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
// TODO Implement this library.