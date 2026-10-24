import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/subscription.dart';
import '../../data/repositories/subscription_repository.dart';

enum _GroupBy { categories, subscriptions }

/// Ek hissa: ek category (ya ek subscription) aur uska mahine ka kharcha.
class _Group {
  final String name;
  Color color;
  double total = 0;
  final List<_Share> items = [];

  _Group(this.name, this.color);
}

class _Share {
  final String name;
  final double amount;
  const _Share(this.name, this.amount);
}

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  late final Stream<List<Subscription>> _stream;
  late final Future<Map<String, String>> _categoryMapFuture;

  _GroupBy _groupBy = _GroupBy.categories;

  // Jis currency ka analytics dikh raha hai (alag currencies kabhi jama nahi hotin)
  String? _currency;
  String _shownCurrency = 'USD';

  static const List<Color> _palette = [
    Color.fromARGB(255, 139, 141, 245), // yellow
    Color(0xFFE57373), // salmon
    Color(0xFFFFCCA8), // peach
    Color(0xFF9CCC3C), // olive green
    Color(0xFFF5A623), // orange
    Color(0xFF64B5F6), // blue
    Color(0xFFBA68C8), // purple
    Color(0xFF4DB6AC), // teal
    Color(0xFFF06292), // pink
    Color(0xFFA1887F), // brown
  ];

  static const List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  // services.json se serviceId -> category ka naam (ek dafa load, phir cache)
  static Map<String, String>? _categoryCache;

  static Future<Map<String, String>> _loadCategoryMap() async {
    if (_categoryCache != null) return _categoryCache!;
    try {
      final raw = await rootBundle.loadString('assets/services.json');
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      return _categoryCache = {
        for (final e in list) e['id'] as String: e['category'] as String,
      };
    } catch (_) {
      return {};
    }
  }

  @override
  void initState() {
    super.initState();
    _stream = ref.read(subscriptionRepositoryProvider).watchAllActive();
    _categoryMapFuture = _loadCategoryMap();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: FutureBuilder<Map<String, String>>(
        future: _categoryMapFuture,
        builder: (context, mapSnap) {
          if (mapSnap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final categoryMap = mapSnap.data ?? const <String, String>{};

          return StreamBuilder<List<Subscription>>(
            stream: _stream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final allSubscriptions = snapshot.data!;
              if (allSubscriptions.isEmpty) {
                return const _AnalyticsEmptyState();
              }

              // Currencies: jis ki zyada subscriptions hon wo pehle
              final counts = <String, int>{};
              for (final s in allSubscriptions) {
                counts[s.currency] = (counts[s.currency] ?? 0) + 1;
              }
              final currencies = counts.keys.toList()
                ..sort((a, b) => counts[b]!.compareTo(counts[a]!));
              final selected =
              (_currency != null && counts.containsKey(_currency))
                  ? _currency!
                  : currencies.first;
              _shownCurrency = selected;

              // 15 USD aur 2000 PKR ko jama karna galat hai, is liye ek waqt
              // mein sirf ek currency ki subscriptions
              final subscriptions = allSubscriptions
                  .where((s) => s.currency == selected)
                  .toList();

              final groups = _buildGroups(subscriptions, categoryMap);
              final total = groups.fold<double>(0, (s, g) => s + g.total);
              if (total <= 0) {
                // Subscriptions hain lekin sab free (price 0) hain
                final cs = Theme.of(context).colorScheme;
                return ListView(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    16 + MediaQuery.paddingOf(context).bottom,
                  ),
                  children: [
                    if (currencies.length > 1) ...[
                      _buildCurrencySelector(context, currencies, selected),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 64),
                    Icon(Icons.savings_outlined, size: 64, color: cs.outline),
                    const SizedBox(height: 16),
                    Text(
                      'Nothing to analyse yet',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your $selected subscriptions are free, so there is no spending to show.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                );
              }

              return ListView(
                // Neeche floating tab bar ki jagah chhodni hai taake aakhri content na chhupe
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  16 + MediaQuery.paddingOf(context).bottom,
                ),
                children: [
                  if (currencies.length > 1) ...[
                    _buildCurrencySelector(context, currencies, selected),
                    const SizedBox(height: 12),
                  ],
                  _buildHeaderCard(context, total, subscriptions.length),
                  const SizedBox(height: 16),
                  _buildStatisticsCard(context, groups, total),
                  const SizedBox(height: 24),
                  Text(
                    _groupBy == _GroupBy.categories
                        ? 'Category details'
                        : 'Subscription details',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _buildDetails(context, groups, total),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Logic
  // -------------------------------------------------------------------------

  /// Har subscription ka mahine ke hisab se kharcha.
  double _monthlyCost(Subscription sub) {
    final count = sub.cycleCount <= 0 ? 1 : sub.cycleCount;
    switch (sub.cycleUnit) {
      case CycleUnit.day:
        return (sub.price / count) * 30;
      case CycleUnit.week:
        return (sub.price / count) * 4.33;
      case CycleUnit.month:
        return sub.price / count;
      case CycleUnit.year:
        return sub.price / (12 * count);
    }
  }

  /// Subscriptions ko category (ya naam) ke hisab se group karta hai, bade se chhota.
  List<_Group> _buildGroups(
      List<Subscription> subscriptions,
      Map<String, String> categoryMap,
      ) {
    final Map<String, _Group> byKey = {};

    for (final sub in subscriptions) {
      final String key;
      if (_groupBy == _GroupBy.categories) {
        key = sub.categoryId ?? categoryMap[sub.serviceId] ?? 'Other';
      } else {
        key = sub.name;
      }
      final cost = _monthlyCost(sub);
      final group = byKey.putIfAbsent(key, () => _Group(key, Colors.grey));
      group.total += cost;
      group.items.add(_Share(sub.name, cost));
    }

    final sorted = byKey.values.toList()
      ..sort((a, b) => b.total.compareTo(a.total));

    for (int i = 0; i < sorted.length; i++) {
      sorted[i].color = _colorFor(i);
      sorted[i].items.sort((a, b) => b.amount.compareTo(a.amount));
    }
    return sorted;
  }

  Color _colorFor(int i) {
    if (i < _palette.length) return _palette[i];
    return HSLColor.fromAHSL(
      1,
      ((i * 47) % 360).toDouble(),
      0.6,
      0.65,
    ).toColor();
  }

  /// Ring ke end par dikhne wala icon.
  IconData _iconFor(String name) {
    if (_groupBy == _GroupBy.subscriptions) return Icons.autorenew_rounded;
    switch (name) {
      case 'Video & TV':
        return Icons.tv_rounded;
      case 'Music':
        return Icons.music_note_rounded;
      case 'Gaming':
        return Icons.sports_esports_rounded;
      case 'Cloud Storage':
        return Icons.cloud_rounded;
      case 'VPN & Security':
        return Icons.shield_rounded;
      case 'Antivirus':
        return Icons.security_rounded;
      case 'Password Managers':
        return Icons.key_rounded;
      case 'Productivity':
        return Icons.check_circle_rounded;
      case 'Developer & Hosting':
        return Icons.code_rounded;
      case 'Internet':
        return Icons.wifi_rounded;
      case 'Mobile & Telecom':
        return Icons.phone_android_rounded;
      case 'Finance':
        return Icons.account_balance_rounded;
      case 'Health & Fitness':
        return Icons.fitness_center_rounded;
      case 'Wellness':
        return Icons.spa_rounded;
      case 'Education':
        return Icons.school_rounded;
      case 'Books & Comics':
        return Icons.menu_book_rounded;
      case 'News & Magazines':
        return Icons.newspaper_rounded;
      case 'Communication':
        return Icons.chat_rounded;
      case 'Food & Delivery':
        return Icons.restaurant_rounded;
      case 'Transport':
        return Icons.directions_car_rounded;
      case 'Shopping':
        return Icons.shopping_bag_rounded;
      case 'Insurance':
        return Icons.verified_user_rounded;
      case 'Smart Home':
        return Icons.home_rounded;
      case 'Domains':
        return Icons.language_rounded;
      case 'AI':
        return Icons.auto_awesome_rounded;
      case 'Donations':
        return Icons.favorite_rounded;
      case 'Utilities':
        return Icons.bolt_rounded;
      case 'Shipping':
        return Icons.local_shipping_rounded;
      case 'Career':
        return Icons.work_rounded;
      case 'Others':
        return Icons.more_horiz_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  String _money(double v) {
    final s = v.toStringAsFixed(v >= 1000 ? 0 : 2);
    final withCommas = s.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (m) => ',',
    );
    return '${_symbolFor(_shownCurrency)}$withCommas';
  }

  String _symbolFor(String code) {
    switch (code) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'INR':
        return '₹';
      case 'JPY':
        return '¥';
      case 'PKR':
        return 'Rs ';
      default:
        return '$code ';
    }
  }

  /// Upar ki chips: kaun si currency ka analytics dekhna hai.
  Widget _buildCurrencySelector(
      BuildContext context,
      List<String> currencies,
      String selected,
      ) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final c in currencies)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(c),
                selected: c == selected,
                onSelected: (_) => setState(() => _currency = c),
              ),
            ),
        ],
      ),
    );
  }

  String _today() {
    final n = DateTime.now();
    final day = n.day.toString().padLeft(2, '0');
    return '$day ${_months[n.month - 1]} ${n.year}';
  }

  // -------------------------------------------------------------------------
  // UI
  // -------------------------------------------------------------------------

  Widget _buildHeaderCard(BuildContext context, double total, int count) {
    final scheme = Theme.of(context).colorScheme;
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: scheme.primary.withOpacity(0.15),
            child: Icon(Icons.insights_rounded, color: scheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _money(total),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _today(),
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Text(
            '$count active',
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard(
      BuildContext context,
      List<_Group> groups,
      double total,
      ) {
    final scheme = Theme.of(context).colorScheme;

    // Rings: top 3 category, baqi sab "Others" ki ek ring mein.
    final List<_Group> ringGroups;
    if (groups.length <= 4) {
      ringGroups = groups;
    } else {
      final others = _Group('Others', const Color(0xFF9E9E9E));
      for (final g in groups.skip(3)) {
        others.total += g.total;
      }
      ringGroups = [...groups.take(3), others];
    }

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monthly statistics',
                style: TextStyle(
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              PopupMenuButton<_GroupBy>(
                initialValue: _groupBy,
                onSelected: (v) => setState(() => _groupBy = v),
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: _GroupBy.categories,
                    child: Text('Categories'),
                  ),
                  PopupMenuItem(
                    value: _GroupBy.subscriptions,
                    child: Text('Subscriptions'),
                  ),
                ],
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _groupBy == _GroupBy.categories
                          ? 'Categories'
                          : 'Subscriptions',
                      style: TextStyle(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, color: scheme.primary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final g in ringGroups) ...[
                      _LegendRow(
                        color: g.color,
                        name: g.name,
                        amount: _money(g.total),
                        percent:
                        '${(g.total / total * 100).toStringAsFixed(0)}%',
                      ),
                      const SizedBox(height: 12),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.onSurface.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Yearly ≈ ${_money(total * 12)}',
                        style: TextStyle(fontSize: 13, color: scheme.onSurface),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _ActivityRings(
                size: 180,
                rings: [
                  for (final g in ringGroups)
                    _RingData(
                      progress: g.total / total,
                      color: g.color,
                      icon: _iconFor(g.name),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Har category ki detail: kitni subscriptions, percent, total, aur andar ki list.
  Widget _buildDetails(
      BuildContext context,
      List<_Group> groups,
      double total,
      ) {
    final scheme = Theme.of(context).colorScheme;
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Column(
        children: [
          for (final g in groups)
            GlassCard(
              margin: const EdgeInsets.only(bottom: 8),
              radius: 16,
              shadow: false, // chhote tiles par shadow zyada bhari lagti hai
              child: ExpansionTile(
                shape: const Border(),
                collapsedShape: const Border(),
                leading: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: g.color,
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(
                  g.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '${g.items.length} subscription${g.items.length == 1 ? '' : 's'}'
                      ' • ${(g.total / total * 100).toStringAsFixed(0)}%',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
                trailing: Text(
                  _money(g.total),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                children: [
                  for (final s in g.items)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(56, 4, 16, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              s.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            _money(s.amount),
                            style: TextStyle(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Glass card: tab bar jaisa blur + transparent gradient + upar ki gloss + border
// ---------------------------------------------------------------------------

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final bool shadow;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.margin,
    this.radius = 20,
    this.shadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final br = BorderRadius.circular(radius);

    // BackdropFilter (blur) hata diya: har card par blur layer scroll par flicker karti thi.
    // Safed ki jagah card ka apna surface color, taake grey/safed na lage
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    final glassTop = base.withValues(alpha: isDark ? 0.55 : 0.70);
    final glassBottom = base.withValues(alpha: isDark ? 0.30 : 0.40);
    final borderColor = Colors.white.withValues(alpha: isDark ? 0.12 : 0.55);
    final glossTop = Colors.white.withValues(alpha: isDark ? 0.06 : 0.25);

    return Container(
      margin: margin,
      // Shadow clip ke bahar rakhi hai taake kate nahi
      decoration: BoxDecoration(
        borderRadius: br,
        boxShadow: shadow
            ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.10),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: br,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: br,
            border: Border.all(color: borderColor, width: 1),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [glassTop, glassBottom],
            ),
          ),
          child: Stack(
            children: [
              // Upar ki chamak (gloss)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 30,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [glossTop, Colors.white.withValues(alpha: 0)],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(padding: padding, child: child),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Legend row: rang ki patti, naam, aur "$amount / percent"
// ---------------------------------------------------------------------------

class _LegendRow extends StatelessWidget {
  final Color color;
  final String name;
  final String amount;
  final String percent;

  const _LegendRow({
    required this.color,
    required this.name,
    required this.amount,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 4,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$amount ',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
                      TextSpan(
                        text: '/ $percent',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Concentric rings
// ---------------------------------------------------------------------------

class _RingData {
  final double progress; // 0..1
  final Color color;
  final IconData icon;

  const _RingData({
    required this.progress,
    required this.color,
    required this.icon,
  });
}

class _ActivityRings extends StatelessWidget {
  final List<_RingData> rings;
  final double size;

  static const double _stroke = 15;
  static const double _gap = 5;

  const _ActivityRings({required this.rings, required this.size});

  double _radius(int i) => size / 2 - _stroke / 2 - i * (_stroke + _gap);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, t, _) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            children: [
              CustomPaint(
                size: Size(size, size),
                painter: _RingsPainter(
                  rings: rings,
                  t: t,
                  stroke: _stroke,
                  radiusOf: _radius,
                ),
              ),
              for (int i = 0; i < rings.length; i++) _marker(i, t),
            ],
          ),
        );
      },
    );
  }

  /// Ring ke end par chhota gol icon.
  Widget _marker(int i, double t) {
    final ring = rings[i];
    final p = ring.progress.clamp(0.0, 1.0) * t;
    final angle = -math.pi / 2 + 2 * math.pi * p;
    final r = _radius(i);
    final cx = size / 2 + r * math.cos(angle);
    final cy = size / 2 + r * math.sin(angle);
    final iconColor =
    ring.color.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;
    return Positioned(
      left: cx - _stroke / 2,
      top: cy - _stroke / 2,
      child: Container(
        width: _stroke,
        height: _stroke,
        decoration: BoxDecoration(color: ring.color, shape: BoxShape.circle),
        child: Icon(ring.icon, size: 8, color: iconColor),
      ),
    );
  }
}

class _RingsPainter extends CustomPainter {
  final List<_RingData> rings;
  final double t;
  final double stroke;
  final double Function(int) radiusOf;

  _RingsPainter({
    required this.rings,
    required this.t,
    required this.stroke,
    required this.radiusOf,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < rings.length; i++) {
      final ring = rings[i];
      final r = radiusOf(i);

      final track = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = ring.color.withOpacity(0.25);
      canvas.drawCircle(center, r, track);

      final p = ring.progress.clamp(0.0, 1.0) * t;
      if (p <= 0) continue;

      final arc = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = ring.color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r),
        -math.pi / 2,
        2 * math.pi * p,
        false,
        arc,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingsPainter old) =>
      old.t != t || old.rings != rings;
}

/// Jab analytics dikhane ke liye koi data na ho.
class _AnalyticsEmptyState extends StatelessWidget {
  const _AnalyticsEmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Center(
      child: Padding(
        // Neeche tab bar ki jagah chhodte hain taake content theek beech mein lage
        padding: EdgeInsets.fromLTRB(
          32,
          0,
          32,
          MediaQuery.paddingOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: cs.primaryContainer.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.pie_chart_rounded,
                size: 56,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No analytics yet',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a subscription to see how much you spend every month, by category or by subscription.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.tonalIcon(
              onPressed: () => context.push('/add'),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add subscription'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}