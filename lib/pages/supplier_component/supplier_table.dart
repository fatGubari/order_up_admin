import 'package:flutter/material.dart';
import 'package:order_up/provider/supplier.dart';
import 'package:provider/provider.dart';
import 'add_supplier.dart';

class SupplierTable extends StatelessWidget {
  final String searchText;
  const SupplierTable({super.key, required this.searchText});

  @override
  Widget build(BuildContext context) {
    final suppliersProvider = Provider.of<Suppliers>(context);
    final suppliers = suppliersProvider.suppliers;

    final filteredSuppliers = suppliers.where((supplier) {
      final name = supplier.name.toLowerCase();
      final location = supplier.location.toLowerCase();
      final email = supplier.email.toLowerCase();
      final category = supplier.category.toLowerCase();
      return name.contains(searchText.toLowerCase()) ||
          location.contains(searchText.toLowerCase()) ||
          email.contains(searchText.toLowerCase()) ||
          category.contains(searchText.toLowerCase());
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(
                  label:
                      Text('ID', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('Name',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('Location',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('Photo',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('Email',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('Password',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('Rate',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('Phone Number',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('Category',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('Action',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
              rows: List.generate(
                filteredSuppliers.length,
                (index) => DataRow(
                  cells: [
                    DataCell(Text(filteredSuppliers[index].id.toString())),
                    DataCell(Text(filteredSuppliers[index].name)),
                    DataCell(Text(filteredSuppliers[index].location)),
                    DataCell(
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 3),
                        child: Image.network(
                          filteredSuppliers[index].image,
                          width: 50, // You can adjust the width and height
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    DataCell(Text(filteredSuppliers[index].email)),
                    DataCell(Text(filteredSuppliers[index].password)),
                    DataCell(
                      Row(
                        children: [
                          Text(filteredSuppliers[index].rate.toString()),
                          Icon(Icons.star, color: Colors.yellow),
                        ],
                      ),
                    ),
                    DataCell(Text(filteredSuppliers[index].phoneNumber)),
                    DataCell(Text(filteredSuppliers[index].category)),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddSupplier(
                                    supplier: filteredSuppliers[index],
                                  ),
                                ),
                              ).then((result) {
                                if (result != null) {
                                  final updatedSupplier = Supplier(
                                    id: filteredSuppliers[index].id,
                                    name: result['name'],
                                    location: result['location'],
                                    image: result['image'],
                                    email: result['email'],
                                    password: result['password'],
                                    phoneNumber: result['phone'],
                                    category: result['category'],
                                    rate: result['rate'],
                                  );
                                  suppliersProvider.updateSupplier(
                                      updatedSupplier.id, updatedSupplier);
                                }
                              });
                            },
                          ),
                          SizedBox(width: 8),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                                   showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text('Are you sure?'),
                                content: Text(
                                    'Do you want to block the restaurant from the list?'),
                                actions: [
                                  TextButton(
                                    child: Text('No'),
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: Text('Yes'),
                                    onPressed: () {
                                      suppliersProvider.deleteSupplier(
                                          filteredSuppliers[index].id);
                                      Navigator.of(ctx).pop();
                                    },
                                  ),
                                ],
                              ),
                            );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
