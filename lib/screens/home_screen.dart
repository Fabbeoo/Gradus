import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/materia.dart';
import '../models/compito.dart';

class HomeScreen extends StatelessWidget {
  final String nomeStudente;
  final List<Materia> materie;
  final List<Compito> compiti;

  const HomeScreen({
    super.key,
    required this.nomeStudente,
    required this.materie,
    required this.compiti,
  });

  Color _coloreMedia(double media, bool hasVoti) {
    if (!hasVoti) return Colors.grey;
    if (media >= 7) return Colors.green;
    if (media >= 6) return Colors.orange;
    return Colors.red;
  }

  Widget _tendenzaWidget(int tendenza) {
    if (tendenza == 1) {
      return const Icon(Icons.arrow_upward, color: Colors.green, size: 18);
    } else if (tendenza == -1) {
      return const Icon(Icons.arrow_downward, color: Colors.red, size: 18);
    }
    return const Icon(Icons.drag_handle, color: Colors.grey, size: 18);
  }

  double _mediaGenerale(List<Materia> materie) {
    final con = materie.where((m) => m.voti.isNotEmpty).toList();
    if (con.isEmpty) return 0;
    return con.map((m) => m.media).reduce((a, b) => a + b) / con.length;
  }

  int _tendenzaGenerale(List<Materia> materie) {
    final con = materie.where((m) => m.voti.length >= 2).toList();
    if (con.isEmpty) return 0;
    int su = 0, giu = 0;
    for (final m in con) {
      if (m.tendenza == 1) su++;
      if (m.tendenza == -1) giu++;
    }
    if (su > giu) return 1;
    if (giu > su) return -1;
    return 0;
  }

  // Calcola la media generale nel tempo — ogni volta che viene aggiunto
  // un voto (in ordine cronologico) ricalcola la media di tutte le materie
  List<FlSpot> _spotsAndamentoGenerale(List<Materia> materie) {
    // Raccogli tutti i voti con la loro materia, ordinati per data
    final tuttiVoti =
        materie.expand((m) => m.voti.map((v) => (materia: m, voto: v))).toList()
          ..sort((a, b) => a.voto.data.compareTo(b.voto.data));

    if (tuttiVoti.length < 2) return [];

    final spots = <FlSpot>[];
    // Per ogni voto aggiunto, ricalcola la media generale
    for (int i = 0; i < tuttiVoti.length; i++) {
      final votiFinoAdOra = tuttiVoti.sublist(0, i + 1);
      // Raggruppa per materia
      final perMateria = <Materia, List<double>>{};
      for (final item in votiFinoAdOra) {
        perMateria.putIfAbsent(item.materia, () => []);
        perMateria[item.materia]!.add(item.voto.valore);
      }
      // Media delle medie
      final medie = perMateria.values
          .map((v) => v.reduce((a, b) => a + b) / v.length)
          .toList();
      final mediaGen = medie.reduce((a, b) => a + b) / medie.length;
      spots.add(FlSpot(i.toDouble(), mediaGen));
    }
    return spots;
  }

  List<Voto> _ultimiVoti(List<Materia> materie, {int n = 5}) {
    final tutti = materie.expand((m) => m.voti).toList()
      ..sort((a, b) => b.data.compareTo(a.data));
    return tutti.take(n).toList();
  }

  String _nomeMateriaDiVoto(Voto voto, List<Materia> materie) {
    for (final m in materie) {
      if (m.voti.contains(voto)) return m.nome;
    }
    return '';
  }

  Color _coloreVoto(double v) {
    if (v >= 7) return Colors.green;
    if (v >= 6) return Colors.orange;
    return Colors.red;
  }

  List<Compito> _compitiSettimana(List<Compito> compiti) {
    final oggi = DateTime.now();
    final fineSettimana = oggi.add(const Duration(days: 7));
    return compiti
        .where(
          (c) =>
              !c.completato &&
              c.dataConsegna.isAfter(oggi.subtract(const Duration(days: 1))) &&
              c.dataConsegna.isBefore(fineSettimana),
        )
        .toList()
      ..sort((a, b) => a.dataConsegna.compareTo(b.dataConsegna));
  }

