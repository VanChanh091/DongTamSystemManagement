class Box {
  final int? inMatTruoc, inMatSau;
  final bool? canMang,
      Xa,
      catKhe,
      be,
      dan_1_Manh,
      dan_2_Manh,
      dongGhim1Manh,
      dongGhim2Manh,
      chongTham;
  final String? dongGoi, maKhuon;

  Box({
    this.inMatTruoc,
    this.inMatSau,
    this.canMang,
    this.Xa,
    this.catKhe,
    this.be,
    this.dan_1_Manh,
    this.dan_2_Manh,
    this.dongGhim1Manh,
    this.dongGhim2Manh,
    this.chongTham,
    this.dongGoi,
    this.maKhuon,
  });

  factory Box.fromJson(Map<String, dynamic> json) {
    return Box(
      inMatTruoc: json['inMatTruoc'] ?? 0,
      inMatSau: json['inMatSau'] ?? 0,
      canMang: json['canMang'] ?? false,
      Xa: json['Xa'] ?? false,
      catKhe: json['catKhe'] ?? false,
      be: json['be'] ?? false,
      dan_1_Manh: json['dan_1_Manh'] ?? false,
      dan_2_Manh: json['dan_2_Manh'] ?? false,
      dongGhim1Manh: json['dongGhim1Manh'] ?? false,
      dongGhim2Manh: json['dongGhim2Manh'] ?? false,
      chongTham: json['chongTham'] ?? false,
      dongGoi: json['dongGoi'] ?? "",
      maKhuon: json['maKhuon'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inMatTruoc': inMatTruoc,
      'inMatSau': inMatSau,
      'canMang': canMang,
      'Xa': Xa,
      'catKhe': catKhe,
      'be': be,
      'dan_1_Manh': dan_1_Manh,
      'dan_2_Manh': dan_2_Manh,
      'dongGhim1Manh': dongGhim1Manh,
      'dongGhim2Manh': dongGhim2Manh,
      'chongTham': chongTham,
      'dongGoi': dongGoi,
      'maKhuon': maKhuon,
    };
  }
}
