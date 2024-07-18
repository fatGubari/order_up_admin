import 'package:flutter/material.dart';

Widget buildInfoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget buildImageGallery(List<String> images) {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: images.map((imgUrl) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Image.network(
            imgUrl,
            height: 100,
            width: 100,
            fit: BoxFit.cover,
          ),
        );
      }).toList(),
    ),
  );
}
