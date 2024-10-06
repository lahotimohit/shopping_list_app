import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/data/categories.dart';

final groceryItems = [
  GroceryList(
      id: 'a',
      name: 'Milk',
      quantity: 1,
      category: categories[Categories.dairy]!),
  GroceryList(
      id: 'b',
      name: 'Bananas',
      quantity: 5,
      category: categories[Categories.fruit]!),
  GroceryList(
      id: 'c',
      name: 'Beef Steak',
      quantity: 1,
      category: categories[Categories.meat]!),
];
