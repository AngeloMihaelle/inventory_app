import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/item.dart';
import '../database/database_helper.dart';

class InventoryProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Uuid _uuid = Uuid();
  
  List<Item> _items = [];
  List<Item> _filteredItems = [];
  String _searchQuery = '';

  List<Item> get items => _filteredItems;
  List<Item> get allItems => _items;
  String get searchQuery => _searchQuery;

  // Get all items without filtering (for export)
  List<Item> getAllItems() => List.from(_items);

  InventoryProvider() {
    loadItems();
  }

  Future<void> loadItems() async {
    _items = await _dbHelper.getAllItems();
    _applySearch();
    notifyListeners();
  }

  Future<void> addItem(String name, int quantity, Map<String, String> characteristics) async {
    final item = Item(
      id: _uuid.v4(),
      name: name,
      quantity: quantity,
      characteristics: characteristics,
    );
    
    await _dbHelper.insertItem(item);
    await loadItems();
  }

  Future<void> updateItem(Item item) async {
    await _dbHelper.updateItem(item);
    await loadItems();
  }

  Future<void> deleteItem(String id) async {
    await _dbHelper.deleteItem(id);
    await loadItems();
  }

  Future<void> importItems(List<Item> items) async {
    for (final item in items) {
      await _dbHelper.insertItem(item);
    }
    await loadItems();
  }

  Future<void> clearAllItems() async {
    // Get all items and delete them one by one
    final allItems = await _dbHelper.getAllItems();
    for (final item in allItems) {
      await _dbHelper.deleteItem(item.id);
    }
    await loadItems();
  }

  void search(String query) {
    _searchQuery = query;
    _applySearch();
    notifyListeners();
  }

  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _filteredItems = List.from(_items);
      return;
    }

    final queryTokens = _searchQuery.toLowerCase().split(' ');
    
    _filteredItems = _items.where((item) {
      final itemName = item.name.toLowerCase();
      final itemId = item.id.toLowerCase();
      
      // Create searchable text from characteristics
      final characteristicsText = item.characteristics.entries
          .map((e) => '${e.key.toLowerCase()} ${e.value.toLowerCase()}')
          .join(' ');
      
      final searchableText = '$itemName $itemId $characteristicsText';
      
      // Check if any token matches
      return queryTokens.any((token) => 
        searchableText.contains(token)
      );
    }).toList();
  }
}