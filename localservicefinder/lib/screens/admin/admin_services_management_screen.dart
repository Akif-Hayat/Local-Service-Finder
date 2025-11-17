import 'package:flutter/material.dart';
import '../../models/service_provider.dart';
import '../../services/admin_service.dart';
import 'admin_add_edit_service_screen.dart';

class AdminServicesManagementScreen extends StatefulWidget {
  const AdminServicesManagementScreen({super.key});

  @override
  State<AdminServicesManagementScreen> createState() => _AdminServicesManagementScreenState();
}

class _AdminServicesManagementScreenState extends State<AdminServicesManagementScreen> {
  List<ServiceProvider> _providers = [];
  List<ServiceProvider> _filteredProviders = [];
  List<ServiceCategory> _categories = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final providers = await AdminService.getAllProviders();
      final categories = await AdminService.getAllCategories();
      setState(() {
        _providers = providers;
        _filteredProviders = providers;
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Future<void> _loadProviders() async {
    try {
      final providers = await AdminService.getAllProviders();
      final categories = await AdminService.getAllCategories();
      setState(() {
        _providers = providers;
        _filteredProviders = providers;
        _categories = categories;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading providers: $e')),
        );
      }
    }
  }

  void _filterProviders() {
    setState(() {
      _filteredProviders = _providers.where((provider) {
        final matchesSearch = _searchQuery.isEmpty ||
            provider.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            provider.category.toLowerCase().contains(_searchQuery.toLowerCase());
        
        final matchesCategory = _selectedCategory == null || 
            provider.category == _selectedCategory;
        
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  Future<void> _deleteProvider(ServiceProvider provider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Provider'),
        content: Text('Are you sure you want to delete "${provider.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await AdminService.deleteProvider(provider.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Provider deleted successfully')),
          );
          _loadProviders();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting provider: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Services'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminAddEditServiceScreen(),
                ),
              );
              if (result == true) {
                _loadProviders();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search providers...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    _searchQuery = value;
                    _filterProviders();
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _CategoryChip(
                        label: 'All',
                        isSelected: _selectedCategory == null,
                        onTap: () {
                          setState(() => _selectedCategory = null);
                          _filterProviders();
                        },
                      ),
                      ..._categories.map((category) => _CategoryChip(
                            label: category.name,
                            isSelected: _selectedCategory == category.name,
                            onTap: () {
                              setState(() => _selectedCategory = category.name);
                              _filterProviders();
                            },
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Providers List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProviders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No providers found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadProviders,
                        child: ListView.builder(
                          itemCount: _filteredProviders.length,
                          itemBuilder: (context, index) {
                            final provider = _filteredProviders[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.purple[100],
                                  child: Text(
                                    provider.name[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.purple,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  provider.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(provider.category),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          size: 16,
                                          color: Colors.amber,
                                        ),
                                        Text(' ${provider.rating.toStringAsFixed(1)}'),
                                        const SizedBox(width: 8),
                                        Icon(
                                          provider.isAvailable
                                              ? Icons.check_circle
                                              : Icons.cancel,
                                          size: 16,
                                          color: provider.isAvailable
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                        Text(
                                          provider.isAvailable
                                              ? ' Available'
                                              : ' Unavailable',
                                          style: TextStyle(
                                            color: provider.isAvailable
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      color: Colors.blue,
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AdminAddEditServiceScreen(
                                              provider: provider,
                                            ),
                                          ),
                                        );
                                        if (result == true) {
                                          _loadProviders();
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      color: Colors.red,
                                      onPressed: () => _deleteProvider(provider),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: Colors.purple[100],
        checkmarkColor: Colors.purple,
      ),
    );
  }
}

