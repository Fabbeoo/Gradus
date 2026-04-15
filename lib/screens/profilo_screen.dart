import 'package:flutter/material.dart';
import '../models/materia.dart';
import '../models/lezione.dart';
import '../models/compito.dart';
import '../services/pdf_service.dart';

class ProfiloScreen extends StatefulWidget {
  final String nomeStudente;
  final List<Materia> materie;
  final List<Lezione> lezioni;
  final List<Compito> compiti;
  final Function(String) onNomeAggiornato;
  final VoidCallback onCancellazioneCompleta;
  final VoidCallback onUpdate;

  const ProfiloScreen({
    super.key,
    required this.nomeStudente,
    required this.materie,
    required this.lezioni,
    required this.compiti,
    required this.onNomeAggiornato,
    required this.onCancellazioneCompleta,
    required this.onUpdate,
  });

  @override
  State<ProfiloScreen> createState() => _ProfiloScreenState();
}

class _ProfiloScreenState extends State<ProfiloScreen> {
  // Open a bottom sheet to edit the student's name.
  void _modificaNome() {
    final controller = TextEditingController(text: widget.nomeStudente);
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
            const Text(
              'Modifica nome',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Nome',
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
                  if (controller.text.trim().isNotEmpty) {
                    widget.onNomeAggiornato(controller.text.trim());
                    Navigator.pop(context);
                  }
                },
                child: const Text('Salva'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Small reusable tile used for exporting data.
  Widget _exportTile({
    required IconData icon,
    required String label,
    required String sublabel,
    required Color colore,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colore.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colore.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: colore, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: colore,
                    ),
                  ),
                  Text(
                    sublabel,
                    style: const TextStyle(fontSize: 12, color: Colors.white38),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colore.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  // Show a confirmation dialog before deleting data.
  void _cancellaDati({
    required String titolo,
    required String messaggio,
    required VoidCallback onConferma,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titolo),
        content: Text(messaggio),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () {
              onConferma();
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Compute simple statistics for display.
    final totVoti = widget.materie.fold<int>(
      0,
      (sum, m) => sum + m.voti.length,
    );
    final totCompiti = widget.compiti.length;
    final totLezioni = widget.lezioni.length;
    final totMaterie = widget.materie.length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Avatar and name section with edit button.
        Center(
          child: Column(
            children: [
              const SizedBox(height: 16),
              CircleAvatar(
                radius: 48,
                backgroundColor: Colors.blue.withOpacity(0.2),
                child: Text(
                  widget.nomeStudente.isNotEmpty
                      ? widget.nomeStudente[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.nomeStudente,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: _modificaNome,
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Modifica nome'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Statistics grid showing counts for subjects, grades, tasks, and lessons.
        const Text(
          'Statistiche',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white54,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.8,
          children: [
            _statCard('Materie', '$totMaterie', Icons.school, Colors.blue),
            _statCard('Voti', '$totVoti', Icons.grade, Colors.green),
            _statCard(
              'Compiti',
              '$totCompiti',
              Icons.assignment,
              Colors.orange,
            ),
            _statCard(
              'Ore in orario',
              '$totLezioni',
              Icons.schedule,
              Colors.purple,
            ),
          ],
        ),

        const SizedBox(height: 28),

        // Export section with tiles to generate PDFs.
        const Text(
          'Esportazione',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white54,
          ),
        ),
        const SizedBox(height: 12),

        _exportTile(
          icon: Icons.picture_as_pdf,
          label: 'Esporta Voti',
          sublabel: 'Genera un PDF con tutti i tuoi voti',
          colore: Colors.blue,
          onTap: () =>
              PdfService().esportaVoti(widget.materie, widget.nomeStudente),
        ),
        const SizedBox(height: 8),
        _exportTile(
          icon: Icons.calendar_month,
          label: 'Esporta Orario',
          sublabel: 'Genera un PDF con il tuo orario settimanale',
          colore: Colors.purple,
          onTap: () =>
              PdfService().esportaOrario(widget.lezioni, widget.nomeStudente),
        ),

        // Data management section with destructive actions.
        const Text(
          'Gestione dati',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white54,
          ),
        ),
        const SizedBox(height: 12),

        // Tile to clear all grades but keep subjects.
        _dangerTile(
          icon: Icons.grade_outlined,
          label: 'Cancella tutti i voti',
          sublabel: 'Elimina i voti ma mantieni le materie',
          onTap: () => _cancellaDati(
            titolo: 'Cancella voti',
            messaggio: 'Vuoi eliminare tutti i voti? Le materie rimarranno.',
            onConferma: () {
              for (final m in widget.materie) {
                m.voti.clear();
              }
              widget.onUpdate();
            },
          ),
        ),
        const SizedBox(height: 8),
        // Tile to clear all tasks and tests.
        _dangerTile(
          icon: Icons.assignment_outlined,
          label: 'Cancella agenda',
          sublabel: 'Elimina tutti i compiti e le verifiche',
          onTap: () => _cancellaDati(
            titolo: 'Cancella agenda',
            messaggio: 'Vuoi eliminare tutti i compiti?',
            onConferma: () {
              widget.compiti.clear();
              widget.onUpdate();
            },
          ),
        ),
        const SizedBox(height: 8),
        // Tile to clear the timetable.
        _dangerTile(
          icon: Icons.schedule_outlined,
          label: 'Cancella orario',
          sublabel: 'Elimina tutto l\'orario scolastico',
          onTap: () => _cancellaDati(
            titolo: 'Cancella orario',
            messaggio: 'Vuoi eliminare tutto l\'orario?',
            onConferma: () {
              widget.lezioni.clear();
              widget.onUpdate();
            },
          ),
        ),
        const SizedBox(height: 8),
        // Tile to delete all app data with a stronger warning style.
        _dangerTile(
          icon: Icons.delete_forever_outlined,
          label: 'Cancella tutto',
          sublabel: 'Elimina tutti i dati dell\'app',
          isRed: true,
          onTap: () => _cancellaDati(
            titolo: 'Cancella tutto',
            messaggio:
                'Vuoi eliminare tutti i dati? Questa azione è irreversibile.',
            onConferma: widget.onCancellazioneCompleta,
          ),
        ),

        const SizedBox(height: 32),
        const Center(
          child: Text(
            'Registro Scolastico v1.0',
            style: TextStyle(fontSize: 12, color: Colors.white24),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // Small card widget used in the statistics grid.
  Widget _statCard(String label, String valore, IconData icon, Color colore) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colore.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colore.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: colore, size: 24),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                valore,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: colore,
                ),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.white54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Tile style for destructive actions, with optional red styling.
  Widget _dangerTile({
    required IconData icon,
    required String label,
    required String sublabel,
    required VoidCallback onTap,
    bool isRed = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isRed
              ? Colors.red.withOpacity(0.1)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isRed
                ? Colors.red.withOpacity(0.3)
                : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isRed ? Colors.red : Colors.white54, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isRed ? Colors.red : Colors.white,
                    ),
                  ),
                  Text(
                    sublabel,
                    style: const TextStyle(fontSize: 12, color: Colors.white38),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isRed ? Colors.red.withOpacity(0.5) : Colors.white24,
            ),
          ],
        ),
      ),
    );
  }
}
