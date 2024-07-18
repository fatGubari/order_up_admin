import 'package:flutter/material.dart';
import 'package:order_up/pages/dashboard_component/dashboard_card.dart';
import 'package:order_up/provider/order.dart';
import 'package:order_up/provider/product.dart';
import 'package:order_up/provider/restaurant.dart';
import 'package:order_up/provider/supplier.dart';
import 'package:provider/provider.dart';
import '../../widgets/sidebar.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  Future<Map<String, int>> fetchCounts(BuildContext context) async {
    final ordersProvider = Provider.of<Orders>(context, listen: false);
    final productsProvider = Provider.of<Products>(context, listen: false);
    final restaurantsProvider = Provider.of<Restaurants>(context, listen: false);
    final suppliersProvider = Provider.of<Suppliers>(context, listen: false);

    await Future.wait([
      ordersProvider.fetchAndSetOrders(),
      productsProvider.fetchAndSetProducts(),
      restaurantsProvider.fetchAndSetRestaurants(),
      suppliersProvider.fetchAndSetSuppliers(),
    ]);

    return {
      'restaurants': restaurantsProvider.restaurants.length ,
      'products': productsProvider.products.length,
      'soldProducts': ordersProvider.orders.fold(0, (sum, order) => sum + order.products.length),
      'suppliers': suppliersProvider.suppliers.length,
      'orders': ordersProvider.orders.length,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: Sidebar(),
      body: FutureBuilder<Map<String, int>>(
        future: fetchCounts(context),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('An error occurred!'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          } else {
            final data = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount;
                  if (constraints.maxWidth > 1200) {
                    crossAxisCount = 5;
                  } else if (constraints.maxWidth > 800) {
                    crossAxisCount = 3;
                  } else {
                    crossAxisCount = 2;
                  }

                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    children: <Widget>[
                      DashboardCard(
                        title: 'Restaurants',
                        count: data['restaurants']!,
                        icon: Icons.restaurant,
                      ),
                      DashboardCard(
                        title: 'Products',
                        count: data['products']!,
                        icon: Icons.fastfood,
                      ),
                      DashboardCard(
                        title: 'Sold Products',
                        count: data['soldProducts']!,
                        icon: Icons.shopping_cart,
                      ),
                      DashboardCard(
                        title: 'Suppliers',
                        count: data['suppliers']!,
                        icon: Icons.local_shipping,
                      ),
                      DashboardCard(
                        title: 'Orders',
                        count: data['orders']!,
                        icon: Icons.receipt,
                      ),
                    ],
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
