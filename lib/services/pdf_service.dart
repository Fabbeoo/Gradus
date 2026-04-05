import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/materia.dart';
import '../models/lezione.dart';

class PdfService {
  static final PdfService _instance = PdfService._();
  factory PdfService() => _instance;
  PdfService._();

  // Esporta i voti come PDF
  Future<void> esportaVoti(List<Materia> materie, String nomeStudente) async {
    final pdf = pw.Document();

    final periodoCorrente = Materia.periodoCorrente();
    final nomePeriodo = periodoCorrente == 0 ? '1° Periodo' : '2° Periodo';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue800,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Registro Voti — $nomeStudente',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  '$nomePeriodo — ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                  style: const pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.white,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 24),

          // Media generale
          _buildMediaGeneralePdf(materie, periodoCorrente),
          pw.SizedBox(height: 24),

          // Tabella per ogni materia
          ...materie.map((materia) {
            final voti = periodoCorrente == 0
                ? materia.primoperiodo
                : materia.secondoperiodo;
            if (voti.isEmpty) return pw.SizedBox();
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeaderMateria(materia, voti),
                pw.SizedBox(height: 8),
                _buildTabellaVoti(voti),
                pw.SizedBox(height: 20),
              ],
            );
          }),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'Voti_${nomeStudente}_$nomePeriodo.pdf',
    );
  }

  pw.Widget _buildMediaGeneralePdf(List<Materia> materie, int periodoCorrente) {
    final materieConVoti = materie.where((m) {
      final voti = periodoCorrente == 0 ? m.primoperiodo : m.secondoperiodo;
      return voti.isNotEmpty;
    }).toList();

    if (materieConVoti.isEmpty) return pw.SizedBox();

    final mediaGen =
        materieConVoti
            .map((m) {
              final voti = periodoCorrente == 0
                  ? m.primoperiodo
                  : m.secondoperiodo;
              return voti.map((v) => v.valore).reduce((a, b) => a + b) /
                  voti.length;
            })
            .reduce((a, b) => a + b) /
        materieConVoti.length;

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Media Generale',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            mediaGen.toStringAsFixed(2),
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: mediaGen >= 7
                  ? PdfColors.green700
                  : mediaGen >= 6
                  ? PdfColors.orange700
                  : PdfColors.red700,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildHeaderMateria(Materia materia, List<Voto> voti) {
    final media =
        voti.map((v) => v.valore).reduce((a, b) => a + b) / voti.length;
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: PdfColors.blue200),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                materia.nome,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              if (materia.professore != null)
                pw.Text(
                  materia.professore!,
                  style: const pw.TextStyle(
                    fontSize: 11,
                    color: PdfColors.grey600,
                  ),
                ),
            ],
          ),
          pw.Row(
            children: [
              pw.Text('Media: ', style: const pw.TextStyle(fontSize: 12)),
              pw.Text(
                media.toStringAsFixed(2),
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: media >= 7
                      ? PdfColors.green700
                      : media >= 6
                      ? PdfColors.orange700
                      : PdfColors.red700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTabellaVoti(List<Voto> voti) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(3),
      },
      children: [
        // Header tabella
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _cellaTabellaHeader('Voto'),
            _cellaTabellaHeader('Data'),
            _cellaTabellaHeader('Tipo'),
            _cellaTabellaHeader('Descrizione'),
          ],
        ),
        // Righe voti
        ...voti.map(
          (voto) => pw.TableRow(
            children: [
              _cellaTabella(
                _labelVoto(voto.valore),
                colore: voto.valore >= 7
                    ? PdfColors.green700
                    : voto.valore >= 6
                    ? PdfColors.orange700
                    : PdfColors.red700,
                bold: true,
              ),
              _cellaTabella(
                '${voto.data.day}/${voto.data.month}/${voto.data.year}',
              ),
              _cellaTabella(voto.tipo),
              _cellaTabella(voto.descrizione ?? '—'),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _cellaTabellaHeader(String testo) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        testo,
        style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  pw.Widget _cellaTabella(String testo, {PdfColor? colore, bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        testo,
        style: pw.TextStyle(
          fontSize: 11,
          color: colore,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  // Esporta l'orario come PDF
  Future<void> esportaOrario(List<Lezione> lezioni, String nomeStudente) async {
    final pdf = pw.Document();
    final giorni = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab'];
    final orePerGiorno = 8;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue800,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Orario Scolastico — $nomeStudente',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.Text(
                    '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                    style: const pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.white,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // Tabella orario
            pw.Expanded(
              child: pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FixedColumnWidth(30),
                  for (int i = 1; i <= giorni.length; i++)
                    i: const pw.FlexColumnWidth(1),
                },
                children: [
                  // Header giorni
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.blue800,
                    ),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          '',
                          style: const pw.TextStyle(color: PdfColors.white),
                        ),
                      ),
                      ...giorni.map(
                        (g) => pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            g,
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Righe ore
                  ...List.generate(orePerGiorno, (oraIndex) {
                    final ora = oraIndex + 1;
                    return pw.TableRow(
                      decoration: oraIndex % 2 == 0
                          ? const pw.BoxDecoration(color: PdfColors.grey50)
                          : null,
                      children: [
                        // Numero ora
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            '$ora°',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.grey600,
                            ),
                          ),
                        ),
                        // Celle materie
                        ...giorni.map((giorno) {
                          final lezione = lezioni.firstWhere(
                            (l) => l.giorno == giorno && l.ora == ora,
                            orElse: () =>
                                Lezione(giorno: giorno, ora: ora, materia: ''),
                          );
                          final hasLezione = lezione.materia.isNotEmpty;
                          return pw.Container(
                            padding: const pw.EdgeInsets.all(6),
                            color: hasLezione
                                ? PdfColors.blue50
                                : PdfColors.white,
                            child: pw.Text(
                              hasLezione ? lezione.materia : '',
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: hasLezione
                                    ? pw.FontWeight.bold
                                    : pw.FontWeight.normal,
                                color: hasLezione
                                    ? PdfColors.blue800
                                    : PdfColors.white,
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
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'Orario_$nomeStudente.pdf',
    );
  }

  String _labelVoto(double valore) {
    final votiMap = {
      1.00: '1',
      1.25: '1+',
      1.50: '1½',
      1.75: '2-',
      2.00: '2',
      2.25: '2+',
      2.50: '2½',
      2.75: '3-',
      3.00: '3',
      3.25: '3+',
      3.50: '3½',
      3.75: '4-',
      4.00: '4',
      4.25: '4+',
      4.50: '4½',
      4.75: '5-',
      5.00: '5',
      5.25: '5+',
      5.50: '5½',
      5.75: '6-',
      6.00: '6',
      6.25: '6+',
      6.50: '6½',
      6.75: '7-',
      7.00: '7',
      7.25: '7+',
      7.50: '7½',
      7.75: '8-',
      8.00: '8',
      8.25: '8+',
      8.50: '8½',
      8.75: '9-',
      9.00: '9',
      9.25: '9+',
      9.50: '9½',
      9.75: '10-',
      10.00: '10',
    };
    return votiMap[valore] ?? valore.toString();
  }
}
