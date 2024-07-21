import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:order_up/models/generate_id.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  late String _token;
  DateTime _expiryDate = DateTime.now();
  late String _userId;

  String get authToken {
    return _token;
  }

  Future login(String email, String password) async {
    const url =
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyB9iIqUoi9vBasvWiEr14lsrZForm27KqQ';

    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw Exception(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData['expiresIn']),
        ),
      );

      UserId.setUserId(_userId);
      UserId.setAuthToken(_token);
      notifyListeners();
    } catch (error) {
      print('Login Error: $error');
      rethrow;
    }
  }

  // Future _authenticate(String email, String password, String urlSegment) async {
  //   final customUserId = generateCustomId();
  //   final url =
  //       'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyB9iIqUoi9vBasvWiEr14lsrZForm27KqQ';
  //   try {
  //     final response = await http.post(Uri.parse(url),
  //         body: json.encode({
  //           'email': email,
  //           'password': password,
  //           'returnSecureToken': true
  //         }));
  //     final responseData = json.decode(response.body);
  //     if (responseData['error'] != null) {
  //       throw HttpException(responseData['error']['message']);
  //     }
  //     _token = responseData['idToken'];
  //     _userId = responseData['localId'];
  //     _expiryDate = DateTime.now().add(
  //       Duration(
  //         seconds: int.parse(responseData['expiresIn']),
  //       ),
  //     );
  //     notifyListeners();
  //     final prefs = await SharedPreferences.getInstance();
  //     final userData = json.encode({
  //       'token': _token,
  //       'userId': _userId,
  //       'expiryDate': _expiryDate.toIso8601String(),
  //     });
  //     await prefs.setString('userData', userData);
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  Future signup(String email, String password) async {
    const url =
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyB9iIqUoi9vBasvWiEr14lsrZForm27KqQ';

    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }

      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData['expiresIn']),
        ),
      );

      UserId.setUserId(_userId);
      UserId.setAuthToken(_token);
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String(),
      });
      await prefs.setString('userData', userData);

      // await addSupplier(_userId, email);
    } catch (e) {
      rethrow;
    }
  }

  // Future signup(String email, String password) async {
  //   return _authenticate(email, password, 'signUp');
  // }

  bool get isAuth {
    return _token != null;
  }

  String? get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }
}