  List<Compito> _verificheSettimana(List<Compito> compiti) {
    final oggi = DateTime.now();
    final fineSettimana = oggi.add(const Duration(days: 7));
    return compiti
        .where(
          (c) =>
              !c.completato &&
              (c.tipo == TipoCompito.verifica ||
                  c.tipo == TipoCompito.interrogazione) &&
              c.dataConsegna.isAfter(oggi.subtract(const Duration(days: 1))) &&
              c.dataConsegna.isBefore(fineSettimana),
        )
        .toList()
      ..sort((a, b) => a.dataConsegna.compareTo(b.dataConsegna));
  }

  List<Materia> _materieDaRecuperare(List<Materia> materie) {
    final periodo = Materia.periodoCorrente();
    return materie.where((m) {
      final voti = periodo == 0 ? m.primoperiodo : m.secondoperiodo;
      return voti.isNotEmpty &&
          voti.map((v) => v.valore).reduce((a, b) => a + b) / voti.length < 6;
    }).toList();
  }

  String _formatData(DateTime data) {
    final oggi = DateTime.now();
    final domani = oggi.add(const Duration(days: 1));
    if (data.day == oggi.day && data.month == oggi.month) return 'Oggi';
    if (data.day == domani.day && data.month == domani.month) return 'Domani';
    return '${data.day}/${data.month}';
  }

  String _labelTipo(TipoCompito tipo) {
    switch (tipo) {
      case TipoCompito.verifica:
        return 'Verifica';
      case TipoCompito.interrogazione:
        return 'Interrogazione';
      case TipoCompito.compito:
        return 'Compito';
    }
  }

