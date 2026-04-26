/// Represents a single grade returned by the ClasseViva API.
class VotoRemoto {
  final String subjectDesc;
  final double decimalValue;
  final String stringValue;
  final DateTime eventDate;
  final String notes;
  final String componentDesc;
  final int periodPos; // 1 = first period, 3 = second period (Pentamestre)

  VotoRemoto({
    required this.subjectDesc,
    required this.decimalValue,
    required this.stringValue,
    required this.eventDate,
    required this.notes,
    required this.componentDesc,
    required this.periodPos,
  });

  factory VotoRemoto.fromJson(Map<String, dynamic> json) {
    final decimalValue = (json['decimalValue'] as num?)?.toDouble() ?? 0.0;
    final dateStr = json['evtDate'] as String? ?? '';
    final eventDate = dateStr.isNotEmpty
        ? DateTime.parse(dateStr)
        : DateTime.now();

    return VotoRemoto(
      subjectDesc: json['subjectDesc'] as String? ?? '',
      decimalValue: decimalValue,
      stringValue: json['displayValue'] as String? ?? '',
      eventDate: eventDate,
      notes: json['notesForFamily'] as String? ?? '',
      componentDesc: json['componentDesc'] as String? ?? 'Scritto',
      periodPos: json['periodPos'] as int? ?? 1,
    );
  }
}
