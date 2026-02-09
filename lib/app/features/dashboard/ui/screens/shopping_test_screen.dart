import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class ShoppingTestScreen extends StatefulWidget {
  const ShoppingTestScreen({super.key});

  @override
  State<ShoppingTestScreen> createState() => _ShoppingTestScreenState();
}

class _ShoppingTestScreenState extends State<ShoppingTestScreen> {
  final _searchController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _products = [];
  String? _errorMessage;

  Future<void> _searchProducts() async {
    if (_searchController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a search query';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _products = [];
    });

    try {
      const String serpApiKey =
          'b28fa56a220c2684f774b3cc4d576666bacecdb53c4962e24b446231248a954c';

      if (serpApiKey.isEmpty) {
        // Mock Data
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          _products = [
            {
              'title': 'Mock - ${_searchController.text} Option 1',
              'price': '\$49.99',
              'source': 'Trendyol',
              'link': 'https://google.com',
              'thumbnail': 'https://via.placeholder.com/150'
            },
            {
              'title': 'Mock - ${_searchController.text} Option 2',
              'price': '\$79.50',
              'source': 'Zara',
              'link': 'https://google.com',
              'thumbnail': 'https://via.placeholder.com/150'
            },
            {
              'title': 'Mock - ${_searchController.text} Option 3',
              'price': '\$99.99',
              'source': 'H&M',
              'link': 'https://google.com',
              'thumbnail': 'https://via.placeholder.com/150'
            },
          ];
          _isLoading = false;
        });
        return;
      }

      final url = Uri.parse('https://serpapi.com/search.json');
      final response = await http.get(url.replace(queryParameters: {
        'engine': 'google_shopping',
        'q': _searchController.text,
        'api_key': serpApiKey,
        'google_domain': 'google.com.tr',
        'gl': 'tr',
        'hl': 'tr',
        'num': '10',
      }));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final shoppingResults = data['shopping_results'] as List?;

        if (shoppingResults == null || shoppingResults.isEmpty) {
          setState(() {
            _errorMessage = 'No products found';
            _isLoading = false;
          });
          return;
        }

        setState(() {
          _products = shoppingResults.map((item) {
            return {
              'title': item['title'],
              'price': item['price'],
              'source': item['source'],
              'link': item['link'] ??
                  item['product_link'] ??
                  item['serpapi_product_api'], // Try fallbacks
              'thumbnail': item['thumbnail'],
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'API Error: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Shopping Test'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText:
                          'Search for products (e.g., "navy blue blazer")',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _searchProducts(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _searchProducts,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Search'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Error Message
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Products List
            Expanded(
              child: _products.isEmpty
                  ? const Center(
                      child: Text(
                        'Enter a search query and press Search',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final product = _products[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: Image.network(
                              product['thumbnail'] ?? '',
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.image_not_supported),
                            ),
                            title: Text(
                              product['title'] ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '${product['price']} - ${product['source']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.open_in_new),
                              onPressed: () async {
                                log(product.toString() + 'sssss');
                                final url = Uri.parse(product['link'] ?? '');
                                log(url.toString() + 'sssss');
                                debugPrint(url.toString());
                                launch(url.toString());
                              },
                            ),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
