import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../models/item.dart';
import 'add_edit_screen.dart';
import 'config_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inventario Móvil'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search bar with config button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Config button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.pink,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.settings, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConfigScreen(),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: 12),
                // Search bar
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar elementos...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onChanged: (value) {
                      context.read<InventoryProvider>().search(value);
                    },
                  ),
                ),
              ],
            ),
          ),
          // Items list
          Expanded(
            child: Consumer<InventoryProvider>(
              builder: (context, provider, child) {
                if (provider.items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          provider.searchQuery.isEmpty 
                              ? 'No hay elementos en el inventario'
                              : 'No se encontraron elementos',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: provider.items.length,
                  itemBuilder: (context, index) {
                    final item = provider.items[index];
                    return ItemCard(item: item);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditScreen(),
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class ItemCard extends StatelessWidget {
  final Item item;

  const ItemCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.pink,
          foregroundColor: Colors.white,
          child: Text(
            item.name.isNotEmpty ? item.name[0].toUpperCase() : '?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          item.name,
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cantidad: ${item.quantity}'),
            if (item.characteristics.isNotEmpty)
              Text(
                item.getCharacteristicsSummary(),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton(
          onSelected: (value) {
            if (value == 'delete') {
              _showDeleteConfirmation(context);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Eliminar'),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditScreen(item: item),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar eliminación'),
        content: Text('¿Está seguro de que desea eliminar "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<InventoryProvider>().deleteItem(item.id);
              Navigator.pop(context);
            },
            child: Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}