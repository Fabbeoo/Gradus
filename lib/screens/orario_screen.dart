import 'package:flutter/material.dart';
import '../models/lezione.dart';
import '../models/materia.dart';

class OrarioScreen extends StatefulWidget {
  final List<Materia> materie;
  final List<Lezione> lezioni;
  final VoidCallback onUpdate;

  const OrarioScreen({
    super.key,
    required this.materie,
    required this.lezioni,
    required this.onUpdate,
  });

  @override
  State<OrarioScreen> createState() => _OrarioScreenState();
}

class _OrarioScreenState extends State<OrarioScreen> {
  final List<String> _giorni = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab'];
  final int _orePerGiorno = 8;
  bool _mostraCompleto = false;
  late String _giornoVisualizzato;
  final double _altezzaOra = 72;

  final List<Color> _coloriDisponibili = [
    Colors.blue,
    Colors.purple,
    Colors.teal,
    Colors.indigo,
    Colors.cyan,
    Colors.green,
    Colors.orange,
    Colors.pink,
    Colors.red,
    Colors.amber,
    Colors.lime,
    Colors.deepOrange,
  ];

  @override
  void initState() {
    super.initState();
    _giornoVisualizzato = _giornoCorrente;
  }

  String get _giornoCorrente {
    final now = DateTime.now();
    int weekday = now.weekday;
    if (now.hour >= 17) weekday++;
    if (weekday > 6) weekday = 1;
    if (weekday == 7) weekday = 1;
    final index = (weekday - 1).clamp(0, 5);
    return _giorni[index];
  }

  String _nomeGiornoCompleto(String giorno) {
    switch (giorno) {
      case 'Lun':
        return 'Lunedì';
      case 'Mar':
        return 'Martedì';
      case 'Mer':
        return 'Mercoledì';
      case 'Gio':
        return 'Giovedì';
      case 'Ven':
        return 'Venerdì';
      case 'Sab':
        return 'Sabato';
      default:
        return giorno;
    }
  }

  Lezione? _lezionePerSlot(String giorno, int ora) {
    try {
      return widget.lezioni.firstWhere(
        (l) => l.giorno == giorno && l.ora == ora,
      );
    } catch (_) {
      return null;
    }
  }

  // Raggruppa le ore del giorno in blocchi consecutivi della stessa materia
  List<Map<String, dynamic>> _raggruppaOre(String giorno) {
    final blocchi = <Map<String, dynamic>>[];
    int i = 1;
    while (i <= _orePerGiorno) {
      final lezione = _lezionePerSlot(giorno, i);
      if (lezione == null) {
        blocchi.add({'ora': i, 'durata': 1, 'lezione': null});
        i++;
      } else {
        int durata = 1;
        while (i + durata <= _orePerGiorno) {
          final prossima = _lezionePerSlot(giorno, i + durata);
          if (prossima != null && prossima.materia == lezione.materia) {
            durata++;
          } else {
            break;
          }
        }
        blocchi.add({'ora': i, 'durata': durata, 'lezione': lezione});
        i += durata;
      }
    }
    return blocchi;
  }

  void _modificaSlot(String giorno, int ora) {
    if (widget.materie.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aggiungi prima una materia!')),
      );
      return;
    }

