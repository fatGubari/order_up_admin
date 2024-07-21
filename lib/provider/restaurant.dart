import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:order_up/models/generate_id.dart';

class Restaurants with ChangeNotifier {
  List<Restaurant> _restaurants = [];

  List<Restaurant> get restaurants {
    return [..._restaurants];
  }

  Future fetchAndSetRestaurants() async {
    const url =
        'https://order-up-e0a41-default-rtdb.firebaseio.com/restaurants.json';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final extractedData =
            json.decode(response.body) as Map<String, dynamic>;
        final List<Restaurant> loadedRestaurants = [];
        if (extractedData != null) {
          extractedData.forEach((restId, restData) {
            loadedRestaurants.add(Restaurant(
              id: restId,
              name: restData['name'],
              location: restData['location'],
              image: restData['image'],
              email: restData['email'],
              password: restData['password'],
              phoneNumber: restData['phoneNumber'],
            ));
          });
        }
        _restaurants = loadedRestaurants;
        notifyListeners();
      } else {
        print('Error fetching data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
      rethrow;
    }
  }

  Future addRestaurant(Restaurant restaurant) async {
    final restaurantId = UserId.getUserId;
    final token = UserId.getAuthToken;

    final url =
        'https://order-up-e0a41-default-rtdb.firebaseio.com/restaurants/$restaurantId.json?auth=$token';
    try {
      await http.put(Uri.parse(url),
          body: json.encode({
            'name': restaurant.name,
            'location': restaurant.location,
            'image': restaurant.image,
            'email': restaurant.email,
            'password': restaurant.password,
            'phoneNumber': restaurant.phoneNumber,
          }));

      final newRestaurant = Restaurant(
        id: restaurantId!,
        name: restaurant.name,
        location: restaurant.location,
        image: restaurant.image,
        email: restaurant.email,
        password: restaurant.password,
        phoneNumber: restaurant.phoneNumber,
      );
      _restaurants.add(newRestaurant);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Restaurant findById(String id) {
    return _restaurants.firstWhere((rest) => rest.id == id);
  }

  Future updateRestaurant(String id, Restaurant newRestaurant) async {
    final token = UserId.getAuthToken;

    final restaurantIndex = restaurants.indexWhere((rest) => rest.id == id);
    if (restaurantIndex >= 0) {
      try {
        final currentRestaurant = restaurants[restaurantIndex];

        // Update email only if it has changed
        if (currentRestaurant.email != newRestaurant.email) {
          await updateEmail(newRestaurant.email);
        }

        // Update password only if it has changed
        if (currentRestaurant.password != newRestaurant.password) {
          await updatePassword(newRestaurant.password);
        }

        final url =
            'https://order-up-e0a41-default-rtdb.firebaseio.com/restaurants/$id.json?auth=$token';

        print(url);

        await http.patch(Uri.parse(url),
            body: json.encode({
              'name': newRestaurant.name,
              'location': newRestaurant.location,
              'image': newRestaurant.image,
              'email': newRestaurant.email,
              'password': newRestaurant.password,
              'phoneNumber': newRestaurant.phoneNumber,
            }));

        _restaurants[restaurantIndex] = newRestaurant;
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

  Future deleteRestaurant(String id) async {
    final token = UserId.getAuthToken;
    final url =
        'https://order-up-e0a41-default-rtdb.firebaseio.com/restaurants/$id.json?auth=$token';
    final existingRestaurantIndex =
        _restaurants.indexWhere((supp) => supp.id == id);
    Restaurant? existingRestaurant = _restaurants[existingRestaurantIndex];
    _restaurants.removeAt(existingRestaurantIndex);
    notifyListeners();
    final response = await http.delete(Uri.parse(url));

    if (response.statusCode >= 400) {
      _restaurants.insert(existingRestaurantIndex, existingRestaurant);
      notifyListeners();
      throw HttpException('Could not delete supplier.');
    }
    existingRestaurant = null;
  }
}

class Restaurant {
  final String id;
  final String name;
  final String location;
  final String image;
  final String email;
  final String password;
  final String phoneNumber;

  Restaurant({
    required this.id,
    required this.name,
    required this.location,
    required this.image,
    required this.email,
    required this.password,
    required this.phoneNumber,
  });
}
