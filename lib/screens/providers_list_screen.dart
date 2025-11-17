import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/service_provider.dart';
import 'provider_detail_screen.dart';

class ProvidersListScreen extends StatelessWidget {
  final String category;

  const ProvidersListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final providers = MockData.getProviders()
        .where((provider) => provider.category == category)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('$category Services'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: providers.isEmpty
          ? const Center(
              child: Text('No providers found for this category'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: providers.length,
              itemBuilder: (context, index) {
                final provider = providers[index];
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
                        Text(provider.description),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
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
    );
  }
}
