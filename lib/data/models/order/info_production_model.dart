class InfoProduction {
  final String? dayReplace;
  final String? middle_1Replace;
  final String? middle_2Replace;
  final String? matReplace;
  final String? songE_Replace;
  final String? songB_Replace;
  final String? songC_Replace;
  final String? songE2_Replace;
  final double sizePaper;
  final int quantity;
  final int numberChild;
  final String? instructSpecial;
  final String? teBien;

  InfoProduction({
    this.dayReplace,
    this.middle_1Replace,
    this.middle_2Replace,
    this.matReplace,
    this.songE_Replace,
    this.songB_Replace,
    this.songC_Replace,
    this.songE2_Replace,
    required this.sizePaper,
    required this.quantity,
    this.instructSpecial,
    required this.numberChild,
    this.teBien,
  });

  //fix here
  String get formatterStructureInfo {
    final prefixes = ['', 'E', '', 'B', '', 'C', '', ''];
    final parts = [
      dayReplace,
      songE_Replace,
      middle_1Replace,
      songB_Replace,
      middle_2Replace,
      songC_Replace,
      matReplace,
      songE2_Replace,
    ];
    final formattedParts = <String>[];

    for (int i = 0; i < parts.length; i++) {
      final part = parts[i];
      if (part != null && part.isNotEmpty) {
        final prefix = prefixes[i];
        if (!part.startsWith(prefix.replaceAll(r'[^A-Z]', ""))) {
          formattedParts.add('$prefix$part');
        } else {
          formattedParts.add(part);
        }
      }
    }
    return formattedParts.join('/');
  }

  factory InfoProduction.fromJson(Map<String, dynamic> json) {
    return InfoProduction(
      dayReplace: json['dayReplace'] ?? "",
      middle_1Replace: json['middle_1Replace'] ?? "",
      middle_2Replace: json['middle_2Replace'] ?? "",
      matReplace: json['matReplace'] ?? "",
      songE_Replace: json['songE_Replace'] ?? "",
      songB_Replace: json['songB_Replace'] ?? "",
      songC_Replace: json['songC_Replace'] ?? "",
      songE2_Replace: json['songE2_Replace'] ?? "",
      sizePaper:
          (json['sizePaper'] is int)
              ? (json['sizePaper'] as int).toDouble()
              : (json['sizePaper'] ?? 0.0) as double,
      quantity: json['quantity'] ?? 0,
      instructSpecial: json['instructSpecial'] ?? "",
      numberChild: json['numberChild'] ?? 0,
      teBien: json['teBien'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayReplace': dayReplace,
      'middle_1Replace': middle_1Replace,
      'middle_2Replace': middle_2Replace,
      'matReplace': matReplace,
      'songE_Replace': songE_Replace,
      'songB_Replace': songB_Replace,
      'songC_Replace': songC_Replace,
      'songE2_Replace': songE2_Replace,
      'sizePaper': sizePaper,
      'quantity': quantity,
      'instructSpecial': instructSpecial,
      'numberChild': numberChild,
      'teBien': teBien,
    };
  }
}
