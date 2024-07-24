import 'package:flutter/material.dart';
import 'package:order_up/pages/orders_component/order_details_widgets.dart';
import 'package:order_up/provider/order.dart';
import 'package:provider/provider.dart';
import '../../widgets/sidebar.dart';

class ViewOrdersPage extends StatefulWidget {
  const ViewOrdersPage({super.key});

  @override
  State<ViewOrdersPage> createState() => _ViewOrdersPageState();
}

class _ViewOrdersPageState extends State<ViewOrdersPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Order> _filteredOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterOrders);
    _fetchOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    await Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
    setState(() {
      _filteredOrders = Provider.of<Orders>(context, listen: false).orders;
      _isLoading = false;
    });
  }

  void _filterOrders() {
    final query = _searchController.text.toLowerCase();
    final ordersData = Provider.of<Orders>(context, listen: false);

    setState(() {
      _filteredOrders = ordersData.orders.where((order) {
        return order.resturantName.toLowerCase().contains(query) ||
            order.status.toLowerCase().contains(query) ||
            order.products.any((product) =>
                product.title.toLowerCase().contains(query) ||
                product.supplier.toLowerCase().contains(query));
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Orders'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: Sidebar(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search',
                      hintText: 'Search orders...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = _filteredOrders[index];
                      return Card(
                        elevation: 5,
                        margin: EdgeInsets.all(10),
                        child: ExpansionTile(
                          title: Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Theme.of(context).iconTheme.color,
                                child: Text(order.resturantName[0]),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  order.dateTime.toLocal().toString(),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  buildInfoRow('ID:', order.id),
                                  buildInfoRow('Restaurant Name:', order.resturantName),
                                  buildInfoRow('Status:', order.status),
                                  buildInfoRow('Date:', order.dateTime.toLocal().toString()),
                                  buildInfoRow('Amount:', order.amount.toString()),
                                  SizedBox(height: 10),
                                  Text(
                                    'Products:',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: order.products.length,
                                    itemBuilder: (ctx, i) {
                                      final product = order.products[i];
                                      return Card(
                                        elevation: 5,
                                        margin: EdgeInsets.symmetric(vertical: 5),
                                        child: ListTile(
                                          title: Text(product.title),
                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Supplier: ${product.supplier}'),
                                              Text('Quantity: ${product.quantity}'),
                                              Text('Price: \$${product.price}'),
                                              Text('Amount Type: ${product.amountType}'),
                                            ],
                                          ),
                                          leading: Image.network(product.image, width: 50, height: 50, fit: BoxFit.cover),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }


}
