class QuantitativePaper {
  final int day, songE, matE, songB, matB, songC, matC;

  QuantitativePaper({
    required this.day,
    required this.songE,
    required this.matE,
    required this.songB,
    required this.matB,
    required this.songC,
    required this.matC,
  });

  factory QuantitativePaper.fromJson(Map<String, dynamic> json) {
    return QuantitativePaper(
      day: json['day'],
      songE: json['songE'],
      matE: json['matE'],
      songB: json['songB'],
      matB: json['matB'],
      songC: json['songC'],
      matC: json['matC'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'songE': songE,
      'matE': matE,
      'songB': songB,
      'matB': matB,
      'songC': songC,
      'matC': matC,
    };
  }
}
