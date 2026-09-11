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
    this.songE2,
    this.matE2,
  });

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
      songE2: null,
      matE2: null,
    );
  }
}
