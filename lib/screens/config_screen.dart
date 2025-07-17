import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../services/csv_service.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({Key? key}) : super(key: key);

  @override
  _ConfigScreenState createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final CSVService _csvService = CSVService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuración'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Data Management Section
            _buildSectionTitle('Gestión de Datos'),
            _buildDataManagementSection(),
            
            SizedBox(height: 32),
            
            // App Settings Section
            _buildSectionTitle('Configuración de la App'),
            _buildAppSettingsSection(),
            
            SizedBox(height: 32),
            
            // About Section
            _buildSectionTitle('Acerca de'),
            _buildAboutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.pink[700],
        ),
      ),
    );
  }

  Widget _buildDataManagementSection() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.file_download, color: Colors.green),
            title: Text('Exportar datos a CSV'),
            subtitle: Text('Guardar todos los elementos en un archivo CSV'),
            trailing: _isLoading 
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.arrow_forward_ios),
            onTap: _isLoading ? null : _exportToCSV,
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.file_upload, color: Colors.orange),
            title: Text('Importar datos desde CSV'),
            subtitle: Text('Cargar elementos desde un archivo CSV'),
            trailing: _isLoading 
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.arrow_forward_ios),
            onTap: _isLoading ? null : _importFromCSV,
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.delete_forever, color: Colors.red),
            title: Text('Limpiar base de datos'),
            subtitle: Text('Eliminar todos los elementos (irreversible)'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: _showClearDatabaseDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettingsSection() {
    return Card(
      child: Column(
        children: [
          Consumer<InventoryProvider>(
            builder: (context, provider, child) {
              return ListTile(
                leading: Icon(Icons.inventory, color: Colors.pink),
                title: Text('Total de elementos'),
                subtitle: Text('${provider.items.length} elementos en inventario'),
                trailing: IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () {
                    provider.loadItems();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Datos actualizados')),
                    );
                  },
                ),
              );
            },
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.format_list_numbered, color: Colors.purple),
            title: Text('Formato de exportación'),
            subtitle: Text('CSV con columnas: ID, Nombre, Cantidad, Características'),
            trailing: Icon(Icons.info_outline),
            onTap: _showExportFormatInfo,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.info, color: Colors.pink),
            title: Text('Versión de la App'),
            subtitle: Text('Inventario Móvil v1.0.0'),
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.help_outline, color: Colors.green),
            title: Text('Ayuda'),
            subtitle: Text('Cómo usar la aplicación'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: _showHelpDialog,
          ),
        ],
      ),
    );
  }

  Future<void> _exportToCSV() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = context.read<InventoryProvider>();
      final success = await _csvService.exportToCSV(provider.getAllItems());
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Datos exportados exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al exportar datos'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _importFromCSV() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = context.read<InventoryProvider>();
      final result = await _csvService.importFromCSV();
      
      if (result.success) {
        await provider.importItems(result.items);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.items.length} elementos importados exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Error al importar datos'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showClearDatabaseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('⚠️ Advertencia'),
        content: Text(
          'Esta acción eliminará TODOS los elementos del inventario de forma permanente. '
          'Esta operación no se puede deshacer.\n\n'
          '¿Está seguro de que desea continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _clearDatabase();
            },
            child: Text('Eliminar Todo', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _clearDatabase() async {
    try {
      final provider = context.read<InventoryProvider>();
      await provider.clearAllItems();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Base de datos limpiada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al limpiar base de datos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showExportFormatInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Formato de Exportación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('El archivo CSV contendrá las siguientes columnas:'),
            SizedBox(height: 12),
            Text('• ID - Identificador único del elemento'),
            Text('• Nombre - Nombre del elemento'),
            Text('• Cantidad - Cantidad en inventario'),
            Text('• Características - Datos adicionales en formato JSON'),
            SizedBox(height: 12),
            Text(
              'Ejemplo de fila CSV:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '"abc123","Cierre","5","{""color"":""rojo"",""tamaño"":""15cm""}"',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ayuda - Inventario Móvil'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Funciones principales:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Agregar elementos: Botón "+" en la pantalla principal'),
              Text('• Editar elementos: Toca cualquier elemento de la lista'),
              Text('• Eliminar elementos: Menú de 3 puntos en cada elemento'),
              Text('• Buscar elementos: Barra de búsqueda en la parte superior'),
              SizedBox(height: 16),
              Text(
                'Características:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Agrega propiedades personalizadas a cada elemento'),
              Text('• Formato clave-valor (ej: color: rojo, tamaño: 15cm)'),
              Text('• La búsqueda incluye las características'),
              SizedBox(height: 16),
              Text(
                'Configuración:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Exportar: Guarda todos los datos en CSV'),
              Text('• Importar: Carga datos desde un archivo CSV'),
              Text('• Limpiar: Elimina todos los elementos'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}