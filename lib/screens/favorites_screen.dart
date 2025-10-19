import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/service_provider.dart';
import '../services/favorites_service.dart';
import 'provider_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<ServiceProvider> _favoriteProviders = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    final allProviders = MockData.getProviders();
    _favoriteProviders = allProviders
        .where((provider) => FavoritesService.isFavorite(provider.id))
        .toList();
    setState(() {});
  }

  void _removeFavorite(String providerId) {
    FavoritesService.removeFavorite(providerId);
    _loadFavorites();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Removed from favorites')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _favoriteProviders.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add providers to your favorites to see them here',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _favoriteProviders.length,
              itemBuilder: (context, index) {
                final provider = _favoriteProviders[index];
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
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'view',
                          child: Text('View Details'),
                        ),
                        const PopupMenuItem(
                          value: 'remove',
                          child: Text('Remove from Favorites'),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'view') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProviderDetailScreen(provider: provider),
                            ),
                          );
                        } else if (value == 'remove') {
                          _removeFavorite(provider.id);
                        }
                      },
                    ),
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
    );
  }
}
