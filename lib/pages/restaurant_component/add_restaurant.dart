import 'package:flutter/material.dart';
import 'package:order_up/pages/restaurant_component/dialogs_and_validate.dart';
import 'package:order_up/provider/auth.dart';
import 'package:order_up/provider/restaurant.dart';
import 'package:provider/provider.dart';

class AddRestaurant extends StatefulWidget {
  final Restaurant? restaurant;
  const AddRestaurant({super.key, this.restaurant});

  @override
  State<AddRestaurant> createState() => _AddRestaurantState();
}

class _AddRestaurantState extends State<AddRestaurant> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _imageController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _phoneController;

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.restaurant?.name ?? '');
    _locationController =
        TextEditingController(text: widget.restaurant?.location ?? '');
    _imageController =
        TextEditingController(text: widget.restaurant?.image ?? '');
    _emailController =
        TextEditingController(text: widget.restaurant?.email ?? '');
    _passwordController =
        TextEditingController(text: widget.restaurant?.password ?? '');
    _phoneController =
        TextEditingController(text: widget.restaurant?.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _imageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final Restaurant newRestaurant;
      if (widget.restaurant == null) {
        await Provider.of<Auth>(context, listen: false).signup(
          _emailController.text,
          _passwordController.text,
        );
        newRestaurant = Restaurant(
          id: '', // Firebase will generate the ID
          name: _nameController.text,
          location: _locationController.text,
          image: _imageController.text,
          email: _emailController.text,
          password: _passwordController.text,
          phoneNumber: _phoneController.text,
        );
        // Add the restaurant using the provider method
        await Provider.of<Restaurants>(context, listen: false)
            .addRestaurant(newRestaurant);
      } else {
        newRestaurant = Restaurant(
          id: widget.restaurant!.id, // Firebase will generate the ID
          name: _nameController.text,
          location: _locationController.text,
          image: _imageController.text,
          email: _emailController.text,
          password: _passwordController.text,
          phoneNumber: _phoneController.text,
        );
        await Provider.of<Restaurants>(context, listen: false)
            .updateRestaurant(widget.restaurant!.id, newRestaurant);
      }

      Navigator.of(context)
          .pop(); // Assuming you want to close the current screen after adding
    } catch (error) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An Error Occurred!'),
          content: Text(error.toString()),
          actions: <Widget>[
            TextButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            )
          ],
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.restaurant != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Update Restaurant' : 'Add Restaurant'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter restaurant name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Location'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter restaurant location';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _imageController,
                decoration: InputDecoration(labelText: 'Image URL'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter image URL';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter restaurant email';
                  }
                  if (!isValidEmail(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isPasswordVisible,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter restaurant password';
                  }
                  if (!isValidPassword(value)) {
                    return 'Password must contain at least one uppercase letter, one number, and one special character';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Phone Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter restaurant phone number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveForm,
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                            Theme.of(context).iconTheme.color),
                        foregroundColor: WidgetStatePropertyAll(Colors.black),
                      ),
                      child: Text(
                          isEditing ? 'Update Restaurant' : 'Add Restaurant'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
