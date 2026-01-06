import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:comby/app/features/closet/models/wardrobe_item_model.dart';
import 'package:comby/app/features/closet/models/model_item_model.dart';
import 'package:comby/core/core.dart';

class UserSelectionSheet extends StatefulWidget {
  final String title;
  final Future<List<dynamic>> Function() fetchItems;
  final Function(dynamic item) onSelected; // Changed to pass full item
  final List<Widget>? leadingItems;

  const UserSelectionSheet({
    super.key,
    required this.title,
    required this.fetchItems,
    required this.onSelected,
    this.leadingItems,
  });

  @override
  State<UserSelectionSheet> createState() => _UserSelectionSheetState();
}

class _UserSelectionSheetState extends State<UserSelectionSheet> {
  List<dynamic> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      final items = await widget.fetchItems();
      if (mounted) {
        setState(() {
          _items = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getImageUrl(dynamic item) {
    if (item is WardrobeItem) return item.imageUrl;
    if (item is ModelItem) return item.imageUrl;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 0.7.sh,
      decoration: BoxDecoration(
        color: colorScheme.surface, // Was 0xFF121212
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: colorScheme.onSurface),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty && widget.leadingItems == null
                    ? Center(
                        child: Text(
                          "No items found",
                          style: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.54),
                              fontSize: 12.sp),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.8,
                        ),
                        itemCount:
                            _items.length + (widget.leadingItems?.length ?? 0),
                        itemBuilder: (context, index) {
                          final leadingCount = widget.leadingItems?.length ?? 0;
                          if (index < leadingCount) {
                            return widget.leadingItems![index];
                          }

                          final item = _items[index - leadingCount];
                          final imageUrl = _getImageUrl(item);

                          return GestureDetector(
                            onTap: () {
                              widget.onSelected(item); // Pass full item
                              Navigator.pop(context);
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: colorScheme.surfaceContainer ??
                                      colorScheme.surface.withOpacity(0.5),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: colorScheme.primary),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: colorScheme.surfaceContainer ??
                                      colorScheme.surface.withOpacity(0.5),
                                  child: Icon(Icons.error,
                                      color:
                                          colorScheme.error.withOpacity(0.5)),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
