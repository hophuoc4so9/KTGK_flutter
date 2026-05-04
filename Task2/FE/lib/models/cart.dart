import 'package:flutter/foundation.dart';
import 'package:hotuanphuoc_2224802010872_lab5/models/catalog.dart';

class CartModel extends ChangeNotifier {
  
  late CatalogModel _catalog;
  final List<int> _itemIds = [];
  CatalogModel get catalog => _catalog;


  set catalog(CatalogModel newCatalog) {
    
    _catalog = newCatalog;
    notifyListeners();
  }

  List<Item> get items => _itemIds.map((id) => _catalog.getById(id)).toList();
}