import 'package:flutter/material.dart';
import 'package:order_up/models/location.dart';
import 'package:order_up/pages/supplier_component/dialogs_and_validate.dart';
import 'package:order_up/pages/supplier_component/location_picker.dart';
import 'package:order_up/provider/auth.dart';
import 'package:order_up/provider/supplier.dart';
import 'package:provider/provider.dart';

class AddSupplier extends StatefulWidget {
  final Supplier? supplier;
  const AddSupplier({super.key, this.supplier});

  @override
  State<AddSupplier> createState() => _AddSupplierState();
}

class _AddSupplierState extends State<AddSupplier> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _imageController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _rateController;
  late TextEditingController _phoneController;
  late TextEditingController _categoryController;
  Location? selectedLocation;

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.supplier?.name ?? '');
    selectedLocation = widget.supplier?.location;
    _imageController =
        TextEditingController(text: widget.supplier?.image ?? '');
    _emailController =
        TextEditingController(text: widget.supplier?.email ?? '');
    _passwordController =
        TextEditingController(text: widget.supplier?.password ?? '');
    _rateController =
        TextEditingController(text: widget.supplier?.rate.toString() ?? '');
    _phoneController =
        TextEditingController(text: widget.supplier?.phoneNumber ?? '');
    _categoryController =
        TextEditingController(text: widget.supplier?.category ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _imageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _rateController.dispose();
    _phoneController.dispose();
    _categoryController.dispose();
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
      final Supplier supplierData;
      if (widget.supplier == null) {
        await Provider.of<Auth>(context, listen: false).signup(
          _emailController.text,
          _passwordController.text,
        );
        supplierData = Supplier(
            id: '',
            name: _nameController.text,
            location: selectedLocation,
            image: _imageController.text,
            email: _emailController.text,
            password: _passwordController.text,
            phoneNumber: _phoneController.text,
            category: _categoryController.text,
            rate: double.parse(_rateController.text));
        await Provider.of<Suppliers>(context, listen: false)
            .addSupplier(supplierData);
      } else {
        supplierData = Supplier(
            id: widget.supplier!.id,
            name: _nameController.text,
            location: selectedLocation,
            image: _imageController.text,
            email: _emailController.text,
            password: _passwordController.text,
            phoneNumber: _phoneController.text,
            category: _categoryController.text,
            rate: double.parse(_rateController.text));
        await Provider.of<Suppliers>(context, listen: false)
            .updateSupplier(widget.supplier!.id, supplierData);
      }

      Navigator.of(context).pop();
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
    final isEditing = widget.supplier != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Update Supplier' : 'Add Supplier'),
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
                    return 'Please enter supplier name';
                  }
                  return null;
                },
              ),
              LocationPicker(
                  setLocation: _setLocation,
                  selectedLocationMap: selectedLocation),
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
                    return 'Please enter supplier email';
                  }
                  if (!showIsValidEmail(value)) {
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
                    return 'Please enter supplier password';
                  }
                  if (!showIsValidPassword(value)) {
                    return 'Password must contain at least one uppercase letter, one number, and one special character';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _rateController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Rate'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter supplier rate';
                  }
                  try {
                    double.parse(value);
                  } catch (e) {
                    return 'Please enter a valid number';
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
                    return 'Please enter supplier phone number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(labelText: 'Category'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter supplier category';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveForm,
                      child:
                          Text(isEditing ? 'Update Supplier' : 'Add Supplier'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void _setLocation(double latitude, double longitude) {
    setState(() {
      selectedLocation = Location(latitude: latitude, longitude: longitude);
    });
  }
}
