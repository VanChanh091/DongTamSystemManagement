double toDouble(dynamic val) {
  if (val is int) return val.toDouble();
  if (val is double) return val;
  return 0.0;
}
