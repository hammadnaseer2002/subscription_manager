import 'package:flutter/material.dart';

/// Brand logo tile: brand color ke rounded square par logo.
/// Agar logo asset na ho (custom subscription) ya load na ho sake,
/// to naam ka pehla letter dikhata hai.
class BrandLogo extends StatelessWidget {
  final String? logoAsset; // e.g. assets/logos/netflix.png
  final String name;
  final String colorHex; // '#RRGGBB'
  final double size;

  const BrandLogo({
    super.key,
    required this.logoAsset,
    required this.name,
    required this.colorHex,
    this.size = 70,
  });

  @override
  Widget build(BuildContext context) {
    final bg = _parseColor(colorHex);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      clipBehavior: Clip.antiAlias,
      child: logoAsset == null || logoAsset!.isEmpty
          ? _letter(bg)
          : Padding(
              padding: EdgeInsets.all(size * 0.14),
              child: Image.asset(
                logoAsset!,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
                errorBuilder: (_, __, ___) => _letter(bg),
              ),
            ),
    );
  }

  Widget _letter(Color bg) {
    final letter = name.isEmpty ? '?' : name.characters.first.toUpperCase();
    return Center(
      child: Text(
        letter,
        style: TextStyle(
          fontSize: size * 0.45,
          fontWeight: FontWeight.bold,
          color: bg.computeLuminance() > 0.5 ? Colors.black : Colors.white,
        ),
      ),
    );
  }

  static Color _parseColor(String hex) {
    var h = hex.startsWith('#') ? hex.substring(1) : hex;
    if (h.length == 6) h = 'FF$h';
    final v = int.tryParse(h, radix: 16);
    return v == null ? Colors.grey : Color(v);
  }
}
