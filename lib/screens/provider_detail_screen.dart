import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/service_provider.dart';
import '../data/mock_data.dart';
import '../services/favorites_service.dart';

class ProviderDetailScreen extends StatefulWidget {
  final ServiceProvider provider;

  const ProviderDetailScreen({super.key, required this.provider});

  @override
  State<ProviderDetailScreen> createState() => _ProviderDetailScreenState();
}

class _ProviderDetailScreenState extends State<ProviderDetailScreen> {
  bool get isFavorite => FavoritesService.isFavorite(widget.provider.id);

  void _toggleFavorite() {
    setState(() {
      FavoritesService.toggleFavorite(widget.provider.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite ? 'Added to favorites' : 'Removed from favorites',
        ),
      ),
    );
  }

  void _callProvider() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: widget.provider.phone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not make phone call')),
      );
    }
  }

  void _emailProvider() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: widget.provider.email,
      query: 'subject=Service Inquiry',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open email client')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.provider.name),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Provider Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.blue,
                          child: Text(
                            widget.provider.name[0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.provider.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.provider.category,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 20),
                                  Text(' ${widget.provider.rating} (${widget.provider.reviewCount} reviews)'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.provider.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          widget.provider.isAvailable ? Icons.check_circle : Icons.cancel,
                          color: widget.provider.isAvailable ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.provider.isAvailable ? 'Available Now' : 'Currently Busy',
                          style: TextStyle(
                            color: widget.provider.isAvailable ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Contact Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _callProvider,
                    icon: const Icon(Icons.phone),
                    label: const Text('Call'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _emailProvider,
                    icon: const Icon(Icons.email),
                    label: const Text('Email'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Services
            const Text(
              'Services Offered',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.provider.services.map((service) {
                return Chip(
                  label: Text(service),
                  backgroundColor: Colors.blue.withOpacity(0.1),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Contact Info
            const Text(
              'Contact Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.phone),
                      title: const Text('Phone'),
                      subtitle: Text(widget.provider.phone),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.email),
                      title: const Text('Email'),
                      subtitle: Text(widget.provider.email),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.location_on),
                      title: const Text('Address'),
                      subtitle: Text(widget.provider.address),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Reviews
            const Text(
              'Reviews',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...MockData.getReviews(widget.provider.id).map((review) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            review.userName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < review.rating ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                                size: 16,
                              );
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(review.comment),
                      const SizedBox(height: 8),
                      Text(
                        '${review.date.day}/${review.date.month}/${review.date.year}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
