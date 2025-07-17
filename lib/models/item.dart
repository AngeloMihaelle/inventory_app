import 'dart:convert';

class Item {
  final String id;
  final String name;
  final int quantity;
  final Map<String, String> characteristics;

  Item({
    required this.id,
    required this.name,
    required this.quantity,
    required this.characteristics,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'characteristics': jsonEncode(characteristics),
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      name: map['name'],
      quantity: map['quantity'],
      characteristics: Map<String, String>.from(
        jsonDecode(map['characteristics'] ?? '{}'),
      ),
    );
  }

  Item copyWith({
    String? id,
    String? name,
    int? quantity,
    Map<String, String>? characteristics,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      characteristics: characteristics ?? this.characteristics,
    );
  }

  String getCharacteristicsSummary() {
    if (characteristics.isEmpty) return '';
    return characteristics.entries
        .map((e) => '${e.key}: ${e.value}')
        .join(', ');
  }
}
