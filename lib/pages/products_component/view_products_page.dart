import 'package:flutter/material.dart';
import 'package:order_up/pages/products_component/product_details_widgets.dart';
import 'package:order_up/provider/product.dart';
import 'package:provider/provider.dart';
import '../../widgets/sidebar.dart';

class ViewProductsPage extends StatefulWidget {
  const ViewProductsPage({super.key});

  @override
  State<ViewProductsPage> createState() => _ViewProductsPageState();
}

class _ViewProductsPageState extends State<ViewProductsPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _filteredProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterProducts);
    _fetchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future _fetchProducts() async {
    await Provider.of<Products>(context, listen: false).fetchAndSetProducts();
    setState(() {
      _filteredProducts =
          Provider.of<Products>(context, listen: false).products;
      _isLoading = false;
    });
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    final productsData = Provider.of<Products>(context, listen: false);

    setState(() {
      _filteredProducts = productsData.products.where((product) {
        return product.title.toLowerCase().contains(query) ||
            product.supplier.toLowerCase().contains(query) ||
            product.category.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Products'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: Sidebar(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search',
                      hintText: 'Search products...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Consumer<Products>(
                    builder: (context, productsData, child) {
                      if (_filteredProducts.isEmpty) {
                        _filteredProducts = productsData.products;
                      }

                      return ListView.builder(
                        itemCount: _filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = _filteredProducts[index];
                          return Card(
                            elevation: 5,
                            margin: EdgeInsets.all(10),
                            child: ExpansionTile(
                              title: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      product.image.isNotEmpty
                                          ? product.image[0]
                                          : 'https://via.placeholder.com/100',
                                    ),
                                    radius: 30,
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      product.title,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      buildInfoRow(
                                          'ID:', product.id.toString()),
                                      buildInfoRow(
                                          'Supplier:', product.supplier),
                                      buildInfoRow(
                                          'Category:', product.category),
                                      buildInfoRow(
                                          'Amount:', product.amount.join(', ')),
                                      buildInfoRow(
                                          'Description:', product.description),
                                      buildInfoRow('Price:',
                                          '${product.price..join(', ')} Rial'),
                                      SizedBox(height: 10),
                                      buildImageGallery(product.image),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
