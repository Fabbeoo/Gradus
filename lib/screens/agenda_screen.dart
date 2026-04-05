import 'package:flutter/material.dart';
import '../models/compito.dart';
import '../models/materia.dart';

class AgendaScreen extends StatefulWidget {
  final List<Materia> materie;
  final List<Compito> compiti;
  final VoidCallback onUpdate;

  const AgendaScreen({
    super.key,
    required this.materie,
    required this.compiti,
    required this.onUpdate,
  });

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  void _aggiungiCompito() {
    _apriForm();
  }

  void _modificaCompito(Compito compito) {
    _apriForm(compito: compito);
  }

  void _apriForm({Compito? compito}) {
    if (widget.materie.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aggiungi prima una materia!')),
      );
      return;
    }

    final isModifica = compito != null;
    String? materiaScelta = isModifica
        ? compito.materia
        : widget.materie.first.nome;
    final descrizioneController = TextEditingController(
      text: isModifica ? compito.descrizione : '',
    );
    DateTime dataScelta = isModifica
        ? compito.dataConsegna
        : DateTime.now().add(const Duration(days: 1));
    TipoCompito tipoScelto = isModifica ? compito.tipo : TipoCompito.compito;

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
                isModifica ? 'Modifica Elemento' : 'Nuovo Elemento',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Tipo
              SegmentedButton<TipoCompito>(
                segments: const [
                  ButtonSegment(
                    value: TipoCompito.compito,
                    label: Text('Compito'),
                    icon: Icon(Icons.assignment),
                  ),
                  ButtonSegment(
                    value: TipoCompito.verifica,
                    label: Text('Verifica'),
                    icon: Icon(Icons.edit_document),
                  ),
                  ButtonSegment(
                    value: TipoCompito.interrogazione,
                    label: Text('Interrog.'),
                    icon: Icon(Icons.record_voice_over),
                  ),
                ],
                selected: {tipoScelto},
                onSelectionChanged: (val) =>
                    setModalState(() => tipoScelto = val.first),
              ),
              const SizedBox(height: 12),

              // Materia
              DropdownButtonFormField<String>(
                value: materiaScelta,
                decoration: InputDecoration(
                  labelText: 'Materia',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: widget.materie
                    .map(
                      (m) =>
                          DropdownMenuItem(value: m.nome, child: Text(m.nome)),
                    )
                    .toList(),
                onChanged: (val) => setModalState(() => materiaScelta = val),
              ),
              const SizedBox(height: 12),

              // Descrizione
              TextField(
                controller: descrizioneController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Descrizione',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
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
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: dataScelta,
                    firstDate: DateTime.now().subtract(
                      const Duration(days: 365),
                    ),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setModalState(() => dataScelta = picked);
                  }
                },
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (descrizioneController.text.trim().isEmpty) return;
                    setState(() {
                      if (isModifica) {
                        // Modifica in-place
                        compito.materia = materiaScelta!;
                        compito.descrizione = descrizioneController.text.trim();
                        compito.dataConsegna = dataScelta;
                        compito.tipo = tipoScelto;
                      } else {
                        widget.compiti.add(
                          Compito(
                            materia: materiaScelta!,
                            descrizione: descrizioneController.text.trim(),
                            dataConsegna: dataScelta,
                            tipo: tipoScelto,
                          ),
                        );
                      }
                      widget.compiti.sort(
                        (a, b) => a.dataConsegna.compareTo(b.dataConsegna),
                      );
                    });
                    widget.onUpdate();
                    Navigator.pop(context);
                  },
                  child: Text(isModifica ? 'Salva modifiche' : 'Aggiungi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _eliminaCompito(int index) {
    setState(() => widget.compiti.removeAt(index));
    widget.onUpdate();
  }

  Color _colorePerTipo(TipoCompito tipo) {
    switch (tipo) {
      case TipoCompito.compito:
        return Colors.blue;
      case TipoCompito.verifica:
        return Colors.red;
      case TipoCompito.interrogazione:
        return Colors.orange;
    }
  }

  IconData _iconaPerTipo(TipoCompito tipo) {
    switch (tipo) {
      case TipoCompito.compito:
        return Icons.assignment;
      case TipoCompito.verifica:
        return Icons.edit_document;
      case TipoCompito.interrogazione:
        return Icons.record_voice_over;
    }
  }

  String _labelPerTipo(TipoCompito tipo) {
    switch (tipo) {
      case TipoCompito.compito:
        return 'Compito';
      case TipoCompito.verifica:
        return 'Verifica';
      case TipoCompito.interrogazione:
        return 'Interrogazione';
    }
  }

  String _formatData(DateTime data) {
    final oggi = DateTime.now();
    final domani = DateTime.now().add(const Duration(days: 1));
    if (data.day == oggi.day && data.month == oggi.month) return 'Oggi';
    if (data.day == domani.day && data.month == domani.month) return 'Domani';
    return '${data.day}/${data.month}/${data.year}';
  }

  bool _isScaduto(DateTime data) {
    final oggi = DateTime.now();
    return data.isBefore(DateTime(oggi.year, oggi.month, oggi.day));
  }

  Widget _buildCard(Compito compito, int index) {
    final colore = _colorePerTipo(compito.tipo);
    final scaduto = _isScaduto(compito.dataConsegna);

    return Dismissible(
      key: Key('${compito.materia}_${compito.dataConsegna}_$index'),
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
        _eliminaCompito(index);
        return false;
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: scaduto
              ? Colors.red.withOpacity(0.05)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: scaduto
                ? Colors.red.withOpacity(0.3)
                : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            GestureDetector(
              onTap: () {
                setState(() => compito.completato = !compito.completato);
                widget.onUpdate();
              },
              child: compito.completato
                  ? const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 26,
                    )
                  : Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: colore, width: 2),
                      ),
                    ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _iconaPerTipo(compito.tipo),
                        size: 14,
                        color: colore,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _labelPerTipo(compito.tipo),
                        style: TextStyle(fontSize: 12, color: colore),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        compito.materia,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    compito.descrizione,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      decoration: compito.completato
                          ? TextDecoration.lineThrough
                          : null,
                      color: compito.completato ? Colors.white38 : Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Data + bottone modifica
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatData(compito.dataConsegna),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: scaduto ? Colors.red : Colors.white54,
                  ),
                ),
                if (scaduto && !compito.completato)
                  const Text(
                    'Scaduto',
                    style: TextStyle(fontSize: 11, color: Colors.red),
                  ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => _modificaCompito(compito),
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final compitiAttivi = widget.compiti.where((c) => !c.completato).toList();
    final compitiCompletati = widget.compiti
        .where((c) => c.completato)
        .toList();

    return Scaffold(
      body: widget.compiti.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 80,
                    color: Colors.white24,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Nessun compito',
                    style: TextStyle(fontSize: 20, color: Colors.white38),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tocca + per aggiungerne uno',
                    style: TextStyle(color: Colors.white24),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (compitiAttivi.isNotEmpty) ...[
                  const Text(
                    'Da fare',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...compitiAttivi.map(
                    (c) => _buildCard(c, widget.compiti.indexOf(c)),
                  ),
                ],
                if (compitiCompletati.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Completati',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white38,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...compitiCompletati.map(
                    (c) => _buildCard(c, widget.compiti.indexOf(c)),
                  ),
                ],
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _aggiungiCompito,
        child: const Icon(Icons.add),
      ),
    );
  }
}
