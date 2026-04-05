import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/materia.dart';

class DettaglioMateriaScreen extends StatefulWidget {
  final Materia materia;
  final VoidCallback onUpdate;

  const DettaglioMateriaScreen({
    super.key,
    required this.materia,
    required this.onUpdate,
  });

  @override
  State<DettaglioMateriaScreen> createState() => _DettaglioMateriaScreenState();
}

class _DettaglioMateriaScreenState extends State<DettaglioMateriaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: Materia.periodoCorrente(),
    );
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _coloreVoto(double voto) {
    if (voto >= 7) return Colors.green;
    if (voto >= 6) return Colors.orange;
    return Colors.red;
  }

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
    } else {
      return const Icon(Icons.drag_handle, color: Colors.grey, size: 18);
    }
  }

  void _eliminaVoto(List<Voto> lista, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina voto'),
        content: Text('Vuoi eliminare il voto ${lista[index].valore}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                widget.materia.voti.remove(lista[index]);
              });
              widget.onUpdate();
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
  }

  Widget _buildContenuto(List<Voto> votiPeriodo) {
    if (votiPeriodo.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.grade_outlined, size: 80, color: Colors.white24),
            SizedBox(height: 16),
            Text(
              'Nessun voto in questo periodo',
              style: TextStyle(fontSize: 18, color: Colors.white38),
            ),
            SizedBox(height: 8),
            Text(
              'Aggiungi voti dalla scheda Voti',
              style: TextStyle(color: Colors.white24),
            ),
          ],
        ),
      );
    }

    final media =
        votiPeriodo.map((v) => v.valore).reduce((a, b) => a + b) /
        votiPeriodo.length;
    final tendenza = widget.materia.tendenzaPeriodo(votiPeriodo);
    final coloreMedia = _coloreMedia(media, true);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Card media
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: coloreMedia.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: coloreMedia.withOpacity(0.4)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Media',
                    style: TextStyle(fontSize: 14, color: Colors.white54),
                  ),
                  Text(
                    media.toStringAsFixed(2),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: coloreMedia,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      _tendenzaWidget(tendenza),
                      const SizedBox(width: 6),
                      Text(
                        '${votiPeriodo.length} vot${votiPeriodo.length == 1 ? 'o' : 'i'}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                  if (widget.materia.professore != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.materia.professore!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        // Voto necessario per sufficienza
        if (media < 6.0) ...[
          const SizedBox(height: 12),
          Builder(
            builder: (context) {
              final votoNeeded = widget.materia.votoNecessario(votiPeriodo);
              final impossibile = votoNeeded != null && votoNeeded > 10;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: impossibile
                          ? const Text(
                              'Un solo 10 non è sufficiente a raggiungere la sufficienza. Continua a impegnarti!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            )
                          : RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                                children: [
                                  const TextSpan(text: 'Ti serve almeno un '),
                                  TextSpan(
                                    text: votoNeeded!.toStringAsFixed(2),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: ' per raggiungere la sufficienza',
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],

        const SizedBox(height: 20),

        // Grafico
        if (votiPeriodo.length >= 2) ...[
          const Text(
            'Andamento',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 220,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: LineChart(
              LineChartData(
                minY: 1,
                maxY: 10,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.white.withOpacity(0.05),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 2,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white38,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= votiPeriodo.length) {
                          return const SizedBox();
                        }
                        return Text(
                          '${index + 1}°',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white38,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                lineBarsData: [
                  // Linea media tratteggiata
                  LineChartBarData(
                    spots: List.generate(
                      votiPeriodo.length,
                      (i) => FlSpot(i.toDouble(), media),
                    ),
                    isCurved: false,
                    color: Colors.white24,
                    barWidth: 1,
                    dotData: const FlDotData(show: false),
                    dashArray: [5, 5],
                  ),
                  // Linea voti
                  LineChartBarData(
                    spots: List.generate(
                      votiPeriodo.length,
                      (i) => FlSpot(i.toDouble(), votiPeriodo[i].valore),
                    ),
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: coloreMedia,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                            radius: 5,
                            color: _coloreVoto(votiPeriodo[index].valore),
                            strokeWidth: 2,
                            strokeColor: Colors.black,
                          ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: coloreMedia.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Lista voti
        const Text(
          'Voti',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white54,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Scorri a sinistra per eliminare',
          style: TextStyle(fontSize: 12, color: Colors.white24),
        ),
        const SizedBox(height: 12),
        ...votiPeriodo.asMap().entries.map((entry) {
          final i = entry.key;
          final voto = entry.value;
          final colore = _coloreVoto(voto.valore);
          return Dismissible(
            key: Key('voto_${i}_${voto.valore}_${voto.data}'),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.delete, color: Colors.red),
            ),
            confirmDismiss: (_) async {
              _eliminaVoto(votiPeriodo, i);
              return false;
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: colore.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colore.withOpacity(0.5)),
                    ),
                    child: Center(
                      child: Text(
                        voto.valore % 1 == 0
                            ? voto.valore.toInt().toString()
                            : voto.valore.toString(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colore,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          voto.tipo,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white54,
                          ),
                        ),
                        if (voto.descrizione != null)
                          Text(
                            voto.descrizione!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white38,
                            ),
                          ),
                        Text(
                          '${voto.data.day}/${voto.data.month}/${voto.data.year}',
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
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.materia.nome), centerTitle: true),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: '1° Periodo'),
              Tab(text: '2° Periodo'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildContenuto(widget.materia.primoperiodo),
                _buildContenuto(widget.materia.secondoperiodo),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
