import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/materia.dart';

class VotiScreen extends StatefulWidget {
  final List<Materia> materie;
  final VoidCallback onUpdate; // aggiungi questo

  const VotiScreen({super.key, required this.materie, required this.onUpdate});

  @override
  State<VotiScreen> createState() => _VotiScreenState();
}

class _VotiScreenState extends State<VotiScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Materia? _materiaSelezionata;

  // Lista completa dei voti italiani
  final List<Map<String, dynamic>> _votiDisponibili = [
    {'label': '1', 'valore': 1.00},
    {'label': '1+', 'valore': 1.25},
    {'label': '1½', 'valore': 1.50},
    {'label': '2-', 'valore': 1.75},
    {'label': '2', 'valore': 2.00},
    {'label': '2+', 'valore': 2.25},
    {'label': '2½', 'valore': 2.50},
    {'label': '3-', 'valore': 2.75},
    {'label': '3', 'valore': 3.00},
    {'label': '3+', 'valore': 3.25},
    {'label': '3½', 'valore': 3.50},
    {'label': '4-', 'valore': 3.75},
    {'label': '4', 'valore': 4.00},
    {'label': '4+', 'valore': 4.25},
    {'label': '4½', 'valore': 4.50},
    {'label': '5-', 'valore': 4.75},
    {'label': '5', 'valore': 5.00},
    {'label': '5+', 'valore': 5.25},
    {'label': '5½', 'valore': 5.50},
    {'label': '6-', 'valore': 5.75},
    {'label': '6', 'valore': 6.00},
    {'label': '6+', 'valore': 6.25},
    {'label': '6½', 'valore': 6.50},
    {'label': '7-', 'valore': 6.75},
    {'label': '7', 'valore': 7.00},
    {'label': '7+', 'valore': 7.25},
    {'label': '7½', 'valore': 7.50},
    {'label': '8-', 'valore': 7.75},
    {'label': '8', 'valore': 8.00},
    {'label': '8+', 'valore': 8.25},
    {'label': '8½', 'valore': 8.50},
    {'label': '9-', 'valore': 8.75},
    {'label': '9', 'valore': 9.00},
    {'label': '9+', 'valore': 9.25},
    {'label': '9½', 'valore': 9.50},
    {'label': '10-', 'valore': 9.75},
    {'label': '10', 'valore': 10.00},
  ];

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

  void _aggiungiVoto(int periodo) {
    if (widget.materie.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aggiungi prima una materia!')),
      );
      return;
    }

    Materia? materiaScelta = _materiaSelezionata;
    final descrizioneController = TextEditingController();
    DateTime dataScelta = periodo == 1
        ? (DateTime.now().month >= 9 && DateTime.now().month <= 12
              ? DateTime.now()
              : DateTime(DateTime.now().year, 10, 1))
        : (DateTime.now().month >= 1 && DateTime.now().month <= 6
              ? DateTime.now()
              : DateTime(DateTime.now().year, 2, 1));

    String tipoScelto = 'scritto';

    // Indice di default sul voto 6
    int votoIndex = _votiDisponibili.indexWhere((v) => v['label'] == '6');
    final FixedExtentScrollController scrollController =
        FixedExtentScrollController(initialItem: votoIndex);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
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
                'Nuovo Voto — ${periodo == 1 ? '1° Periodo' : '2° Periodo'}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Materia
              DropdownButtonFormField<Materia>(
                value: materiaScelta,
                hint: const Text('Seleziona materia'),
                decoration: InputDecoration(
                  labelText: 'Materia',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: widget.materie
                    .map((m) => DropdownMenuItem(value: m, child: Text(m.nome)))
                    .toList(),
                onChanged: (val) => setModalState(() => materiaScelta = val),
              ),
              const SizedBox(height: 16),

              // Picker voto
              const Text(
                'Voto',
                style: TextStyle(fontSize: 15, color: Colors.white54),
              ),
              const SizedBox(height: 8),
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Indicatore selezione
                    Container(
                      height: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                    ),
                    CupertinoPicker(
                      scrollController: scrollController,
                      itemExtent: 40,
                      backgroundColor: Colors.transparent,
                      onSelectedItemChanged: (index) {
                        setModalState(() => votoIndex = index);
                      },
                      children: _votiDisponibili.map((v) {
                        final valore = v['valore'] as double;
                        final label = v['label'] as String;
                        final colore = valore >= 7
                            ? Colors.green
                            : valore >= 6
                            ? Colors.orange
                            : Colors.red;
                        return Center(
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: colore,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Tipo
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'scritto', label: Text('Scritto')),
                  ButtonSegment(value: 'orale', label: Text('Orale')),
                  ButtonSegment(value: 'pratico', label: Text('Pratico')),
                ],
                selected: {tipoScelto},
                onSelectionChanged: (val) =>
                    setModalState(() => tipoScelto = val.first),
              ),
              const SizedBox(height: 12),

              // Data
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  '${dataScelta.day}/${dataScelta.month}/${dataScelta.year}',
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  final firstDate = periodo == 1
                      ? DateTime(DateTime.now().year - 1, 9, 1)
                      : DateTime(DateTime.now().year, 1, 1);
                  final lastDate = periodo == 1
                      ? DateTime(DateTime.now().year, 12, 31)
                      : DateTime(DateTime.now().year, 6, 30);
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: dataScelta,
                    firstDate: firstDate,
                    lastDate: lastDate,
                  );
                  if (picked != null) {
                    setModalState(() => dataScelta = picked);
                  }
                },
              ),
              const SizedBox(height: 12),

              // Descrizione
              TextField(
                controller: descrizioneController,
                decoration: InputDecoration(
                  labelText: 'Descrizione (opzionale)',
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
                    if (materiaScelta == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Seleziona una materia!')),
                      );
                      return;
                    }
                    final valore =
                        _votiDisponibili[votoIndex]['valore'] as double;
                    setState(() {
                      materiaScelta!.voti.add(
                        Voto(
                          valore: valore,
                          data: dataScelta,
                          descrizione: descrizioneController.text.trim().isEmpty
                              ? null
                              : descrizioneController.text.trim(),
                          tipo: tipoScelto,
                        ),
                      );
                      materiaScelta!.voti.sort(
                        (a, b) => a.data.compareTo(b.data),
                      );
                      widget.onUpdate();
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Salva Voto'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _eliminaVoto(Materia materia, Voto voto) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina voto'),
        content: Text('Vuoi eliminare il voto ${voto.valore}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () {
              setState(() => materia.voti.remove(voto));
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

  Color _coloreVoto(double voto) {
    if (voto >= 7) return Colors.green;
    if (voto >= 6) return Colors.orange;
    return Colors.red;
  }

  String _labelVoto(double valore) {
    final found = _votiDisponibili.firstWhere(
      (v) => (v['valore'] as double) == valore,
      orElse: () => {'label': valore.toString(), 'valore': valore},
    );
    return found['label'] as String;
  }

  Widget _buildLista(List<Voto> Function(Materia) getVoti, int periodo) {
    final materieVisibili = _materiaSelezionata != null
        ? [_materiaSelezionata!]
        : widget.materie;

    final tuttiVoti =
        materieVisibili
            .expand((m) => getVoti(m).map((v) => (materia: m, voto: v)))
            .toList()
          ..sort((a, b) => b.voto.data.compareTo(a.voto.data));

    if (tuttiVoti.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.grade_outlined, size: 60, color: Colors.white24),
            SizedBox(height: 12),
            Text(
              'Nessun voto in questo periodo',
              style: TextStyle(color: Colors.white38),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tuttiVoti.length,
      itemBuilder: (context, index) {
        final item = tuttiVoti[index];
        final voto = item.voto;
        final materia = item.materia;
        final colore = _coloreVoto(voto.valore);

        return Dismissible(
          key: Key('voto_${materia.nome}_${voto.data}_${voto.valore}'),
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
            _eliminaVoto(materia, voto);
            return false;
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: colore.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colore.withOpacity(0.5)),
                  ),
                  child: Center(
                    child: Text(
                      _labelVoto(voto.valore),
                      style: TextStyle(
                        fontSize: 16,
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
                        materia.nome,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (voto.descrizione != null)
                        Text(
                          voto.descrizione!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white54,
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
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('Tutte'),
                    selected: _materiaSelezionata == null,
                    onSelected: (_) =>
                        setState(() => _materiaSelezionata = null),
                  ),
                ),
                ...widget.materie.map(
                  (m) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(m.nome),
                      selected: _materiaSelezionata == m,
                      onSelected: (_) =>
                          setState(() => _materiaSelezionata = m),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
                _buildLista((m) => m.primoperiodo, 1),
                _buildLista((m) => m.secondoperiodo, 2),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _aggiungiVoto(_tabController.index + 1),
        child: const Icon(Icons.add),
      ),
    );
  }
}
