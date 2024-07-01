import 'package:flutter/material.dart';
import 'package:app_lista_de_compras/app/features/model/produto.dart';

class AddProductDialog extends StatefulWidget {
  final void Function(Produto) onAddProduct;
  final Produto? initialProduto;

  const AddProductDialog({Key? key, required this.onAddProduct, this.initialProduto}) : super(key: key);

  @override
  AddProductDialogState createState() => AddProductDialogState();
}

class AddProductDialogState extends State<AddProductDialog> {
  late Produto _produto;
  String? _errorText;
  late TextEditingController _nomeController;
  late TextEditingController _precoController;
  late TextEditingController _quantidadeController;
  late TextEditingController _categoriaController;

  @override
  void initState() {
    super.initState();
    _produto = widget.initialProduto ?? Produto();

    // Initialize controllers
    _nomeController = TextEditingController(text: _produto.nomeProduto);
    _precoController = TextEditingController(text: _produto.preco.toString());
    _quantidadeController = TextEditingController(text: _produto.quantidade.toString());
    _categoriaController = TextEditingController(text: _produto.categoria);
  }

  @override
  void dispose() {
    // Dispose controllers
    _nomeController.dispose();
    _precoController.dispose();
    _quantidadeController.dispose();
    _categoriaController.dispose();
    super.dispose();
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
          const SizedBox(height: 12),
          TextField(
            controller: _nomeController,
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
                width: 110,
                child: TextField(
                  controller: _precoController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Preço',
                    labelStyle: TextStyle(fontSize: 12), 
                     
                    hintText: 'Preço',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (String value) {
                    _produto.preco = double.tryParse(value) ?? 0.0;
                  },
                ),
              ),
              SizedBox(
                width: 90,
                child: TextField(
                  controller: _quantidadeController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Quantidade', 
                    labelStyle: TextStyle(fontSize: 12), 
                    hintText: 'quantidade',
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
            controller: _categoriaController,
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
