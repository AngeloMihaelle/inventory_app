import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/inventory_provider.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => InventoryProvider(),
      child: MaterialApp(
        title: 'Inventario Móvil',
        theme: ThemeData(
          primarySwatch: Colors.pink,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: MainScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}