  Color _coloreTipo(TipoCompito tipo) {
    switch (tipo) {
      case TipoCompito.verifica:
        return Colors.red;
      case TipoCompito.interrogazione:
        return Colors.orange;
      case TipoCompito.compito:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasVoti = materie.any((m) => m.voti.isNotEmpty);
    final mediaGen = _mediaGenerale(materie);
    final tendenzaGen = _tendenzaGenerale(materie);
    final spots = _spotsAndamentoGenerale(materie);
    final ultimiVoti = _ultimiVoti(materie);
    final compitiSett = _compitiSettimana(compiti);
    final verificheSett = _verificheSettimana(compiti);
    final daRecuperare = _materieDaRecuperare(materie);
    final periodo = Materia.periodoCorrente() == 0 ? '1°' : '2°';
    final colore = _coloreMedia(mediaGen, hasVoti);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Saluto
          Text(
            'Ciao, $nomeStudente! 👋',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          Text(
            '$periodo Periodo',
            style: const TextStyle(fontSize: 14, color: Colors.white54),
          ),
          const SizedBox(height: 20),

          // Card media + grafico unificata
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colore.withOpacity(0.3), colore.withOpacity(0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colore.withOpacity(0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Riga media + tendenza
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Media Generale',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            hasVoti ? mediaGen.toStringAsFixed(2) : 'N/D',
                            style: TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.bold,
                              color: colore,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        _tendenzaWidget(tendenzaGen),
                        const SizedBox(height: 4),
                        Text(
                          tendenzaGen == 1
                              ? 'In salita'
                              : tendenzaGen == -1
                              ? 'In discesa'
                              : 'Stabile',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Grafico andamento
                if (spots.length >= 2) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 140,
                    child: LineChart(
                      LineChartData(
                        minY: 1,
                        maxY: 10,
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 3,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.white.withOpacity(0.08),
                            strokeWidth: 1,
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 3,
                              reservedSize: 28,
                              getTitlesWidget: (value, meta) => Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white38,
                                ),
                              ),
                            ),
                          ),
                          bottomTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        lineBarsData: [
                          // Linea sufficienza tratteggiata
                          LineChartBarData(
                            spots: [
                              FlSpot(0, 6),
                              FlSpot((spots.length - 1).toDouble(), 6),
                            ],
                            isCurved: false,
                            color: Colors.white24,
                            barWidth: 1,
                            dotData: const FlDotData(show: false),
                            dashArray: [5, 5],
                          ),
                          // Linea andamento media
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            curveSmoothness: 0.3,
                            color: colore,
                            barWidth: 3,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, bar, index) =>
                                  FlDotCirclePainter(
                                    radius: 4,
                                    color: colore,
                                    strokeWidth: 2,
                                    strokeColor: Colors.black,
                                  ),
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: colore.withOpacity(0.15),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Center(
                    child: Text(
                      'Andamento nel tempo — linea tratteggiata = sufficienza',
                      style: TextStyle(fontSize: 11, color: Colors.white24),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Materie da recuperare
          if (daRecuperare.isNotEmpty) ...[
            _sectionTitle('⚠️ Da recuperare'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                children: daRecuperare.map((m) {
                  final voti = Materia.periodoCorrente() == 0
                      ? m.primoperiodo
                      : m.secondoperiodo;
                  final media =
                      voti.map((v) => v.valore).reduce((a, b) => a + b) /
                      voti.length;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          m.nome,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            media.toStringAsFixed(2),
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Ultimi voti
          if (ultimiVoti.isNotEmpty) ...[
            _sectionTitle('Ultimi voti'),
            const SizedBox(height: 8),
            ...ultimiVoti.map((voto) {
              final nomeMateria = _nomeMateriaDiVoto(voto, materie);
              final coloreVoto = _coloreVoto(voto.valore);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: coloreVoto.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: coloreVoto.withOpacity(0.5)),
                      ),
                      child: Center(
                        child: Text(
                          voto.valore % 1 == 0
                              ? voto.valore.toInt().toString()
                              : voto.valore.toString(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: coloreVoto,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nomeMateria,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${voto.tipo} — ${voto.data.day}/${voto.data.month}/${voto.data.year}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white38,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
          ],

          // Verifiche e interrogazioni
          if (verificheSett.isNotEmpty) ...[
            _sectionTitle('Verifiche e interrogazioni questa settimana'),
            const SizedBox(height: 8),
            ...verificheSett.map((c) {
              final coloreC = _coloreTipo(c.tipo);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: coloreC.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: coloreC.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: coloreC.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _formatData(c.dataConsegna),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: coloreC,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.materia,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _labelTipo(c.tipo),
                            style: TextStyle(fontSize: 12, color: coloreC),
                          ),
                          if (c.descrizione.isNotEmpty)
                            Text(
                              c.descrizione,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white54,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
          ],

          // Compiti settimana
          if (compitiSett
              .where((c) => c.tipo == TipoCompito.compito)
              .isNotEmpty) ...[
            _sectionTitle('Compiti questa settimana'),
            const SizedBox(height: 8),
            ...compitiSett
                .where((c) => c.tipo == TipoCompito.compito)
                .map(
                  (c) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.blue.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _formatData(c.dataConsegna),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.materia,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (c.descrizione.isNotEmpty)
                                Text(
                                  c.descrizione,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white54,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            const SizedBox(height: 16),
          ],

          // Tutto ok
          if (!hasVoti &&
              compitiSett.isEmpty &&
              verificheSett.isEmpty &&
              daRecuperare.isEmpty)
            Center(
              child: Column(
                children: const [
                  SizedBox(height: 40),
                  Icon(
                    Icons.sentiment_satisfied_alt,
                    size: 80,
                    color: Colors.white24,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Tutto in ordine!',
                    style: TextStyle(fontSize: 20, color: Colors.white38),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Inizia aggiungendo le tue materie',
                    style: TextStyle(fontSize: 14, color: Colors.white24),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white70,
      ),
    );
  }
}
