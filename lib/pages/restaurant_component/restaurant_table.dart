import 'package:flutter/material.dart';
import 'package:order_up/pages/restaurant_component/add_restaurant.dart';
import 'package:order_up/provider/restaurant.dart';
import 'package:provider/provider.dart';

class RestaurantTable extends StatelessWidget {
  final String searchText;
  const RestaurantTable({super.key, required this.searchText});

  @override
  Widget build(BuildContext context) {
    final restaurantsProvider = Provider.of<Restaurants>(context);
    final restaurants = restaurantsProvider.restaurants;

    final filteredRestaurants = restaurants.where((restaurant) {
      final name = restaurant.name.toLowerCase();
      final location = restaurant.location.toLowerCase();
      final email = restaurant.email.toLowerCase();
      return name.contains(searchText.toLowerCase()) ||
          location.contains(searchText.toLowerCase()) ||
          email.contains(searchText.toLowerCase());
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
                    label: Text('ID',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text(
                  'Name',
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
                DataColumn(
                    label: Text('Location',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Photo',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Email',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Password',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Phone Number',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Action',
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: List.generate(
                filteredRestaurants.length,
                (index) => DataRow(
                  cells: [
                    DataCell(Text(filteredRestaurants[index].id.toString())),
                    DataCell(Text(filteredRestaurants[index].name)),
                    DataCell(Text(filteredRestaurants[index].location)),
                    DataCell(
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 3),
                        child: Image.network(
                          filteredRestaurants[index].image,
                          width: 50, // You can adjust the width and height
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (BuildContext context, Object exception,
                              StackTrace? stackTrace) {
                            return Icon(
                              Icons.account_circle,
                              size: 50,
                            );
                          },
                        ),
                      ),
                    ),
                    DataCell(Text(filteredRestaurants[index].email)),
                    DataCell(Text(filteredRestaurants[index].password)),
                    DataCell(Text(filteredRestaurants[index].phoneNumber)),
                    DataCell(Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddRestaurant(
                                  restaurant: filteredRestaurants[index],
                                ),
                              ),
                            ).then((result) {
                              if (result != null) {
                                final updatedRestaurant = Restaurant(
                                  id: filteredRestaurants[index].id,
                                  name: result['name'],
                                  location: result['location'],
                                  image: result['image'],
                                  email: result['email'],
                                  password: result['password'],
                                  phoneNumber: result['phone'],
                                );
                                restaurantsProvider.updateRestaurant(
                                    filteredRestaurants[index].id,
                                    updatedRestaurant);
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
                                      restaurantsProvider.deleteRestaurant(
                                          filteredRestaurants[index].id);
                                      Navigator.of(ctx).pop();
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    )),
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
