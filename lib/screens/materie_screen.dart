import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/materia.dart';
import 'dettaglio_materia_screen.dart';

class MaterieScreen extends StatefulWidget {
  final List<Materia> materie;
  final VoidCallback onUpdate;

  const MaterieScreen({
    super.key,
    required this.materie,
    required this.onUpdate,
  });

  @override
  State<MaterieScreen> createState() => _MaterieScreenState();
}

class _MaterieScreenState extends State<MaterieScreen>
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

  // Build points that show the global average over time for the selected period.
  List<FlSpot> _spotsAndamentoGenerale(List<Voto> Function(Materia) getVoti) {
    final tuttiVoti =
        widget.materie
            .expand((m) => getVoti(m).map((v) => (materia: m, voto: v)))
            .toList()
          ..sort((a, b) => a.voto.data.compareTo(b.voto.data));

    if (tuttiVoti.length < 2) return [];

    final spots = <FlSpot>[];
    for (int i = 0; i < tuttiVoti.length; i++) {
      final votiFinoAdOra = tuttiVoti.sublist(0, i + 1);
      final perMateria = <Materia, List<double>>{};
      for (final item in votiFinoAdOra) {
        perMateria.putIfAbsent(item.materia, () => []);
        perMateria[item.materia]!.add(item.voto.valore);
      }
      final medie = perMateria.values
          .map((v) => v.reduce((a, b) => a + b) / v.length)
          .toList();
      final mediaGen = medie.reduce((a, b) => a + b) / medie.length;
      spots.add(FlSpot(i.toDouble(), mediaGen));
    }
    return spots;
  }

  // Show a bottom sheet with a larger chart for the global average.
  void _mostraGraficoGenerale(
    BuildContext context,
    List<FlSpot> spots,
    double media,
  ) {
    final colore = media >= 7
        ? Colors.green
        : media >= 6
        ? Colors.orange
        : Colors.red;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Andamento Media Generale',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colore.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colore.withOpacity(0.5)),
                  ),
                  child: Text(
                    media.toStringAsFixed(2),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colore,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
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
                        color: colore.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Linea tratteggiata = sufficienza',
                style: TextStyle(fontSize: 11, color: Colors.white24),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Open the form to add a new subject.
  void _aggiungiMateria(BuildContext context) {
    _apriFormMateria(context);
  }

  // Open the form to edit an existing subject.
  void _modificaMateria(BuildContext context, Materia materia) {
    _apriFormMateria(context, materia: materia);
  }

  // Show a bottom sheet form to add or edit a subject.
  void _apriFormMateria(BuildContext context, {Materia? materia}) {
    final isModifica = materia != null;
    final nomeController = TextEditingController(
      text: isModifica ? materia.nome : '',
    );
    final professoreController = TextEditingController(
      text: isModifica ? materia.professore ?? '' : '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isModifica ? 'Modifica Materia' : 'Nuova Materia',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nomeController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Nome materia *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: professoreController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Professore (opzionale)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (nomeController.text.trim().isEmpty) return;
                  if (isModifica) {
                    materia.nome = nomeController.text.trim();
                    materia.professore =
                        professoreController.text.trim().isEmpty
                        ? null
                        : professoreController.text.trim();
                  } else {
                    widget.materie.add(
                      Materia(
                        nome: nomeController.text.trim(),
                        professore: professoreController.text.trim().isEmpty
                            ? null
                            : professoreController.text.trim(),
                      ),
                    );
                  }
                  widget.onUpdate();
                  Navigator.pop(context);
                },
                child: Text(isModifica ? 'Salva modifiche' : 'Aggiungi'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Ask the user to confirm deleting a subject and remove it if confirmed.
  void _eliminaMateria(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina materia'),
        content: Text(
          'Vuoi eliminare "${widget.materie[index].nome}"? Tutti i voti verranno persi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () {
              widget.materie.removeAt(index);
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

  // Return a color based on an average value.
  Color _coloreMedia(double media, bool hasVoti) {
    if (!hasVoti) return Colors.grey;
    if (media >= 7) return Colors.green;
    if (media >= 6) return Colors.orange;
    return Colors.red;
  }

  // Return an icon for trend direction.
  Widget _tendenzaWidget(int tendenza) {
    if (tendenza == 1) {
      return const Icon(Icons.arrow_upward, color: Colors.green, size: 18);
    } else if (tendenza == -1) {
      return const Icon(Icons.arrow_downward, color: Colors.red, size: 18);
    }
    return const Icon(Icons.drag_handle, color: Colors.grey, size: 18);
  }

  // Compute the global average for the selected period across subjects.
  double _mediaGeneralePeriodo(List<Voto> Function(Materia) getVoti) {
    final con = widget.materie.where((m) => getVoti(m).isNotEmpty).toList();
    if (con.isEmpty) return 0;
    final medie = con.map((m) {
      final v = getVoti(m);
      return v.map((e) => e.valore).reduce((a, b) => a + b) / v.length;
    });
    return medie.reduce((a, b) => a + b) / con.length;
  }

  // Compute the overall trend for the selected period: up, down, or stable.
  int _tendenzaGeneralePeriodo(List<Voto> Function(Materia) getVoti) {
    final con = widget.materie.where((m) => getVoti(m).length >= 2).toList();
    if (con.isEmpty) return 0;
    int su = 0, giu = 0;
    for (final m in con) {
      final t = m.tendenzaPeriodo(getVoti(m));
      if (t == 1) su++;
      if (t == -1) giu++;
    }
    if (su > giu) return 1;
    if (giu > su) return -1;
    return 0;
  }

  // Build the UI list for a given period (first or second).
  Widget _buildLista(List<Voto> Function(Materia) getVoti, String periodo) {
    final materie = widget.materie;
    final mediaGen = _mediaGeneralePeriodo(getVoti);
    final hasVoti = materie.any((m) => getVoti(m).isNotEmpty);
    final spots = _spotsAndamentoGenerale(getVoti);
    final colore = _coloreMedia(mediaGen, hasVoti);

    return Column(
      children: [
        // Card that shows the global average and opens the chart on tap.
        GestureDetector(
          onTap: spots.length >= 2
              ? () => _mostraGraficoGenerale(context, spots, mediaGen)
              : null,
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colore.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colore.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Media Generale',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (spots.length >= 2)
                      const Text(
                        'Tocca per vedere il grafico',
                        style: TextStyle(fontSize: 11, color: Colors.white38),
                      ),
                  ],
                ),
                Row(
                  children: [
                    _tendenzaWidget(_tendenzaGeneralePeriodo(getVoti)),
                    const SizedBox(width: 8),
                    Text(
                      hasVoti ? mediaGen.toStringAsFixed(2) : 'N/D',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: colore,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // List of subjects for the selected period.
        Expanded(
          child: materie.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 80,
                        color: Colors.white24,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Nessuna materia',
                        style: TextStyle(fontSize: 20, color: Colors.white38),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tocca + per aggiungerne una',
                        style: TextStyle(color: Colors.white24),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: materie.length,
                  itemBuilder: (context, index) {
                    final materia = materie[index];
                    final votiPeriodo = getVoti(materia);
                    final haVoti = votiPeriodo.isNotEmpty;
                    final media = haVoti
                        ? votiPeriodo
                                  .map((v) => v.valore)
                                  .reduce((a, b) => a + b) /
                              votiPeriodo.length
                        : 0.0;
                    final mediaStr = haVoti ? media.toStringAsFixed(2) : 'N/D';
                    final coloreM = _coloreMedia(media, haVoti);
                    final tendenza = materia.tendenzaPeriodo(votiPeriodo);

                    return Dismissible(
                      key: Key('${materia.nome}_$periodo'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete, color: Colors.red),
                      ),
                      confirmDismiss: (_) async {
                        _eliminaMateria(context, index);
                        return false;
                      },
                      child: GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DettaglioMateriaScreen(
                                materia: materia,
                                onUpdate: widget.onUpdate,
                              ),
                            ),
                          );
                          setState(() {});
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      materia.nome,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (materia.professore != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        materia.professore!,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.white54,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 4),
                                    Text(
                                      '${votiPeriodo.length} vot${votiPeriodo.length == 1 ? 'o' : 'i'}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.white38,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Edit button for the subject.
                              IconButton(
                                onPressed: () =>
                                    _modificaMateria(context, materia),
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  size: 18,
                                  color: Colors.white38,
                                ),
                              ),
                              Row(
                                children: [
                                  _tendenzaWidget(tendenza),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: coloreM.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: coloreM.withOpacity(0.5),
                                      ),
                                    ),
                                    child: Text(
                                      mediaStr,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: coloreM,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                _buildLista((m) => m.primoperiodo, '1° Periodo'),
                _buildLista((m) => m.secondoperiodo, '2° Periodo'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _aggiungiMateria(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
