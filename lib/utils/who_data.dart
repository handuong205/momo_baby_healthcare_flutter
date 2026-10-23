enum GrowthMetric { weight, height }

class WhoRow {
  final double month;
  final double p3;
  final double p15;
  final double p50;
  final double p85;
  final double p97;

  const WhoRow(this.month, this.p3, this.p15, this.p50, this.p85, this.p97);
}

const _weightBoys = [
  WhoRow(0, 2.5, 2.9, 3.3, 3.9, 4.4),
  WhoRow(2, 4.3, 4.9, 5.6, 6.3, 7.1),
  WhoRow(4, 5.6, 6.2, 7.0, 7.8, 8.6),
  WhoRow(6, 6.4, 7.1, 7.9, 8.8, 9.7),
  WhoRow(8, 7.0, 7.8, 8.6, 9.6, 10.5),
  WhoRow(10, 7.5, 8.3, 9.2, 10.2, 11.2),
  WhoRow(12, 7.8, 8.7, 9.6, 10.7, 11.8),
  WhoRow(15, 8.4, 9.3, 10.3, 11.5, 12.7),
  WhoRow(18, 8.9, 9.9, 10.9, 12.2, 13.5),
  WhoRow(21, 9.4, 10.4, 11.5, 12.9, 14.3),
  WhoRow(24, 9.8, 10.9, 12.0, 13.5, 15.0),
];
const _weightGirls = [
  WhoRow(0, 2.4, 2.8, 3.2, 3.8, 4.2),
  WhoRow(2, 3.9, 4.5, 5.1, 5.8, 6.6),
  WhoRow(4, 5.0, 5.7, 6.4, 7.3, 8.2),
  WhoRow(6, 5.8, 6.5, 7.3, 8.2, 9.3),
  WhoRow(8, 6.3, 7.0, 7.9, 9.0, 10.2),
  WhoRow(10, 6.8, 7.5, 8.5, 9.6, 10.9),
  WhoRow(12, 7.1, 7.9, 8.9, 10.1, 11.5),
  WhoRow(15, 7.7, 8.5, 9.6, 10.9, 12.4),
  WhoRow(18, 8.2, 9.1, 10.2, 11.6, 13.2),
  WhoRow(21, 8.6, 9.6, 10.8, 12.3, 14.0),
  WhoRow(24, 9.0, 10.1, 11.4, 13.0, 14.8),
];
const _heightBoys = [
  WhoRow(0, 46.3, 48.0, 49.9, 51.8, 53.4),
  WhoRow(2, 54.4, 56.4, 58.4, 60.4, 62.4),
  WhoRow(4, 59.7, 61.8, 63.9, 66.0, 68.0),
  WhoRow(6, 63.6, 65.7, 67.9, 70.1, 72.2),
  WhoRow(8, 66.8, 69.0, 71.2, 73.5, 75.6),
  WhoRow(10, 69.6, 71.8, 74.1, 76.4, 78.6),
  WhoRow(12, 71.9, 74.2, 76.5, 78.9, 81.1),
  WhoRow(15, 75.0, 77.4, 79.9, 82.4, 84.7),
  WhoRow(18, 77.8, 80.4, 83.0, 85.6, 88.0),
  WhoRow(21, 80.5, 83.1, 85.9, 88.6, 91.2),
  WhoRow(24, 82.9, 85.7, 88.6, 91.4, 94.1),
];
const _heightGirls = [
  WhoRow(0, 45.6, 47.3, 49.1, 51.0, 52.7),
  WhoRow(2, 53.2, 55.0, 57.1, 59.1, 60.9),
  WhoRow(4, 58.0, 60.0, 62.1, 64.2, 66.2),
  WhoRow(6, 61.5, 63.5, 65.7, 67.9, 69.9),
  WhoRow(8, 64.5, 66.6, 68.8, 71.1, 73.2),
  WhoRow(10, 67.0, 69.2, 71.5, 73.9, 76.1),
  WhoRow(12, 69.2, 71.4, 73.7, 76.1, 78.4),
  WhoRow(15, 72.2, 74.5, 77.0, 79.5, 81.8),
  WhoRow(18, 74.9, 77.4, 80.0, 82.6, 85.0),
  WhoRow(21, 77.5, 80.1, 82.7, 85.4, 88.0),
  WhoRow(24, 79.8, 82.5, 85.2, 88.0, 90.7),
];

List<WhoRow> whoTable(GrowthMetric metric, bool isBoy) =>
    metric == GrowthMetric.weight
        ? (isBoy ? _weightBoys : _weightGirls)
        : (isBoy ? _heightBoys : _heightGirls);

WhoRow? whoAt(List<WhoRow> table, double month) {
  if (month < 0 || month > 24) return null;
  final upperIndex = table.indexWhere((row) => row.month >= month);
  final upper = table[upperIndex];
  if (upper.month == month || upperIndex == 0) {
    return WhoRow(month, upper.p3, upper.p15, upper.p50, upper.p85, upper.p97);
  }
  final lower = table[upperIndex - 1];
  final t = (month - lower.month) / (upper.month - lower.month);
  double mix(double a, double b) => a + (b - a) * t;
  return WhoRow(month, mix(lower.p3, upper.p3), mix(lower.p15, upper.p15),
      mix(lower.p50, upper.p50), mix(lower.p85, upper.p85), mix(lower.p97, upper.p97));
}

String? classifyGrowth(GrowthMetric metric, bool isBoy, double month, double value) {
  final ref = whoAt(whoTable(metric, isBoy), month);
  if (ref == null) return null;
  if (value < ref.p3) return metric == GrowthMetric.weight ? 'Nhẹ cân so với chuẩn' : 'Thấp so với chuẩn';
  if (value < ref.p15) return metric == GrowthMetric.weight ? 'Hơi nhẹ cân' : 'Hơi thấp';
  if (value <= ref.p85) return 'Trong mức chuẩn';
  if (value <= ref.p97) return metric == GrowthMetric.weight ? 'Hơi nặng cân' : 'Hơi cao';
  return metric == GrowthMetric.weight ? 'Nặng cân so với chuẩn' : 'Cao vượt chuẩn';
}

double ageInMonths(DateTime dob, DateTime at) =>
    at.difference(dob).inMilliseconds / (30.44 * 24 * 60 * 60 * 1000);
