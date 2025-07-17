

// screens/add_edit_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../models/item.dart';

class AddEditScreen extends StatefulWidget {
  final Item? item;

  const AddEditScreen({Key? key, this.item}) : super(key: key);

  @override
  _AddEditScreenState createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  
  List<CharacteristicPair> _characteristics = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _nameController.text = widget.item!.name;
      _quantityController.text = widget.item!.quantity.toString();
      _characteristics = widget.item!.characteristics.entries
          .map((e) => CharacteristicPair(key: e.key, value: e.value))
          .toList();
    }
    
    if (_characteristics.isEmpty) {
      _characteristics.add(CharacteristicPair());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? 'Agregar Elemento' : 'Editar Elemento'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: Icon(Icons.save),
              onPressed: _saveItem,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre es requerido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              
              // Quantity field
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'Cantidad *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La cantidad es requerida';
                  }
                  final quantity = int.tryParse(value);
                  if (quantity == null || quantity < 0) {
                    return 'Ingrese una cantidad válida';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              
              // Characteristics section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Características',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: _addCharacteristic,
                  ),
                ],
              ),
              SizedBox(height: 8),
              
              // Characteristics list
              ..._characteristics.asMap().entries.map((entry) {
                final index = entry.key;
                final characteristic = entry.value;
                
                return Card(
                  margin: EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              TextFormField(
                                initialValue: characteristic.key,
                                decoration: InputDecoration(
                                  labelText: 'Clave',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                onChanged: (value) {
                                  characteristic.key = value;
                                },
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                initialValue: characteristic.value,
                                decoration: InputDecoration(
                                  labelText: 'Valor',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                onChanged: (value) {
                                  characteristic.value = value;
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeCharacteristic(index),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              
              SizedBox(height: 32),
              
              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Guardar',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addCharacteristic() {
    setState(() {
      _characteristics.add(CharacteristicPair());
    });
  }

  void _removeCharacteristic(int index) {
    setState(() {
      _characteristics.removeAt(index);
    });
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final name = _nameController.text.trim();
      final quantity = int.parse(_quantityController.text);
      
      // Filter out empty characteristics
      final characteristics = <String, String>{};
      for (final char in _characteristics) {
        if (char.key.trim().isNotEmpty && char.value.trim().isNotEmpty) {
          characteristics[char.key.trim()] = char.value.trim();
        }
      }

      final provider = context.read<InventoryProvider>();
      
      if (widget.item == null) {
        await provider.addItem(name, quantity, characteristics);
      } else {
        final updatedItem = widget.item!.copyWith(
          name: name,
          quantity: quantity,
          characteristics: characteristics,
        );
        await provider.updateItem(updatedItem);
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

class CharacteristicPair {
  String key;
  String value;

  CharacteristicPair({this.key = '', this.value = ''});
}