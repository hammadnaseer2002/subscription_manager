import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/brand_logo.dart';

class PredefinedService {
  final String id;
  final String name;
  final String category;
  final String brandColor;
  final String logoAsset;

  PredefinedService({
    required this.id,
    required this.name,
    required this.category,
    required this.brandColor,
    required this.logoAsset,
  });

  factory PredefinedService.fromJson(Map<String, dynamic> json) {
    return PredefinedService(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      brandColor: json['brandColor'],
      logoAsset: json['logoAsset'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'brandColor': brandColor,
    'logoAsset': logoAsset,
  };
}

class ServicePickerScreen extends StatefulWidget {
  const ServicePickerScreen({super.key});

  // Services ki list ek hi dafa load hoti hai, phir memory mein rehti hai.
  static List<PredefinedService>? _cache;
  static Future<List<PredefinedService>>? _pending;

  /// App start par call karo (main.dart) taake screen khulne se pehle list ready ho.
  static Future<List<PredefinedService>> preload() {
    return _pending ??= () async {
      try {
        final String response = await rootBundle.loadString(
          'assets/services.json',
        );
        final List<dynamic> data = json.decode(response);
        final list = data.map((e) => PredefinedService.fromJson(e)).toList();
        list.sort((a, b) => a.name.compareTo(b.name));
        _cache = list;
        return list;
      } catch (_) {
        _pending = null; // fail hua to agli dafa dobara koshish ho
        rethrow;
      }
    }();
  }

  @override
  State<ServicePickerScreen> createState() => _ServicePickerScreenState();
}

class _ServicePickerScreenState extends State<ServicePickerScreen> {
  List<PredefinedService> _allServices = [];
  List<PredefinedService> _filteredServices = [];
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final cached = ServicePickerScreen._cache;
    if (cached != null) {
      _allServices = cached;
      _filteredServices = _allServices;
      _isLoading = false;
    } else {
      _loadServices();
    }
  }

  Future<void> _loadServices() async {
    final services = await ServicePickerScreen.preload();
    if (!mounted) return;
    setState(() {
      _allServices = services;
      _filteredServices = _allServices;
      _isLoading = false;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filteredServices = _allServices
          .where((s) => s.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  /// Search khali ho to A, B, C... ke headers ke saath rows banata hai,
  /// search chal rahi ho to sirf matching services.
  List<Object> _buildRows() {
    if (_searchQuery.isNotEmpty) {
      return List<Object>.from(_filteredServices);
    }
    final rows = <Object>[];
    String? last;
    for (final s in _filteredServices) {
      final first = s.name.isEmpty ? '#' : s.name.characters.first.toUpperCase();
      final key = RegExp(r'[A-Z]').hasMatch(first) ? first : '#';
      if (key != last) {
        rows.add(key);
        last = key;
      }
      rows.add(s);
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final rows = _buildRows();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Subscription'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search services...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: cs.surfaceContainerHigh,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredServices.isEmpty
          ? const Center(child: Text('No services found'))
          : ListView.builder(
        // Neeche "Add own" button ki jagah chhodni hai
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        itemCount: rows.length,
        itemBuilder: (context, index) {
          final row = rows[index];

          // Alphabet header (Upcoming ke section headers jaisa)
          if (row is String) {
            return Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Text(
                row,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.primary,
                ),
              ),
            );
          }

          final service = row as PredefinedService;
          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 10),
            color: cs.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              leading: BrandLogo(
                logoAsset: service.logoAsset,
                name: service.name,
                colorHex: service.brandColor,
              ),
              title: Text(
                service.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(service.category),
              trailing: Icon(Icons.chevron_right, color: cs.outline),
              onTap: () {
                context.push('/add/custom', extra: service);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add/custom'),
        icon: const Icon(Icons.add),
        label: const Text('Add own'),
      ),
    );
  }
}