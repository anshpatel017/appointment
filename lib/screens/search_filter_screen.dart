import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/appointment.dart';
import '../providers/appointment_provider.dart';
import '../utils/constants.dart';
import '../widgets/appointment_card.dart';

class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  final _searchController = TextEditingController();
  String? _filterStatus;
  String? _filterService;
  DateTime? _filterDate;
  List<Appointment> _results = [];
  bool _hasSearched = false;
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    final results = await context.read<AppointmentProvider>().searchAndFilter(
      query: _searchController.text.trim().isNotEmpty ? _searchController.text.trim() : null,
      date: _filterDate != null ? DateFormat('yyyy-MM-dd').format(_filterDate!) : null,
      status: _filterStatus,
      serviceType: _filterService,
    );

    setState(() {
      _results = results;
      _isSearching = false;
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _filterStatus = null;
      _filterService = null;
      _filterDate = null;
      _results = [];
      _hasSearched = false;
    });
  }

  Future<void> _pickFilterDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _filterDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.cardBg,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _filterDate = picked);
      _performSearch();
    }
  }

  bool get _hasActiveFilters =>
      _searchController.text.isNotEmpty || _filterStatus != null || _filterService != null || _filterDate != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search & Filter', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          if (_hasActiveFilters)
            TextButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.clear_all_rounded, size: 18, color: AppColors.cancelled),
              label: const Text('Clear', style: TextStyle(color: AppColors.cancelled, fontSize: 13)),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search by name or appointment ID...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
                  onPressed: _performSearch,
                ),
              ),
              onSubmitted: (_) => _performSearch(),
            ),
          ),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _filterChip(
                  icon: Icons.calendar_today_rounded,
                  label: _filterDate != null ? DateFormat('MMM dd').format(_filterDate!) : 'Date',
                  isActive: _filterDate != null,
                  onTap: _pickFilterDate,
                  onClear: () { setState(() => _filterDate = null); _performSearch(); },
                ),
                const SizedBox(width: 8),
                _filterDropdown(
                  icon: Icons.flag_rounded,
                  label: _filterStatus ?? 'Status',
                  isActive: _filterStatus != null,
                  items: AppointmentStatus.all,
                  onSelected: (val) { setState(() => _filterStatus = val); _performSearch(); },
                  onClear: () { setState(() => _filterStatus = null); _performSearch(); },
                ),
                const SizedBox(width: 8),
                _filterDropdown(
                  icon: Icons.medical_services_rounded,
                  label: _filterService ?? 'Service',
                  isActive: _filterService != null,
                  items: ServiceTypes.all,
                  onSelected: (val) { setState(() => _filterService = val); _performSearch(); },
                  onClear: () { setState(() => _filterService = null); _performSearch(); },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.divider, height: 1),

          // Results
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _results.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _hasSearched ? Icons.search_off_rounded : Icons.search_rounded,
                              color: AppColors.textMuted, size: 48,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _hasSearched ? 'No results found' : 'Search or apply filters\nto find appointments',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 15),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 24),
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          return AppointmentCard(appointment: _results[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip({
    required IconData icon, required String label, required bool isActive,
    required VoidCallback onTap, required VoidCallback onClear,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withAlpha(30) : AppColors.surfaceBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isActive ? AppColors.primary : AppColors.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? AppColors.primary : AppColors.textMuted, size: 16),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: isActive ? AppColors.primary : AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
            if (isActive) ...[
              const SizedBox(width: 4),
              GestureDetector(onTap: onClear, child: const Icon(Icons.close_rounded, color: AppColors.primary, size: 14)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _filterDropdown({
    required IconData icon, required String label, required bool isActive,
    required List<String> items, required ValueChanged<String> onSelected, required VoidCallback onClear,
  }) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      color: AppColors.surfaceBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => items
          .map((item) => PopupMenuItem(value: item, child: Text(item, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14))))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withAlpha(30) : AppColors.surfaceBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isActive ? AppColors.primary : AppColors.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? AppColors.primary : AppColors.textMuted, size: 16),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: isActive ? AppColors.primary : AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(width: 4),
            if (isActive)
              GestureDetector(onTap: onClear, child: const Icon(Icons.close_rounded, color: AppColors.primary, size: 14))
            else
              const Icon(Icons.arrow_drop_down_rounded, color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}
