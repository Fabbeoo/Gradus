import 'package:flutter/material.dart';
import '../models/materia.dart';
import '../models/lezione.dart';
import '../models/compito.dart';
import '../api/services/classeviva_service.dart';
import 'classeviva_login_screen.dart';
import 'sincronizzazione_screen.dart';

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
  bool _cvLoggedIn = false;
  String? _cvNome;

  @override
  void initState() {
    super.initState();
    _checkClasseViva();
  }

  Future<void> _checkClasseViva() async {
    final loggedIn = await ClasseVivaService().isLoggedIn();
    final nome = await ClasseVivaService().getNomeStudente();
    setState(() {
      _cvLoggedIn = loggedIn;
      _cvNome = nome;
    });
  }

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
        // Avatar and name
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

        // Statistics
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

        // ClasseViva section
        const Text(
          'ClasseViva',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white54,
          ),
        ),
        const SizedBox(height: 12),

        _cvLoggedIn
            ? Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Connesso a ClasseViva',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              if (_cvNome != null)
                                Text(
                                  _cvNome!,
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
                  const SizedBox(height: 8),
                  _exportTile(
                    icon: Icons.sync,
                    label: 'Sincronizza ora',
                    sublabel: 'Importa voti, orario e agenda da ClasseViva',
                    colore: Colors.blue,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SincronizzazioneScreen(
                            materie: widget.materie,
                            lezioni: widget.lezioni,
                            compiti: widget.compiti,
                            onUpdate: widget.onUpdate,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _exportTile(
                    icon: Icons.logout,
                    label: 'Disconnetti ClasseViva',
                    sublabel: 'Rimuovi le credenziali salvate',
                    colore: Colors.red,
                    onTap: () async {
                      await ClasseVivaService().logout();
                      _checkClasseViva();
                    },
                  ),
                ],
              )
            : _exportTile(
                icon: Icons.login,
                label: 'Accedi a ClasseViva',
                sublabel: 'Importa voti, orario e agenda automaticamente',
                colore: Colors.blue,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ClasseVivaLoginScreen(
                        onLoginSuccess: () {
                          Navigator.pop(context);
                          _checkClasseViva();
                        },
                      ),
                    ),
                  );
                },
              ),

        const SizedBox(height: 28),

        // Data management
        const Text(
          'Gestione dati',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white54,
          ),
        ),
        const SizedBox(height: 12),

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
            'Gradus v1.0',
            style: TextStyle(fontSize: 12, color: Colors.white24),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

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