    final lezioneEsistente = _lezionePerSlot(giorno, ora);
    String? materiaScelta = lezioneEsistente?.materia;
    final aulaController = TextEditingController(
      text: lezioneEsistente?.aula ?? '',
    );
    int oreConsecutive = 1;
    Color coloreSelezionato =
        lezioneEsistente?.colore ?? _coloriDisponibili.first;

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
                '$giorno — Ora $ora',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: materiaScelta,
                hint: const Text('Seleziona materia'),
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
              TextField(
                controller: aulaController,
                decoration: InputDecoration(
                  labelText: 'Aula (opzionale)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Selettore colore
              const Text('Colore:', style: TextStyle(fontSize: 15)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _coloriDisponibili.map((colore) {
                  final selezionato = colore.value == coloreSelezionato.value;
                  return GestureDetector(
                    onTap: () =>
                        setModalState(() => coloreSelezionato = colore),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colore,
                        shape: BoxShape.circle,
                        border: selezionato
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: selezionato
                            ? [
                                BoxShadow(
                                  color: colore.withOpacity(0.6),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: selezionato
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Ore consecutive
              Row(
                children: [
                  const Text(
                    'Ore consecutive:',
                    style: TextStyle(fontSize: 15),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: oreConsecutive > 1
                        ? () => setModalState(() => oreConsecutive--)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text(
                    '$oreConsecutive',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: (ora + oreConsecutive - 1) < _orePerGiorno
                        ? () => setModalState(() => oreConsecutive++)
                        : null,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  if (lezioneEsistente != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            // Rimuovi tutte le ore di questo blocco
                            final blocchi = _raggruppaOre(giorno);
                            final blocco = blocchi.firstWhere(
                              (b) =>
                                  b['ora'] == ora ||
                                  (b['lezione'] != null &&
                                      b['lezione'].materia ==
                                          lezioneEsistente.materia &&
                                      b['ora'] <= ora &&
                                      b['ora'] + b['durata'] > ora),
                              orElse: () => {'ora': ora, 'durata': 1},
                            );
                            for (
                              int i = 0;
                              i < (blocco['durata'] as int);
                              i++
                            ) {
                              final l = _lezionePerSlot(
                                giorno,
                                (blocco['ora'] as int) + i,
                              );
                              if (l != null) widget.lezioni.remove(l);
                            }
                          });
                          widget.onUpdate();
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: const Text('Rimuovi'),
                      ),
                    ),
                  if (lezioneEsistente != null) const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        if (materiaScelta == null) return;
                        setState(() {
                          for (int i = 0; i < oreConsecutive; i++) {
                            final slotOra = ora + i;
                            final esistente = _lezionePerSlot(giorno, slotOra);
                            if (esistente != null) {
                              widget.lezioni.remove(esistente);
                            }
                          }
                          for (int i = 0; i < oreConsecutive; i++) {
                            widget.lezioni.add(
                              Lezione(
                                giorno: giorno,
                                ora: ora + i,
                                materia: materiaScelta!,
                                aula: aulaController.text.trim().isEmpty
                                    ? null
                                    : aulaController.text.trim(),
                                colore: coloreSelezionato,
                              ),
                            );
                          }
                        });
                        widget.onUpdate();
                        Navigator.pop(context);
                      },
                      child: const Text('Salva'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVistaSingola(String giorno) {
    final blocchi = _raggruppaOre(giorno);
    final haLezioni = blocchi.any((b) => b['lezione'] != null);

    return Column(
      children: [
        // Header giorno con frecce
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  final index = _giorni.indexOf(giorno);
                  if (index > 0) {
                    setState(() => _giornoVisualizzato = _giorni[index - 1]);
                  }
                },
                icon: const Icon(Icons.chevron_left),
              ),
              Column(
                children: [
                  Text(
                    _nomeGiornoCompleto(giorno),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!haLezioni)
                    const Text(
                      'Nessuna lezione',
                      style: TextStyle(fontSize: 13, color: Colors.white38),
                    ),
                ],
              ),
              IconButton(
                onPressed: () {
                  final index = _giorni.indexOf(giorno);
                  if (index < _giorni.length - 1) {
                    setState(() => _giornoVisualizzato = _giorni[index + 1]);
                  }
                },
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),

        // Lista blocchi ore
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: blocchi.length,
            itemBuilder: (context, i) {
              final blocco = blocchi[i];
              final ora = blocco['ora'] as int;
              final durata = blocco['durata'] as int;
              final lezione = blocco['lezione'] as Lezione?;
              final colore = lezione?.colore ?? Colors.white;
              final altezza = _altezzaOra * durata + (durata - 1) * 8;

              return GestureDetector(
                onTap: () => _modificaSlot(giorno, ora),
                child: Container(
                  height: altezza,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: lezione != null
                        ? colore.withOpacity(0.15)
                        : Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: lezione != null
                          ? colore.withOpacity(0.4)
                          : Colors.white.withOpacity(0.08),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Colonna numeri ora
                      SizedBox(
                        width: 30,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            durata,
                            (j) => Text(
                              '${ora + j}°',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white38,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: lezione != null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lezione.materia,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: colore,
                                    ),
                                  ),
                                  if (lezione.aula != null)
                                    Text(
                                      'Aula ${lezione.aula}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: colore.withOpacity(0.7),
                                      ),
                                    ),
                                  if (durata > 1)
                                    Text(
                                      '$durata ore',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colore.withOpacity(0.5),
                                      ),
                                    ),
                                ],
                              )
                            : const Text(
                                'Tocca per aggiungere',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white24,
                                ),
                              ),
                      ),
                      if (lezione != null)
                        Icon(
                          Icons.edit_outlined,
                          size: 16,
                          color: colore.withOpacity(0.5),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Bottone orario completo
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => setState(() => _mostraCompleto = true),
              icon: const Icon(Icons.calendar_view_week),
              label: const Text('Visualizza orario completo'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVistaCompleta() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => setState(() => _mostraCompleto = false),
              icon: const Icon(Icons.today),
              label: const Text('Torna alla vista giornaliera'),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 40),
                        ..._giorni.map(
                          (g) => Container(
                            width: 100,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            alignment: Alignment.center,
                            child: Text(
                              g,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    ...List.generate(_orePerGiorno, (oraIndex) {
                      final ora = oraIndex + 1;
                      return Row(
                        children: [
                          SizedBox(
                            width: 40,
                            child: Text(
                              '$ora°',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          ..._giorni.map((giorno) {
                            final lezione = _lezionePerSlot(giorno, ora);
                            final colore = lezione?.colore;
                            return GestureDetector(
                              onTap: () => _modificaSlot(giorno, ora),
                              child: Container(
                                width: 100,
                                height: 60,
                                margin: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: lezione != null
                                      ? colore!.withOpacity(0.2)
                                      : Colors.white.withOpacity(0.04),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: lezione != null
                                        ? colore!.withOpacity(0.5)
                                        : Colors.white.withOpacity(0.08),
                                  ),
                                ),
                                child: lezione != null
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            lezione.materia,
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: colore,
                                            ),
                                          ),
                                          if (lezione.aula != null)
                                            Text(
                                              lezione.aula!,
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: colore!.withOpacity(0.7),
                                              ),
                                            ),
                                        ],
                                      )
                                    : const Icon(
                                        Icons.add,
                                        size: 18,
                                        color: Colors.white12,
                                      ),
                              ),
                            );
                          }),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _mostraCompleto
        ? _buildVistaCompleta()
        : _buildVistaSingola(_giornoVisualizzato);
  }
}
