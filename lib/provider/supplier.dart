import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:order_up/models/generate_id.dart';

class Suppliers with ChangeNotifier {
  List<Supplier> _suppliers = [];

  List<Supplier> get suppliers {
    return [..._suppliers];
  }

  Future fetchAndSetSuppliers() async {
    const url =
        'https://order-up-e0a41-default-rtdb.firebaseio.com/suppliers.json';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final extractedData =
            json.decode(response.body) as Map<String, dynamic>;
        final List<Supplier> loadedRestaurants = [];
        if (extractedData != null) {
          extractedData.forEach((suppId, suppData) {
            loadedRestaurants.add(Supplier(
              id: suppId,
              name: suppData['name'] ?? '',
              location: suppData['location'] ?? '',
              image: suppData['image'] ?? '',
              email: suppData['email'] ?? '',
              password: suppData['password'] ?? '',
              phoneNumber: suppData['phoneNumber'] ?? '',
              category: suppData['category'] ?? '',
              rate: (suppData['rate'] is String)
                  ? double.parse(suppData['rate'])
                  : suppData['rate'] ?? 0.0,
            ));
          });
        }
        _suppliers = loadedRestaurants;
        notifyListeners();
      } else {
        print('Error fetching data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
      rethrow;
    }
  }

  Future addSupplier(Supplier supplier) async {
    final supplierId = UserId.getUserId;
    final token = UserId.getAuthToken;
    final url =
        'https://order-up-e0a41-default-rtdb.firebaseio.com/suppliers/$supplierId.json?auth=$token';

    try {
      await http.put(Uri.parse(url),
          body: json.encode({
            'name': supplier.name,
            'location': supplier.location,
            'image': supplier.image,
            'email': supplier.email,
            'password': supplier.password,
            'phoneNumber': supplier.phoneNumber,
            'category': supplier.category,
            'rate': supplier.rate,
          }));
      final newSupplier = Supplier(
        id: supplierId!,
        name: supplier.name,
        location: supplier.location,
        image: supplier.image,
        email: supplier.email,
        password: supplier.password,
        phoneNumber: supplier.phoneNumber,
        category: supplier.category,
        rate: supplier.rate,
      );
      _suppliers.add(newSupplier);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Supplier findById(String id) {
    return _suppliers.firstWhere((supp) => supp.id == id);
  }

  Future updateSupplier(String id, Supplier newSupplier) async {
    final token = UserId.getAuthToken;
    final supplierIndex = suppliers.indexWhere((supp) => supp.id == id);
    if (supplierIndex >= 0) {
      try {
        final currentSupplier = suppliers[supplierIndex];

        // Update email only if it has changed
        if (currentSupplier.email != newSupplier.email) {
          await updateEmail(newSupplier.email);
        }
        
        // Update password only if it has changed
        if (currentSupplier.password != newSupplier.password) {
          await updatePassword(newSupplier.password);
        }

        final url = 'https://order-up-e0a41-default-rtdb.firebaseio.com/suppliers/$id.json?auth=$token';

        // Prepare data to update, excluding email and password if they haven't changed
        final updateData = {
          'name': newSupplier.name,
          'location': newSupplier.location,
          'image': newSupplier.image,
          'phoneNumber': newSupplier.phoneNumber,
          'category': newSupplier.category,
          'rate': newSupplier.rate,
        };

        // Include email and password in update data only if they have changed
        if (currentSupplier.email != newSupplier.email) {
          updateData['email'] = newSupplier.email;
        }
        if (currentSupplier.password != newSupplier.password) {
          updateData['password'] = newSupplier.password;
        }

        await http.patch(Uri.parse(url), body: json.encode(updateData));

        _suppliers[supplierIndex] = newSupplier;
        notifyListeners();
      } catch (error) {
        print('Error updating supplier: $error');
        rethrow;
      }
    }
  }
  Future updateEmail(String newEmail) async {
    var token = UserId.getAuthToken;
    const url =
        'https://identitytoolkit.googleapis.com/v1/accounts:update?key=AIzaSyB9iIqUoi9vBasvWiEr14lsrZForm27KqQ';

    if (token == null) {
      throw HttpException('Authentication token not available.');
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode({
          'idToken': token,
          'email': newEmail,
          'returnSecureToken': true,
        }),
      );

      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }

      // Update local token if needed
      token = responseData['idToken']; // Update token if needed
      UserId.setAuthToken(token!); // Update the stored token
      notifyListeners();
    } catch (error) {
      print('Error updating email: $error');
      rethrow;
    }
  }

  Future updatePassword(String newPassword) async {
    var token = UserId.getAuthToken;
    const url =
        'https://identitytoolkit.googleapis.com/v1/accounts:update?key=AIzaSyB9iIqUoi9vBasvWiEr14lsrZForm27KqQ';

    if (token == null) {
      throw HttpException('Authentication token not available.');
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode({
          'idToken': token,
          'password': newPassword,
          'returnSecureToken': true,
        }),
      );

      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }

      // Update local token if needed
      token = responseData['idToken']; // Update token if needed
      UserId.setAuthToken(token!); // Update the stored token
      notifyListeners();
    } catch (error) {
      print('Error updating password: $error');
      rethrow;
    }
  }

  Future deleteSupplier(String id) async {
    final token = UserId.getAuthToken;
    final url =
        'https://order-up-e0a41-default-rtdb.firebaseio.com/suppliers/$id.json?auth=$token';
    final existingSupplierIndex =
        _suppliers.indexWhere((supp) => supp.id == id);
    Supplier? existingSupplier = _suppliers[existingSupplierIndex];
    _suppliers.removeAt(existingSupplierIndex);
    notifyListeners();
    final response = await http.delete(Uri.parse(url));

    if (response.statusCode >= 400) {
      _suppliers.insert(existingSupplierIndex, existingSupplier);
      notifyListeners();
      throw HttpException('Could not delete supplier.');
    }
    existingSupplier = null;
  }
}

class Supplier {
  String id;
  final String name;
  final String location;
  final String image;
  final String email;
  final String password;
  final String phoneNumber;
  final String category;
  final double rate;

  Supplier(
      {required this.id,
      required this.name,
      required this.location,
      required this.image,
      required this.email,
      required this.password,
      required this.phoneNumber,
      required this.category,
      required this.rate});
}
