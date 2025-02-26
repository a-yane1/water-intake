class WaterIntake {
  final String id;
  final int amount;
  final DateTime timestamp;

  WaterIntake(
      {required this.id, required this.amount, required this.timestamp});

  // Converts the WaterIntake object to a map for JSON encoding
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Converts a map (JSON) to a WaterIntake object
  factory WaterIntake.fromJson(Map<String, dynamic> json) {
    return WaterIntake(
      id: json['id'],
      amount: json['amount'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
