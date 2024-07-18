import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            child:
                Text('Admin Dashboard', style: TextStyle(color: Colors.white)),
          ),
          ListTile(
            title: Text('Dashboard'),
            onTap: () {
              context.go('/');
            },
          ),
          ListTile(
            title: Text('Manage Supplier'),
            onTap: () {
              context.go('/manage-supplier');
            },
          ),
          ListTile(
            title: Text('Manage Restaurant'),
            onTap: () {
              context.go('/manage-restaurant');
            },
          ),
          ListTile(
            title: Text('View Orders'),
            onTap: () {
              context.go('/view-orders');
            },
          ),
          ListTile(
            title: Text('View Products'),
            onTap: () {
              context.go('/view-products');
            },
          ),
        ],
      ),
    );
  }
}
