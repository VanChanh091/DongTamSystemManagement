// --- CLASS KẾT QUẢ TRẢ VỀ CHO ORDER DIALOG ---
class PaperStructureResult {
  final String formattedString; // Chuỗi hiển thị: NTA100/BMAT150/NKA110...
  final String? day;
  final String? songE;
  final String? matE;
  final String? songB;
  final String? matB;
  final String? songC;
  final String? matC;
  final String? songA;
  final String? matA;
  final String? songE2;
  final String? matE2;

  PaperStructureResult({
    required this.formattedString,
    this.day,
    this.songE,
    this.matE,
    this.songB,
    this.matB,
    this.songC,
    this.matC,
    this.songA,
    this.matA,
    this.songE2,
    this.matE2,
  });

  static String format({
    String? day,
    String? songE,
    String? matE,
    String? songB,
    String? matB,
    String? songC,
    String? matC,
    String? songA,
    String? matA,
    String? songE2,
    String? matE2,
  }) {
    final parts = [day, songE, matE, songB, matB, songC, matC, songA, matA, songE2, matE2];
    return parts.where((part) => part != null && part.trim().isNotEmpty).join('/');
  }

  factory PaperStructureResult.fromMap(String formatted, Map<String, String?> map) {
    return PaperStructureResult(
      formattedString: formatted,
      day: map["day"],
      songE: map["songE"],
      matE: map["matE"],
      songB: map["songB"],
      matB: map["matB"],
      songC: map["songC"],
      matC: map["matC"],
      songA: map["songA"],
      matA: map["matA"],
      songE2: map["songE2"],
      matE2: map["matE2"],
    );
  }

  factory PaperStructureResult.empty() {
    return PaperStructureResult(
      formattedString: "",
      day: null,
      songE: null,
      matE: null,
      songB: null,
      matB: null,
      songC: null,
      matC: null,
      songA: null,
      matA: null,
      songE2: null,
      matE2: null,
    );
  }
}
