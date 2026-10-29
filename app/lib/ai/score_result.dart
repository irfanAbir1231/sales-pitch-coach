class ScoreResult {
  final double total; // out of 10
  final double keyPointsScore; // /4
  final double reasonScore; // /2
  final double structureScore; // /2
  final double toneScore; // /1
  final double noFalseClaimsScore; // /1
  final List<String> coveredPoints;
  final List<String> missedPoints;
  final List<String> falseClaims;
  final String feedback;
  final String betterLine;
  final String providerName;

  ScoreResult({
    required this.total,
    required this.keyPointsScore,
    required this.reasonScore,
    required this.structureScore,
    required this.toneScore,
    required this.noFalseClaimsScore,
    required this.coveredPoints,
    required this.missedPoints,
    required this.falseClaims,
    required this.feedback,
    required this.betterLine,
    required this.providerName,
  });

  Map<String, dynamic> toJson() => {
        'total': total,
        'keyPointsScore': keyPointsScore,
        'reasonScore': reasonScore,
        'structureScore': structureScore,
        'toneScore': toneScore,
        'noFalseClaimsScore': noFalseClaimsScore,
        'coveredPoints': coveredPoints,
        'missedPoints': missedPoints,
        'falseClaims': falseClaims,
        'feedback': feedback,
        'betterLine': betterLine,
        'providerName': providerName,
      };

  factory ScoreResult.fromJson(Map<String, dynamic> j) => ScoreResult(
        total: (j['total'] as num).toDouble(),
        keyPointsScore: (j['keyPointsScore'] as num).toDouble(),
        reasonScore: (j['reasonScore'] as num).toDouble(),
        structureScore: (j['structureScore'] as num).toDouble(),
        toneScore: (j['toneScore'] as num).toDouble(),
        noFalseClaimsScore: (j['noFalseClaimsScore'] as num).toDouble(),
        coveredPoints: List<String>.from(j['coveredPoints']),
        missedPoints: List<String>.from(j['missedPoints']),
        falseClaims: List<String>.from(j['falseClaims']),
        feedback: j['feedback'] as String,
        betterLine: j['betterLine'] as String,
        providerName: j['providerName'] as String,
      );
}
