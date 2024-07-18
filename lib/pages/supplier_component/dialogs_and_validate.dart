import 'package:flutter/material.dart';
import 'package:order_up/provider/supplier.dart';
import 'package:provider/provider.dart';

void showDeleteConfirmationDialog(BuildContext context, int supplierId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Confirm Deletion"),
        content: Text("Are you sure you want to block this supplier?"),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Provider.of<Suppliers>(context, listen: false)
                  .deleteSupplier(supplierId.toString());
              Navigator.of(context).pop();
            },
            child: Text(
              "block",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    },
  );
}

bool showIsValidEmail(String email) {
  // Email validation regex
  final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  return emailRegex.hasMatch(email);
}

bool showIsValidPassword(String password) {
  // at least one uppercase letter, one number, one special character
  final RegExp passwordRegex =
      RegExp(r'^(?=.*?[A-Z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
  return passwordRegex.hasMatch(password);
}
