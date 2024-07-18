import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Orders with ChangeNotifier {
  List<Order> _orders = [];

  List<Order> get orders {
    return [..._orders];
  }

  Future fetchAndSetOrders() async {
    const url =
        'https://order-up-e0a41-default-rtdb.firebaseio.com/orders.json';
    final response = await http.get(Uri.parse(url));
    final List<Order> loadedOrders = [];
    final extractedData = jsonDecode(response.body) as Map<String, dynamic>;
    if (extractedData.isEmpty) {
      return;
    }
    for (var restaurantId in extractedData.keys) {
      final restaurantOrders =
          extractedData[restaurantId] as Map<String, dynamic>;
      restaurantOrders.forEach((orderId, orderData) {
        loadedOrders.add(
          Order(
            id: orderId,
            amount: orderData['amount'],
            resturantName: orderData['resturantName'],
            dateTime: DateTime.parse(orderData['dateTime']),
            status: orderData['status'],
            products: (orderData['products'] as List<dynamic>)
                .map(
                  (item) => CartItem(
                    id: item['id'],
                    title: item['title'],
                    supplier: item['supplier'],
                    quantity: item['quantity'],
                    price: item['price'],
                    amountType: item['amountType'],
                    image: item['image'],
                  ),
                )
                .toList(),
          ),
        );
      });
    }

    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }
}

class Order {
  final String id;
  final double amount;
  final String resturantName;
  final List<CartItem> products;
  final DateTime dateTime;
  final String status;

  Order(
      {required this.id,
      required this.amount,
      required this.resturantName,
      required this.products,
      required this.dateTime,
      required this.status});
}

class CartItem {
  final String id;
  final String title;
  final String supplier;
  final int quantity;
  final double price;
  final String amountType;
  final String image;

  CartItem(
      {required this.id,
      required this.title,
      required this.supplier,
      required this.quantity,
      required this.price,
      required this.amountType,
      required this.image});
}
