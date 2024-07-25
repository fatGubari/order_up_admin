import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:order_up/pages/dashboard_component/dashboard_page.dart';
import 'package:order_up/pages/login_componenet/login_page.dart';
import 'package:order_up/pages/orders_component/view_orders_page.dart';
import 'package:order_up/pages/products_component/view_products_page.dart';
import 'package:order_up/pages/restaurant_component/manage_restaurant_page.dart';
import 'package:order_up/pages/supplier_component/manage_supplier_page.dart';
import 'package:order_up/provider/auth.dart';
import 'package:order_up/provider/order.dart';
import 'package:order_up/provider/product.dart';
import 'package:order_up/provider/restaurant.dart';
import 'package:order_up/provider/supplier.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Suppliers()),
        ChangeNotifierProvider(create: (_) => Restaurants()),
        ChangeNotifierProvider(create: (_) => Products()),
        ChangeNotifierProvider(create: (_) => Orders()),
        ChangeNotifierProvider(create: (_) => Auth()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => DashboardPage()),
        GoRoute(path: '/login', builder: (context, state) => LoginPage()),
        GoRoute(
            path: '/manage-supplier',
            builder: (context, state) => ManageSupplierPage()),
        GoRoute(
            path: '/manage-restaurant',
            builder: (context, state) => ManageRestaurantPage()),
        GoRoute(
            path: '/view-orders',
            builder: (context, state) => ViewOrdersPage()),
        GoRoute(
            path: '/view-products',
            builder: (context, state) => ViewProductsPage()),
      ],
      initialLocation: '/login',
    );

    return MaterialApp.router(
      title: 'Admin Dashboard',
      debugShowCheckedModeBanner: false,
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(0, 17, 161, 177)),
        iconTheme:
            IconThemeData(color: const Color.fromARGB(255, 236, 198, 73)),
      ),
    );
  }
}
