import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryItem extends StatefulWidget {
  const GroceryItem({super.key});

  @override
  State<GroceryItem> createState() => _GroceryItemState();
}

class _GroceryItemState extends State<GroceryItem> {
  List<GroceryList> _groceryItems = [];
  late Future<List<GroceryList>> _loadedItem;

  Future<List<GroceryList>> _loadItem() async {
    final url = Uri.https(
        'shopping-list-flutter-d48be-default-rtdb.firebaseio.com',
        'shopping-list.json');
    final response = await http.get(url);
    if (response.statusCode >= 400) {
      throw Exception("failed to fetch content. Please try again later....");
    }

    if (response.body == "null") {
      return [];
    }

    final Map<String, dynamic> listData = json.decode(response.body);
    final List<GroceryList> _loadedItems = [];
    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere(
              (catItem) => catItem.value.title == item.value['category'])
          .value;
      _loadedItems.add(GroceryList(
          id: item.key,
          name: item.value["name"],
          quantity: item.value['quantity'],
          category: category));
    }
    return _loadedItems;
  }

  @override
  void initState() {
    _loadedItem = _loadItem();
    super.initState();
  }

  void _addItem() async {
    final newItem = await Navigator.of(context)
        .push<GroceryList>(MaterialPageRoute(builder: (ctx) => NewItem()));
    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _deleteItem(GroceryList item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });
    final url = Uri.https(
        'shopping-list-flutter-d48be-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Your Grocieries"),
          actions: [IconButton(onPressed: _addItem, icon: Icon(Icons.add))],
        ),
        body: FutureBuilder(
          future: _loadedItem,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            }

            if (snapshot.data!.isEmpty) {
              return const Center(
                child: Text("No items added yet."),
              );
              ;
            }

            return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (ctx, index) => Dismissible(
                      key: ValueKey(snapshot.data![index].id),
                      onDismissed: (direction) {
                        _deleteItem(snapshot.data![index]);
                      },
                      child: ListTile(
                        title: Text(snapshot.data![index].name),
                        leading: Container(
                          height: 24,
                          width: 24,
                          color: snapshot.data![index].category.color,
                        ),
                        trailing:
                            Text(snapshot.data![index].quantity.toString()),
                      ),
                    ));
          },
        ));
  }
}
