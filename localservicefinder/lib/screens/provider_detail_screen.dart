import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/service_provider.dart';
import '../services/provider_service.dart';
import '../services/favorites_service.dart';
import '../services/auth_service.dart';
import 'add_review_screen.dart';

class ProviderDetailScreen extends StatefulWidget {
  final ServiceProvider provider;

  const ProviderDetailScreen({super.key, required this.provider});

  @override
  State<ProviderDetailScreen> createState() => _ProviderDetailScreenState();
}

class _ProviderDetailScreenState extends State<ProviderDetailScreen> {
  late ServiceProvider _currentProvider;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _currentProvider = widget.provider;
  }

  Future<void> _refreshProvider() async {
    setState(() => _isRefreshing = true);
    try {
      final providers = await ProviderService.fetchProviders();
      final updatedProvider = providers.firstWhere(
        (p) => p.id == widget.provider.id,
        orElse: () => _currentProvider,
      );
      setState(() {
        _currentProvider = updatedProvider;
        _isRefreshing = false;
      });
    } catch (e) {
      setState(() => _isRefreshing = false);
    }
  }

  bool get isFavorite => FavoritesService.isFavorite(_currentProvider.id);

  void _toggleFavorite() {
    setState(() {
      FavoritesService.toggleFavorite(_currentProvider.id);
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
    final Uri phoneUri = Uri(scheme: 'tel', path: _currentProvider.phone);
    
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        // Fallback: copy phone number to clipboard and show message
        await Clipboard.setData(ClipboardData(text: _currentProvider.phone));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Phone number copied to clipboard: ${widget.provider.phone}'),
              action: SnackBarAction(
                label: 'Copy Again',
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: _currentProvider.phone));
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Copy to clipboard as fallback
      await Clipboard.setData(ClipboardData(text: widget.provider.phone));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Phone number copied to clipboard: ${widget.provider.phone}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _emailProvider() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: _currentProvider.email,
      query: 'subject=Service Inquiry',
    );
    
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        // Fallback: copy email to clipboard
        await Clipboard.setData(ClipboardData(text: _currentProvider.email));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Email copied to clipboard: ${widget.provider.email}'),
              action: SnackBarAction(
                label: 'Copy Again',
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: _currentProvider.email));
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Copy to clipboard as fallback
      await Clipboard.setData(ClipboardData(text: widget.provider.email));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email copied to clipboard: ${widget.provider.email}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentProvider.name),
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
                            _currentProvider.name[0],
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
                                _currentProvider.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _currentProvider.category,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 20),
                                  Text(' ${_currentProvider.rating.toStringAsFixed(1)} (${_currentProvider.reviewCount} reviews)'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _currentProvider.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          _currentProvider.isAvailable ? Icons.check_circle : Icons.cancel,
                          color: _currentProvider.isAvailable ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _currentProvider.isAvailable ? 'Available Now' : 'Currently Busy',
                          style: TextStyle(
                            color: _currentProvider.isAvailable ? Colors.green : Colors.red,
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
              children: _currentProvider.services.map((service) {
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
                      subtitle: Text(_currentProvider.phone),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.email),
                      title: const Text('Email'),
                      subtitle: Text(_currentProvider.email),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.location_on),
                      title: const Text('Address'),
                      subtitle: Text(_currentProvider.address),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Reviews Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Reviews',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (AuthService.isLoggedIn)
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddReviewScreen(
                            provider: _currentProvider,
                          ),
                        ),
                      );
                      if (result == true && mounted) {
                        // Refresh provider data to get updated rating and review count
                        await _refreshProvider();
                        setState(() {});
                      }
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Write Review'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<Review>>(
              future: ProviderService.fetchReviews(_currentProvider.id),
              key: ValueKey('${_currentProvider.id}_$_isRefreshing'), // Refresh when provider changes
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: LinearProgressIndicator(),
                  );
                }
                
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error loading reviews: ${snapshot.error}'),
                      ],
                    ),
                  );
                }
                
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final reviews = snapshot.data!;
                return _buildReviewsList(reviews);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsList(List<Review> reviews) {
    if (reviews.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No reviews yet',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      );
    }

    return Column(
      children: reviews.map((review) {
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
    );
  }
}
