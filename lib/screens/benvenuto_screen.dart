import 'package:flutter/material.dart';

class BenvenutoScreen extends StatefulWidget {
  final Function(String) onCompletato;

  const BenvenutoScreen({super.key, required this.onCompletato});

  @override
  State<BenvenutoScreen> createState() => _BenvenutoScreenState();
}

class _BenvenutoScreenState extends State<BenvenutoScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nomeController = TextEditingController();
  int _paginaCorrente = 0;

  final List<Map<String, dynamic>> _pagine = [
    {
      'icon': Icons.school,
      'color': Colors.blue,
      'titolo': 'Benvenuto nel tuo Registro!',
      'descrizione':
          'Tieni traccia dei tuoi voti, del tuo orario scolastico e dei tuoi compiti in un unico posto.',
    },
    {
      'icon': Icons.grade,
      'color': Colors.green,
      'titolo': 'Voti e Medie',
      'descrizione':
          'Inserisci i tuoi voti per materia e periodo. Il registro calcola automaticamente le medie e ti mostra l\'andamento nel tempo con un grafico.',
    },
    {
      'icon': Icons.schedule,
      'color': Colors.purple,
      'titolo': 'Orario Scolastico',
      'descrizione':
          'Configura il tuo orario settimanale. Ogni giorno vedrai le tue lezioni in modo chiaro, con i blocchi di ore consecutive uniti automaticamente.',
    },
    {
      'icon': Icons.assignment,
      'color': Colors.orange,
      'titolo': 'Agenda',
      'descrizione':
          'Aggiungi compiti, verifiche e interrogazioni. Riceverai una notifica il giorno prima e il giorno stesso per non dimenticare nulla.',
    },
    {
      'icon': Icons.person,
      'color': Colors.pink,
      'titolo': 'Come ti chiami?',
      'descrizione': 'Inserisci il tuo nome per personalizzare il registro.',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nomeController.dispose();
    super.dispose();
  }

  void _avanti() {
    if (_paginaCorrente < _pagine.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completa();
    }
  }

  void _completa() {
    final nome = _nomeController.text.trim();
    if (nome.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Inserisci il tuo nome!')));
      return;
    }
    widget.onCompletato(nome);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Page indicators shown at the top to show current page.
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pagine.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _paginaCorrente == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _paginaCorrente == index
                          ? Colors.blue
                          : Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

            // Pages displayed in a PageView for the welcome flow.
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) =>
                    setState(() => _paginaCorrente = index),
                itemCount: _pagine.length,
                itemBuilder: (context, index) {
                  final pagina = _pagine[index];
                  final colore = pagina['color'] as Color;
                  final isUltima = index == _pagine.length - 1;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon shown inside a circular background.
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: colore.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colore.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            pagina['icon'] as IconData,
                            size: 60,
                            color: colore,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Title text for the page.
                        Text(
                          pagina['titolo'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Description text explaining the feature.
                        Text(
                          pagina['descrizione'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white54,
                            height: 1.5,
                          ),
                        ),

                        // Name input field shown only on the last page.
                        if (isUltima) ...[
                          const SizedBox(height: 40),
                          TextField(
                            controller: _nomeController,
                            autofocus: false,
                            textCapitalization: TextCapitalization.words,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 18),
                            decoration: InputDecoration(
                              hintText: 'Il tuo nome',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                            ),
                            onSubmitted: (_) => _completa(),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),

            // Navigation buttons at the bottom: back and next/start.
            Padding(
              padding: const EdgeInsets.all(32),
              child: Row(
                children: [
                  // Back button shown when not on the first page.
                  if (_paginaCorrente > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Text('Indietro'),
                      ),
                    ),
                  if (_paginaCorrente > 0) const SizedBox(width: 12),

                  // Next or Start button that advances pages or completes the flow.
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _avanti,
                      child: Text(
                        _paginaCorrente == _pagine.length - 1
                            ? 'Inizia! '
                            : 'Avanti',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
