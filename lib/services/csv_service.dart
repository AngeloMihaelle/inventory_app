import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import '../models/item.dart';
import 'package:uuid/uuid.dart';

class CSVImportResult {
  final bool success;
  final List<Item> items;
  final String? error;

  CSVImportResult({
    required this.success,
    this.items = const [],
    this.error,
  });
}

class CSVService {
  final Uuid _uuid = Uuid();

  Future<bool> exportToCSV(List<Item> items) async {
    try {
      // Request storage permission
      if (!await _requestStoragePermission()) {
        return false;
      }

      // Create CSV content
      final csvContent = _createCSVContent(items);
      
      // Get Downloads directory
      final directory = await getExternalStorageDirectory();
      if (directory == null) return false;
      
      // Create file path
      final fileName = 'inventario_${DateTime.now().millisecondsSinceEpoch}.csv';
      final filePath = '${directory.path}/$fileName';
      
      // Write file
      final file = File(filePath);
      await file.writeAsString(csvContent, encoding: utf8);
      
      // Try to move to Downloads folder (Android)
      try {
        final downloadsDir = Directory('/storage/emulated/0/Download');
        if (await downloadsDir.exists()) {
          final downloadFile = File('${downloadsDir.path}/$fileName');
          await file.copy(downloadFile.path);
        }
      } catch (e) {
        // If can't access Downloads, file is saved in app directory
        print('Could not save to Downloads: $e');
      }
      
      return true;
    } catch (e) {
      print('Error exporting CSV: $e');
      return false;
    }
  }

  Future<CSVImportResult> importFromCSV() async {
    try {
      // Pick CSV file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result == null || result.files.single.path == null) {
        return CSVImportResult(
          success: false,
          error: 'No se seleccionó ningún archivo',
        );
      }

      final file = File(result.files.single.path!);
      final csvContent = await file.readAsString(encoding: utf8);
      
      // Parse CSV
      final items = _parseCSVContent(csvContent);
      
      return CSVImportResult(
        success: true,
        items: items,
      );
    } catch (e) {
      return CSVImportResult(
        success: false,
        error: 'Error al importar archivo: $e',
      );
    }
  }

  String _createCSVContent(List<Item> items) {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('ID,Nombre,Cantidad,Características');
    
    // Data rows
    for (final item in items) {
      final characteristics = jsonEncode(item.characteristics);
      buffer.writeln(
        '"${item.id}","${_escapeCsvValue(item.name)}","${item.quantity}","${_escapeCsvValue(characteristics)}"'
      );
    }
    
    return buffer.toString();
  }

  List<Item> _parseCSVContent(String csvContent) {
    final items = <Item>[];
    final lines = csvContent.split('\n');
    
    if (lines.isEmpty) return items;
    
    // Skip header line
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      
      try {
        final item = _parseCSVLine(line);
        if (item != null) {
          items.add(item);
        }
      } catch (e) {
        print('Error parsing line $i: $e');
        // Continue with other lines
      }
    }
    
    return items;
  }

  Item? _parseCSVLine(String line) {
    try {
      final values = _parseCSVValues(line);
      if (values.length < 3) return null;
      
      final id = values[0].isNotEmpty ? values[0] : _uuid.v4();
      final name = values[1];
      final quantity = int.tryParse(values[2]) ?? 0;
      
      Map<String, String> characteristics = {};
      if (values.length > 3 && values[3].isNotEmpty) {
        try {
          final decoded = jsonDecode(values[3]);
          if (decoded is Map) {
            characteristics = Map<String, String>.from(decoded);
          }
        } catch (e) {
          // If JSON parsing fails, treat as empty characteristics
          characteristics = {};
        }
      }
      
      return Item(
        id: id,
        name: name,
        quantity: quantity,
        characteristics: characteristics,
      );
    } catch (e) {
      print('Error parsing CSV line: $e');
      return null;
    }
  }

  List<String> _parseCSVValues(String line) {
    final values = <String>[];
    final buffer = StringBuffer();
    bool inQuotes = false;
    
    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      
      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          // Escaped quote
          buffer.write('"');
          i++; // Skip next quote
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        values.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }
    
    values.add(buffer.toString());
    return values;
  }

  String _escapeCsvValue(String value) {
    // Escape quotes by doubling them
    return value.replaceAll('"', '""');
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (status.isGranted) return true;
      
      // Try with manage external storage for Android 11+
      final manageStatus = await Permission.manageExternalStorage.request();
      return manageStatus.isGranted;
    }
    return true; // iOS handles permissions automatically
  }
}