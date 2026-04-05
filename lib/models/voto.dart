class Voto {
  double valore;
  DateTime data;
  String? descrizione;
  String tipo; // 'scritto', 'orale', 'pratico'

  Voto({
    required this.valore,
    required this.data,
    this.descrizione,
    this.tipo = 'scritto',
  });
}
