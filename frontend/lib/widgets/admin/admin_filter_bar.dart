import 'package:flutter/material.dart';

class AdminFilterBar extends StatelessWidget {
  final String searchQuery;
  final Function(String) onSearchChanged;
  final List<FilterChipData>? filters;
  final String? selectedFilter;
  final Function(String?)? onFilterChanged;
  final VoidCallback? onClearFilters;
  final Widget? additionalActions;

  const AdminFilterBar({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    this.filters,
    this.selectedFilter,
    this.onFilterChanged,
    this.onClearFilters,
    this.additionalActions,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () => onSearchChanged(''),
                          )
                        : null,
                    filled: true,
                    fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              if (additionalActions != null) ...[
                const SizedBox(width: 12),
                additionalActions!,
              ],
            ],
          ),

          // Filter Chips
          if (filters != null && filters!.isNotEmpty) ...[
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...filters!.map((filter) {
                    final isSelected = selectedFilter == filter.value;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (filter.icon != null) ...[
                              Icon(
                                filter.icon,
                                size: 16,
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey[600],
                              ),
                              const SizedBox(width: 6),
                            ],
                            Text(filter.label),
                            if (filter.count != null) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey[400],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  filter.count.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (onFilterChanged != null) {
                            onFilterChanged!(selected ? filter.value : null);
                          }
                        },
                        backgroundColor: Colors.transparent,
                        selectedColor: Theme.of(
                          context,
                        ).primaryColor.withOpacity(0.1),
                        checkmarkColor: Theme.of(context).primaryColor,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.grey[700],
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.grey.withOpacity(0.3),
                        ),
                      ),
                    );
                  }),
                  if (selectedFilter != null && onClearFilters != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: ActionChip(
                        label: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.clear, size: 14),
                            SizedBox(width: 4),
                            Text('Xóa bộ lọc'),
                          ],
                        ),
                        onPressed: onClearFilters,
                        backgroundColor: Colors.grey[200],
                        labelStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class FilterChipData {
  final String label;
  final String value;
  final IconData? icon;
  final int? count;

  FilterChipData({
    required this.label,
    required this.value,
    this.icon,
    this.count,
  });
}
