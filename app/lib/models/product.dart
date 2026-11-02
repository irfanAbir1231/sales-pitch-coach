class KeyPoint {
  final String id;
  final String point;
  final List<String> keywords;
  final List<String> synonyms;
  final int weight;

  KeyPoint({
    required this.id,
    required this.point,
    required this.keywords,
    required this.synonyms,
    required this.weight,
  });

  factory KeyPoint.fromJson(Map<String, dynamic> j) => KeyPoint(
    id: j['id'] as String,
    point: j['point'] as String,
    keywords: List<String>.from(j['keywords'] ?? const []),
    synonyms: List<String>.from(j['synonyms'] ?? const []),
    weight: (j['weight'] ?? 2) as int,
  );
}

class Objection {
  final String question;
  final String idealAnswer;
  Objection(this.question, this.idealAnswer);

  factory Objection.fromJson(Map<String, dynamic> j) =>
      Objection(j['q'] as String, j['ideal_answer'] as String);
}

class Product {
  final String id;
  final String name;
  final String? nameEn;
  final String category;
  final Map<String, dynamic> mrp;
  final String idealPitch;
  final List<KeyPoint> keyPoints;
  final List<String> mustNotSay;
  /// Loaded from assets/objections.json (keyed by product id).
  List<Objection> objections;

  /// Name in the app language; falls back to Bangla when there is no English name.
  String localName(bool english) => english ? (nameEn ?? name) : name;

  String get imageAsset => 'assets/images/products/$id.webp';

  Product({
    required this.id,
    required this.name,
    this.nameEn,
    required this.category,
    required this.mrp,
    required this.idealPitch,
    required this.keyPoints,
    required this.mustNotSay,
    this.objections = const [],
  });

  factory Product.fromJson(Map<String, dynamic> j) => Product(
    id: j['id'] as String,
    name: j['name'] as String,
    nameEn: j['name_en'] as String?,
    category: j['category'] as String,
    mrp: Map<String, dynamic>.from(j['mrp_bdt'] ?? const {}),
    idealPitch: j['ideal_pitch'] as String,
    keyPoints: (j['key_points'] as List)
        .map((e) => KeyPoint.fromJson(e as Map<String, dynamic>))
        .toList(),
    mustNotSay: List<String>.from(j['must_not_say'] ?? const []),
  );

  String get mrpText =>
      mrp.entries.map((e) => '${e.key}: ৳${e.value}').join('  •  ');
}
