import 'package:flutter/material.dart';

import '../models/product.dart';

/// Product pack shot on a white rounded tile; falls back to the first letter if the asset is missing.
class ProductImage extends StatelessWidget {
  final Product product;
  final double size;
  final double radius;
  const ProductImage({
    super.key,
    required this.product,
    this.size = 56,
    this.radius = 14,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.08),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Image.asset(
        product.imageAsset,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, _, _) => Center(
          child: Text(
            product.name.characters.first,
            style: TextStyle(fontSize: size * 0.4, color: cs.primary),
          ),
        ),
      ),
    );
  }
}
