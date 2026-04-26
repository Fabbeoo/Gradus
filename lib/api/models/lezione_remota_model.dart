/// Represents a single lesson returned by the ClasseViva lessons API.
/// The API returns lessons by date, not by day-of-week.
class LesioneRemota {
  final String subjectDesc;
  final int dayOfWeek; // 1=Monday ... 6=Saturday
  final int slotNumber;

  LesioneRemota({
    required this.subjectDesc,
    required this.dayOfWeek,
    required this.slotNumber,
  });

  factory LesioneRemota.fromJson(Map<String, dynamic> json) {
    // evtDate is 'YYYY-MM-DD', convert to day of week
    final dateStr = json['evtDate'] as String? ?? '';
    int dayOfWeek = 1;
    if (dateStr.isNotEmpty) {
      final date = DateTime.parse(dateStr);
      dayOfWeek = date.weekday; // 1=Monday, 6=Saturday
    }

    return LesioneRemota(
      subjectDesc: json['subjectDesc'] as String? ?? '',
      dayOfWeek: dayOfWeek,
      slotNumber: json['evtHPos'] as int? ?? 1,
    );
  }
}
