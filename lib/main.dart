import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/materia.dart';
import 'models/lezione.dart';
import 'models/compito.dart';
import 'screens/home_screen.dart' as home;
import 'screens/materie_screen.dart';
import 'screens/voti_screen.dart';
import 'screens/orario_screen.dart';
import 'screens/agenda_screen.dart';
import 'screens/profilo_screen.dart';
import 'screens/benvenuto_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Hive.initFlutter();

    Hive.registerAdapter(VotoAdapter());
    Hive.registerAdapter(MateriaAdapter());
    Hive.registerAdapter(LezioneAdapter());
    Hive.registerAdapter(TipoCompitoAdapter());
    Hive.registerAdapter(CompitoAdapter());

    await Hive.openBox<Materia>('materie');
    await Hive.openBox<Lezione>('lezioni');
    await Hive.openBox<Compito>('compiti');
    await Hive.openBox('impostazioni');

    await NotificationService().init();
  } catch (e) {
    debugPrint('Errore init: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const RootScreen(),
    );
  }
}

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _selectedIndex = 0;
  bool _primoAvvio = false;
  late String _nomeStudente;
  late List<Materia> _materie;
  late List<Lezione> _lezioni;
  late List<Compito> _compiti;

  late Box<Materia> _materieBox;
  late Box<Lezione> _lezioniBox;
  late Box<Compito> _compitiBox;
  late Box _impostazioniBox;

  @override
  void initState() {
    super.initState();
    _materieBox = Hive.box<Materia>('materie');
    _lezioniBox = Hive.box<Lezione>('lezioni');
    _compitiBox = Hive.box<Compito>('compiti');
    _impostazioniBox = Hive.box('impostazioni');

    _nomeStudente = _impostazioniBox.get('nome', defaultValue: '');
    _materie = _materieBox.values.toList();
    _lezioni = _lezioniBox.values.toList();
    _compiti = _compitiBox.values.toList();

    // Mostra benvenuto se il nome non è stato ancora inserito
    _primoAvvio = _nomeStudente.isEmpty;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await NotificationService().richiediPermessi();
      await NotificationService().schedulaTutteLeNotifiche(_compiti);
    });
  }

  Future<void> _salva() async {
    await _materieBox.clear();
    await _materieBox.addAll(_materie);

    await _lezioniBox.clear();
    await _lezioniBox.addAll(_lezioni);

    await _compitiBox.clear();
    await _compitiBox.addAll(_compiti);
  }

  void _onUpdate() {
    setState(() {});
    _salva();
    NotificationService().schedulaTutteLeNotifiche(_compiti);
  }

  void _salvaNome(String nome) {
    setState(() => _nomeStudente = nome);
    _impostazioniBox.put('nome', nome);
  }

  void _cancellazioneCompleta() {
    setState(() {
      _materie.clear();
      _lezioni.clear();
      _compiti.clear();
    });
    _materieBox.clear();
    _lezioniBox.clear();
    _compitiBox.clear();
    NotificationService().cancellaNotifiche();
  }

  final List<String> _titles = [
    'Home',
    'Materie',
    'Voti',
    'Orario',
    'Agenda',
    'Profilo',
  ];

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return home.HomeScreen(
          nomeStudente: _nomeStudente,
          materie: _materie,
          compiti: _compiti,
        );
      case 1:
        return MaterieScreen(materie: _materie, onUpdate: _onUpdate);
      case 2:
        return VotiScreen(materie: _materie);
      case 3:
        return OrarioScreen(
          materie: _materie,
          lezioni: _lezioni,
          onUpdate: _onUpdate,
        );
      case 4:
        return AgendaScreen(
          materie: _materie,
          compiti: _compiti,
          onUpdate: _onUpdate,
        );
      case 5:
        return ProfiloScreen(
          nomeStudente: _nomeStudente,
          materie: _materie,
          lezioni: _lezioni,
          compiti: _compiti,
          onNomeAggiornato: _salvaNome,
          onCancellazioneCompleta: _cancellazioneCompleta,
          onUpdate: _onUpdate,
        );
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_primoAvvio) {
      return BenvenutoScreen(
        onCompletato: (nome) {
          setState(() {
            _nomeStudente = nome;
            _primoAvvio = false;
          });
          _impostazioniBox.put('nome', nome);
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 230),
          child: Text(_titles[_selectedIndex], key: ValueKey(_selectedIndex)),
        ),
        centerTitle: true,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 230),
        transitionBuilder: (child, animation) {
          // Slide dal basso verso l'alto + fade
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.04),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOut),
                  ),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey(_selectedIndex),
          child: _buildScreen(_selectedIndex),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: 'Materie',
          ),
          NavigationDestination(
            icon: Icon(Icons.grade_outlined),
            selectedIcon: Icon(Icons.grade),
            label: 'Voti',
          ),
          NavigationDestination(
            icon: Icon(Icons.schedule_outlined),
            selectedIcon: Icon(Icons.schedule),
            label: 'Orario',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Agenda',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profilo',
          ),
        ],
      ),
    );
  }
}
