import 'package:flutter/material.dart';
import 'package:order_up/pages/restaurant_component/add_restaurant.dart';
import 'package:order_up/pages/restaurant_component/restaurant_table.dart';
import 'package:order_up/provider/restaurant.dart';
import 'package:provider/provider.dart';
import '../../widgets/sidebar.dart';

class ManageRestaurantPage extends StatefulWidget {
  const ManageRestaurantPage({super.key});

  @override
  State<ManageRestaurantPage> createState() => _ManageRestaurantPageState();
}

class _ManageRestaurantPageState extends State<ManageRestaurantPage> {
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<Restaurants>(context, listen: false)
        .fetchAndSetRestaurants());
  }

  @override
  Widget build(BuildContext context) {
    final restaurantsProvider = Provider.of<Restaurants>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Restaurant'),
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
                    builder: (context) => AddRestaurant(),
                  ),
                ).then((result) {
                  if (result != null) {
                    final newRestaurant = Restaurant(
                      id: (restaurantsProvider.restaurants.length + 1)
                          .toString(),
                      name: result['name'],
                      location: result['location'],
                      image: result['image'],
                      email: result['email'],
                      password: result['password'],
                      phoneNumber: result['phone'],
                    );
                    restaurantsProvider.addRestaurant(newRestaurant);
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
            Consumer<Restaurants>(
              builder: (ctx, restaurantData, _) => RestaurantTable(
                searchText: _searchText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
