import 'package:flutter/foundation.dart';
import 'package:hotuanphuoc_2224802010872_lab5/models/catalog.dart';

class CartModel extends ChangeNotifier {
  CartModel({required CatalogModel catalog}) : _catalog = catalog;

  CatalogModel _catalog;
  final List<int> _itemIds = [];

  CatalogModel get catalog => _catalog;

  set catalog(CatalogModel newCatalog) {
    _catalog = newCatalog;
    notifyListeners();
  }

  List<Item> get items => _itemIds.map((id) => _catalog.getById(id)).toList();

  int get totalPrice => items.fold(0, (sum, item) => sum + item.price);

  void add(Item item) {
    if (_itemIds.contains(item.id)) {
      return;
    }
    _itemIds.add(item.id);
    notifyListeners();
  }

  bool contains(Item item) => _itemIds.contains(item.id);
}
