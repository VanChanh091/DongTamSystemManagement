class Box {
  final int? inMatTruoc, inMatSau;
  final bool? canMang, xa, catKhe, be, dan_1_Manh, dan_2_Manh, dongGhim;
  final String? khac_1, khac_2;

  Box({
    this.inMatTruoc,
    this.inMatSau,
    this.canMang,
    this.xa,
    this.catKhe,
    this.be,
    this.dan_1_Manh,
    this.dan_2_Manh,
    this.dongGhim,
    this.khac_1,
    this.khac_2,
  });

  factory Box.fromJson(Map<String, dynamic> json) {
    return Box(
      inMatTruoc: json['inMatTruoc'] ?? 0,
      inMatSau: json['inMatSau'] ?? 0,
      canMang: json['canMang'] ?? false,
      xa: json['xa'] ?? false,
      catKhe: json['catKhe'] ?? false,
      be: json['be'] ?? false,
      dan_1_Manh: json['dan_1_Manh'] ?? false,
      dan_2_Manh: json['dan_2_manh'] ?? false,
      dongGhim: json['dongGhim'] ?? false,
      khac_1: json['khac_1'] ?? "",
      khac_2: json['khac_2'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inMatTruoc': inMatTruoc,
      'inMatSau': inMatSau,
      'canMang': canMang,
      'xa': xa,
      'catKhe': catKhe,
      'be': be,
      'dan_1_Manh': dan_1_Manh,
      'dan_2_manh': dan_2_Manh,
      'dongGhim': dongGhim,
      'khac_1': khac_1,
      'khac_2': khac_2,
    };
  }
}
