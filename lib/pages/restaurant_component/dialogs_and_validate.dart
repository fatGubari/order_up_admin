// import 'package:flutter/material.dart';

// void showConfirmationDialog(
//     BuildContext context, String title, String content, Function onConfirm) {
//   showDialog(
//     context: context,
//     builder: (ctx) => AlertDialog(
//       title: Text(title),
//       content: Text(content),
//       actions: [
//         TextButton(
//           child: Text('No'),
//           onPressed: () {
//             Navigator.of(ctx).pop();
//           },
//         ),
//         TextButton(
//           child: Text('Yes'),
//           onPressed: () {
//             onConfirm();
//             Navigator.of(ctx).pop();
//           },
//         ),
//       ],
//     ),
//   );
// }

bool isValidEmail(String email) {
  // Email validation regex
  final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  return emailRegex.hasMatch(email);
}

bool isValidPassword(String password) {
  // at least one uppercase letter, one number, one special character
  final RegExp passwordRegex =
      RegExp(r'^(?=.*?[A-Z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
  return passwordRegex.hasMatch(password);
}
