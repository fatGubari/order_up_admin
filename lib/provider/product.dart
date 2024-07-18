import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  List<Product> _products = [];

  List<Product> get products {
    return [..._products];
  }

  Future fetchAndSetProducts() async {
    const url =
        'https://order-up-e0a41-default-rtdb.firebaseio.com/products.json';
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProduct = [];
      if (extractedData.isEmpty) {
        return;
      }
      extractedData.forEach((prodId, prodData) {
        loadedProduct.add(Product(
          id: prodId,
          title: prodData['title'],
          supplier: prodData['supplier'],
          category: prodData['category'],
          amount: List<String>.from(prodData['amount']),
          description: prodData['description'],
          image: List<String>.from(prodData['image']),
          price: List<String>.from(prodData['price']),
        ));
      });
      _products = loadedProduct;
      // print('loadded data $loadedProduct');
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}

class Product {
  final String id;
  final String title;
  final String supplier;
  final String category;
  final List<String> amount;
  final String description;
  final List<String> image;
  final List<String> price;

  Product({
    required this.id,
    required this.title,
    required this.supplier,
    required this.category,
    required this.amount,
    required this.description,
    required this.image,
    required this.price,
  });
}
