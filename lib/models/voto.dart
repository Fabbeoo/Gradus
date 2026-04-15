// Simple class that represents a single grade entry.
class Voto {
  // Numeric grade value (e.g. 6.00, 7.50).
  double valore;
  // Date when the grade was recorded.
  DateTime data;
  // Optional text note about the grade.
  String? descrizione;
  // Type of the grade: 'scritto', 'orale', 'pratico'
  String tipo; // 'scritto', 'orale', 'pratico'

  // Constructor to create a Voto object.
  // - valore and data are required.
  // - descrizione is optional.
  // - tipo defaults to 'scritto' if not provided.
  Voto({
    required this.valore,
    required this.data,
    this.descrizione,
    this.tipo = 'scritto',
  });
}
