import 'package:flutter/material.dart';
import '../models/compito.dart';
import '../models/materia.dart';

/// Screen that shows the agenda with subjects and tasks.
/// Allows adding, editing, completing, and deleting tasks.
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
  void _aggiungiCompito() => _apriForm();
  void _modificaCompito(Compito compito) => _apriForm(compito: compito);

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

              // Type dropdown with all four types
              DropdownButtonFormField<TipoCompito>(
                value: tipoScelto,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Tipo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: [
                  DropdownMenuItem(
                    value: TipoCompito.compito,
                    child: Row(
                      children: [
                        Icon(Icons.assignment, size: 18, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text('Compito'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: TipoCompito.verifica,
                    child: Row(
                      children: [
                        Icon(Icons.edit_document, size: 18, color: Colors.red),
                        const SizedBox(width: 8),
                        const Text('Verifica'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: TipoCompito.interrogazione,
                    child: Row(
                      children: [
                        Icon(
                          Icons.record_voice_over,
                          size: 18,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        const Text('Interrogazione'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: TipoCompito.comunicazione,
                    child: Row(
                      children: [
                        Icon(
                          Icons.campaign_outlined,
                          size: 18,
                          color: Colors.teal,
                        ),
                        const SizedBox(width: 8),
                        const Text('Comunicazione'),
                      ],
                    ),
                  ),
                ],
                onChanged: (val) => setModalState(
                  () => tipoScelto = val ?? TipoCompito.compito,
                ),
              ),
              const SizedBox(height: 12),

              // Subject dropdown
              DropdownButtonFormField<String>(
                value: materiaScelta,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Materia',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: widget.materie
                    .map(
                      (m) => DropdownMenuItem(
                        value: m.nome,
                        child: Text(m.nome, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setModalState(() => materiaScelta = val),
              ),
              const SizedBox(height: 12),

              // Description field
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

              // Date picker
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
      case TipoCompito.comunicazione:
        return Colors.teal;
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
      case TipoCompito.comunicazione:
        return Icons.campaign_outlined;
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
      case TipoCompito.comunicazione:
        return 'Comunicazione';
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

  /// Opens a detail bottom sheet for the selected task.
  void _apriDettaglio(Compito compito) {
    final colore = _colorePerTipo(compito.tipo);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Type badge + complete button
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colore.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colore.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _iconaPerTipo(compito.tipo),
                        size: 14,
                        color: colore,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _labelPerTipo(compito.tipo),
                        style: TextStyle(
                          fontSize: 13,
                          color: colore,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    setState(() => compito.completato = !compito.completato);
                    widget.onUpdate();
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: compito.completato
                          ? Colors.green.withOpacity(0.15)
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: compito.completato
                            ? Colors.green.withOpacity(0.4)
                            : Colors.white24,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          compito.completato
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          size: 14,
                          color: compito.completato
                              ? Colors.green
                              : Colors.white54,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          compito.completato ? 'Completato' : 'Da fare',
                          style: TextStyle(
                            fontSize: 13,
                            color: compito.completato
                                ? Colors.green
                                : Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Subject
            Text(
              compito.materia,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            // Teacher name
            if (compito.autore.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                compito.autore,
                style: const TextStyle(fontSize: 14, color: Colors.white54),
              ),
            ],

            const SizedBox(height: 20),

            // Date
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: Colors.white54,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${compito.dataConsegna.day}/${compito.dataConsegna.month}/${compito.dataConsegna.year}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatData(compito.dataConsegna),
                    style: const TextStyle(fontSize: 13, color: Colors.white54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Description
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Text(
                compito.descrizione,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Edit / Delete buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _modificaCompito(compito);
                    },
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Modifica'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final index = widget.compiti.indexOf(compito);
                      Navigator.pop(context);
                      _eliminaCompito(index);
                    },
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Elimina'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
      child: GestureDetector(
        onTap: () => _apriDettaglio(compito),
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
            crossAxisAlignment: CrossAxisAlignment.center,
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

              // Info: teacher/subject + description
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
                        Flexible(
                          child: Text(
                            // Show teacher if available and different from subject,
                            // otherwise show subject name
                            compito.autore.isNotEmpty &&
                                    compito.autore.toLowerCase() !=
                                        compito.materia.toLowerCase()
                                ? '${compito.autore} · ${compito.materia}'
                                : compito.autore.isNotEmpty
                                ? compito.autore
                                : compito.materia,
                            style: TextStyle(fontSize: 12, color: colore),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                        color: compito.completato
                            ? Colors.white38
                            : Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Date column
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ora = DateTime.now();
    final oggi = DateTime(ora.year, ora.month, ora.day);

    final compitiAttivi = widget.compiti
        .where((c) => !c.completato && !c.dataConsegna.isBefore(oggi))
        .toList();

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
                    'Nessun elemento',
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
