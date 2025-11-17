import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/service_provider.dart';
import '../../services/admin_service.dart';

class AdminAddEditServiceScreen extends StatefulWidget {
  final ServiceProvider? provider;

  const AdminAddEditServiceScreen({super.key, this.provider});

  @override
  State<AdminAddEditServiceScreen> createState() => _AdminAddEditServiceScreenState();
}

class _AdminAddEditServiceScreenState extends State<AdminAddEditServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _servicesController = TextEditingController();

  String? _selectedCategory;
  bool _isAvailable = true;
  bool _isLoading = false;
  bool _isLoadingCategories = true;
  final List<String> _services = [];
  List<ServiceCategory> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    if (widget.provider != null) {
      final p = widget.provider!;
      _nameController.text = p.name;
      _phoneController.text = p.phone;
      _emailController.text = p.email;
      _addressController.text = p.address;
      _descriptionController.text = p.description;
      _imageUrlController.text = p.imageUrl;
      _selectedCategory = p.category;
      _isAvailable = p.isAvailable;
      _services.addAll(p.services);
      _servicesController.text = p.services.join(', ');
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await AdminService.getAllCategories();
      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() => _isLoadingCategories = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading categories: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _servicesController.dispose();
    super.dispose();
  }

  void _parseServices() {
    _services.clear();
    final servicesText = _servicesController.text.trim();
    if (servicesText.isNotEmpty) {
      _services.addAll(
        servicesText.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty),
      );
    }
  }

  Future<void> _saveProvider() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    _parseServices();

    setState(() => _isLoading = true);

    try {
      final provider = ServiceProvider(
        id: widget.provider?.id ?? '',
        name: _nameController.text.trim(),
        category: _selectedCategory!,
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        rating: 0.0, // Rating is auto-calculated from user reviews
        reviewCount: 0, // Review count is auto-calculated from user reviews
        description: _descriptionController.text.trim(),
        services: _services,
        isAvailable: _isAvailable,
        imageUrl: _imageUrlController.text.trim(),
      );

      if (widget.provider == null) {
        await AdminService.addProvider(provider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Provider added successfully')),
          );
          Navigator.pop(context, true);
        }
      } else {
        await AdminService.updateProvider(provider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Provider updated successfully')),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.provider != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Service Provider' : 'Add Service Provider'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: (_isLoading || _isLoadingCategories)
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Provider Name *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.business),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter provider name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category.name,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedCategory = value);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _servicesController,
                      decoration: const InputDecoration(
                        labelText: 'Services (comma-separated)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.build),
                        hintText: 'e.g., Plumbing, Repairs, Installation',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Image URL',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.image),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Available'),
                      subtitle: const Text('Is this provider currently available?'),
                      value: _isAvailable,
                      onChanged: (value) {
                        setState(() => _isAvailable = value);
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveProvider,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isEdit ? 'Update Provider' : 'Add Provider',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

