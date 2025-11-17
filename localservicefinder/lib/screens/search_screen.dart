import 'package:flutter/material.dart';
import '../services/provider_service.dart';
import '../models/service_provider.dart';
import 'provider_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ServiceProvider> _searchResults = [];
  bool _isSearching = false;

  void _searchProviders(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Simulate search delay and fetch from service
    Future.delayed(const Duration(milliseconds: 400), () async {
      final all = await ProviderService.fetchProviders();
      final results = all.where((provider) {
        return provider.name.toLowerCase().contains(query.toLowerCase()) ||
            provider.category.toLowerCase().contains(query.toLowerCase()) ||
            provider.services.any(
              (service) => service.toLowerCase().contains(query.toLowerCase()),
            );
      }).toList();

      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Services'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for services or providers...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _searchProviders('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _searchProviders,
            ),
            const SizedBox(height: 16),
            if (_isSearching)
              const Center(child: CircularProgressIndicator())
            else if (_searchResults.isEmpty && _searchController.text.isNotEmpty)
              const Center(
                child: Text('No results found'),
              )
            else if (_searchResults.isEmpty)
              const Center(
                child: Text('Start typing to search for services'),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final provider = _searchResults[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text(
                            provider.name[0],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          provider.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(provider.category),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                                Text(' ${provider.rating} (${provider.reviewCount} reviews)'),
                                const SizedBox(width: 16),
                                Icon(
                                  provider.isAvailable ? Icons.check_circle : Icons.cancel,
                                  color: provider.isAvailable ? Colors.green : Colors.red,
                                  size: 16,
                                ),
                                Text(
                                  provider.isAvailable ? ' Available' : ' Busy',
                                  style: TextStyle(
                                    color: provider.isAvailable ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProviderDetailScreen(provider: provider),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
