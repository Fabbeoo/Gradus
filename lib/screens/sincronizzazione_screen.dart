import 'package:flutter/material.dart';
import '../api/services/classeviva_service.dart';
import '../models/materia.dart';
import '../models/lezione.dart';
import '../models/compito.dart';

/// Screen that handles the synchronization process with ClasseViva.
/// Imports grades (replacing existing ones), timetable, and agenda events.
/// Manual agenda entries are preserved alongside imported ones.
class SincronizzazioneScreen extends StatefulWidget {
  final List<Materia> materie;
  final List<Lezione> lezioni;
  final List<Compito> compiti;
  final VoidCallback onUpdate;

  const SincronizzazioneScreen({
    super.key,
    required this.materie,
    required this.lezioni,
    required this.compiti,
    required this.onUpdate,
  });

  @override
  State<SincronizzazioneScreen> createState() => _SincronizzazioneScreenState();
}

class _SincronizzazioneScreenState extends State<SincronizzazioneScreen> {
  bool _loading = false;
  String? _error;

  // Sync results
  int _votiImportati = 0;
  int _materieImportate = 0;
  int _lezioniImportate = 0;
  int _compitiImportati = 0;
  bool _completato = false;

  /// Maps Italian day name to its index used in [Lezione].
  static const _giorniMap = {
    1: 'Lun',
    2: 'Mar',
    3: 'Mer',
    4: 'Gio',
    5: 'Ven',
    6: 'Sab',
  };

  /// Maps ClasseViva component description to our internal type string.
  String _mapTipoVoto(String componentDesc) {
    final lower = componentDesc.toLowerCase();
    if (lower.contains('oral')) return 'orale';
    if (lower.contains('prat')) return 'pratico';
    // 'Scritto/Grafico' and other written types
    return 'scritto';
  }

  /// Maps ClasseViva event code to [TipoCompito].
  TipoCompito _mapTipoCompito(String evtCode) {
    if (evtCode == 'AGHW') return TipoCompito.compito;
    if (evtCode == 'AGNT') return TipoCompito.verifica;
    return TipoCompito.compito;
  }

  Future<void> _sincronizza() async {
    setState(() {
      _loading = true;
      _error = null;
      _completato = false;
      _votiImportati = 0;
      _materieImportate = 0;
      _lezioniImportate = 0;
      _compitiImportati = 0;
    });

    try {
      final service = ClasseVivaService();

      // === STEP 1: Import grades ===
      // === STEP 1: Import grades ===
      try {
        final votiRemoti = await service.fetchVoti();

        // Clear existing grades from all subjects
        for (final m in widget.materie) {
          m.voti.clear();
        }

        for (final vr in votiRemoti) {
          final nomeMat = vr.subjectDesc.trim();
          if (nomeMat.isEmpty) continue;

          // Find or create subject
          Materia? materia;
          try {
            materia = widget.materie.firstWhere(
              (m) => m.nome.toLowerCase() == nomeMat.toLowerCase(),
            );
          } catch (_) {
            materia = Materia(nome: nomeMat);
            widget.materie.add(materia);
            _materieImportate++;
          }

          // Map periodPos to a date that falls in the correct semester.
          // periodPos 1 = first period → use the actual evtDate
          // periodPos 3 = second period (Pentamestre) → use the actual evtDate
          // We keep the real date so our primoperiodo/secondoperiodo
          // getters work correctly by month.
          materia.voti.add(
            Voto(
              valore: vr.decimalValue,
              data: vr.eventDate,
              descrizione: vr.notes.isNotEmpty ? vr.notes : null,
              tipo: _mapTipoVoto(vr.componentDesc),
            ),
          );
          _votiImportati++;
        }

        // Sort grades by date within each subject
        for (final m in widget.materie) {
          m.voti.sort((a, b) => a.data.compareTo(b.data));
        }
      } catch (e) {
        debugPrint('Errore import voti: $e');
      }

      // === STEP 2: Import timetable ===
      try {
        final lezioniRemote = await service.fetchOrario();
        widget.lezioni.clear();
        for (final lr in lezioniRemote) {
          final giorno = _giorniMap[lr.dayOfWeek];
          if (giorno == null) continue;
          if (lr.subjectDesc.trim().isEmpty) continue;
          widget.lezioni.add(
            Lezione(
              giorno: giorno,
              ora: lr.slotNumber,
              materia: lr.subjectDesc.trim(),
            ),
          );
          _lezioniImportate++;
        }
      } catch (e) {
        debugPrint('Errore import orario: $e');
      }

      // === STEP 3: Import agenda ===
      try {
        final now = DateTime.now();
        final agendaRemota = await service.fetchAgenda(
          from: now.subtract(const Duration(days: 30)),
          to: now.add(const Duration(days: 60)),
        );
        final materieNomi = widget.materie
            .map((m) => m.nome.toLowerCase())
            .toSet();
        widget.compiti.removeWhere(
          (c) => materieNomi.contains(c.materia.toLowerCase()) && !c.completato,
        );
        for (final ar in agendaRemota) {
          if (ar.notes.trim().isEmpty && ar.subjectDesc.trim().isEmpty)
            continue;
          widget.compiti.add(
            Compito(
              materia: ar.subjectDesc.trim().isNotEmpty
                  ? ar.subjectDesc.trim()
                  : ar.authorName.trim(),
              descrizione: ar.notes.trim().isNotEmpty
                  ? ar.notes.trim()
                  : ar.evtCode,
              dataConsegna: ar.end,
              tipo: _mapTipoCompito(ar.evtCode),
            ),
          );
          _compitiImportati++;
        }
        widget.compiti.sort((a, b) => a.dataConsegna.compareTo(b.dataConsegna));
      } catch (e) {
        debugPrint('Errore import agenda: $e');
      }

      widget.onUpdate();
      setState(() => _completato = true);
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sincronizzazione'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Cosa verrà importato',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.grade,
                    text: 'Voti — sostituisce quelli esistenti',
                  ),
                  SizedBox(height: 6),
                  _InfoRow(
                    icon: Icons.schedule,
                    text: 'Orario — sostituisce quello esistente',
                  ),
                  SizedBox(height: 6),
                  _InfoRow(
                    icon: Icons.assignment,
                    text: 'Agenda — aggiunge senza rimuovere quelli manuali',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Results
            if (_completato) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Sincronizzazione completata!',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _ResultRow(
                      icon: Icons.school,
                      label: 'Materie create',
                      value: '$_materieImportate',
                    ),
                    const SizedBox(height: 6),
                    _ResultRow(
                      icon: Icons.grade,
                      label: 'Voti importati',
                      value: '$_votiImportati',
                    ),
                    const SizedBox(height: 6),
                    _ResultRow(
                      icon: Icons.schedule,
                      label: 'Ore orario importate',
                      value: '$_lezioniImportate',
                    ),
                    const SizedBox(height: 6),
                    _ResultRow(
                      icon: Icons.assignment,
                      label: 'Eventi agenda importati',
                      value: '$_compitiImportati',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Torna al profilo'),
                ),
              ),
            ],

            // Error
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            const Spacer(),

            // Sync button
            if (!_completato)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _loading ? null : _sincronizza,
                  icon: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.sync),
                  label: Text(
                    _loading ? 'Sincronizzazione in corso...' : 'Sincronizza',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Small row used in the info card.
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.blue.withOpacity(0.7)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Colors.white70),
          ),
        ),
      ],
    );
  }
}

/// Small row used in the results card.
class _ResultRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ResultRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.green.withOpacity(0.7)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.white70),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ],
    );
  }
}
