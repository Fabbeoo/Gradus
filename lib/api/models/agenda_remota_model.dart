/// Represents a single agenda event (homework, test, oral exam)
/// returned by the ClasseViva API.
class AgendaRemota {
  final String authorName;
  final String subjectDesc;
  final String notes;
  final DateTime begin;
  final DateTime end;
  final String evtCode; // 'AGHW' = homework, 'AGNT' = test/note

  AgendaRemota({
    required this.authorName,
    required this.subjectDesc,
    required this.notes,
    required this.begin,
    required this.end,
    required this.evtCode,
  });

  factory AgendaRemota.fromJson(Map<String, dynamic> json) {
    final beginStr = json['evtDatetimeBegin'] as String? ?? '';
    final endStr = json['evtDatetimeEnd'] as String? ?? '';

    // Use authorName as fallback when subjectDesc is null
    final subjectDesc =
        json['subjectDesc'] as String? ?? json['authorName'] as String? ?? '';
    final notes = json['notes'] as String? ?? '';

    return AgendaRemota(
      authorName: json['authorName'] as String? ?? '',
      subjectDesc: subjectDesc,
      notes: notes,
      begin: beginStr.isNotEmpty ? DateTime.parse(beginStr) : DateTime.now(),
      end: endStr.isNotEmpty ? DateTime.parse(endStr) : DateTime.now(),
      evtCode: json['evtCode'] as String? ?? '',
    );
  }
}
