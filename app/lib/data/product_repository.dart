import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/product.dart';

class ProductRepository {
  List<Product> products = [];
  Map<String, dynamic> meta = {};

  Future<void> load() async {
    final raw = await rootBundle.loadString('assets/products.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    meta = Map<String, dynamic>.from(data['meta'] ?? const {});
    products = (data['products'] as List)
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  List<String> get categories {
    final s = <String>{};
    for (final p in products) {
      s.add(p.category);
    }
    return s.toList();
  }
}
