import 'package:flutter/material.dart';
import 'package:app_lista_de_compras/app/features/model/produto.dart';

class AddProductDialog extends StatefulWidget {
  final void Function(Produto) onAddProduct;
  final Produto? initialProduto;

  const AddProductDialog({super.key, required this.onAddProduct, this.initialProduto});

  @override
  AddProductDialogState createState() => AddProductDialogState();
}

class AddProductDialogState extends State<AddProductDialog> {
  late Produto _produto;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _produto = widget.initialProduto ?? Produto();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Text(widget.initialProduto == null ? "Adicione um produto" : "Edite o produto"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 12,
            width: 400,
          ),
          TextField(
            controller: TextEditingController(text: _produto.nomeProduto),
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: 'Nome do produto',
              errorText: _errorText,
            ),
            onChanged: (String value) {
              setState(() {
                _produto.nomeProduto = value;
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
                  controller: TextEditingController(text: _produto.preco.toString()),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Preço',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (String value) {
                    _produto.preco = double.tryParse(value) ?? 0.0;
                  },
                ),
              ),
              SizedBox(
                width: 180,
                child: TextField(
                  controller: TextEditingController(text: _produto.quantidade.toString()),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Quantidade',
                  ),
                  onChanged: (String value) {
                    _produto.quantidade = int.tryParse(value) ?? 1;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: TextEditingController(text: _produto.categoria),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Categoria',
            ),
            onChanged: (String value) {
              _produto.categoria = value;
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
                if (_produto.nomeProduto.isEmpty) {
                  setState(() {
                    _errorText = 'O nome do produto não pode estar vazio';
                  });
                } else {
                  widget.onAddProduct(_produto);
                  Navigator.of(context).pop();
                }
              },
              child: Text(
                widget.initialProduto == null ? 'Adicionar' : 'Salvar',
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
