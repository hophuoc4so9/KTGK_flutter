import 'package:flutter/material.dart';


class CatalogModel {
  List <String> items = [
    'Apple',
    'Banana',
    'Orange',
    'Grapes',
    'Mango',
    'Pineapple',
    'Strawberry',
    'Watermelon',
    'Peach',
    'Cherry',
    'Blueberry',
    'Kiwi',

    
  ];
  Item getById(int id) => Item(id, items[id%items.length]);

  Item getByPosition(int position) => getById(position);

}

@immutable
class Item {
  final int id;
  final String name;
  final Color color;
  final int price = 42;

  Item(this.id, this.name) : color = Colors.primaries[id % Colors.primaries.length];
  @override
  int get hashCode => id;
  @override
  bool operator ==(Object other) => other is Item && other.id == id;

}