import 'package:flutter/material.dart';
import 'package:order_up/provider/supplier.dart';
import 'package:provider/provider.dart';
import 'add_supplier.dart';
import 'supplier_table.dart';
import '../../widgets/sidebar.dart';

class ManageSupplierPage extends StatefulWidget {
  const ManageSupplierPage({super.key});

  @override
  State<ManageSupplierPage> createState() => _ManageSupplierPageState();
}

class _ManageSupplierPageState extends State<ManageSupplierPage> {
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<Suppliers>(context, listen: false).fetchAndSetSuppliers());
  }

  @override
  Widget build(BuildContext context) {
    final suppliersProvider = Provider.of<Suppliers>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Supplier'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddSupplier(),
                  ),
                ).then((result) {
                  if (result != null) {
                    final newSupplier = Supplier(
                      id: (suppliersProvider.suppliers.length + 1).toString(),
                      name: result['name'],
                      location: result['location'],
                      image: result['image'],
                      email: result['email'],
                      password: result['password'],
                      phoneNumber: result['phone'],
                      category: result['category'],
                      rate: result['rate'],
                    );
                    suppliersProvider.addSupplier(newSupplier);
                  }
                });
              },
            ),
          ),
        ],
      ),
      drawer: Sidebar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchText = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Search',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Consumer<Suppliers>(
              builder: (ctx, supplierData, _) => SupplierTable(
                searchText: _searchText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
