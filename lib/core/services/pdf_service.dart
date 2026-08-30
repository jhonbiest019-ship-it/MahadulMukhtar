import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../constants/app_strings.dart';
import '../models/student_model.dart';
import '../models/hifz_progress_model.dart';

class PdfService {
  static Future<void> printOrShareReport({
    required StudentModel student,
    required List<HifzProgressModel> history,
    required String rangeTitle,
  }) async {
    await printHifzHistoryReport(
      student: student,
      history: history,
      rangeTitle: rangeTitle,
    );
  }

  static Future<void> printHifzHistoryReport({
    required StudentModel student,
    required List<HifzProgressModel> history,
    required String rangeTitle,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          final List<List<String>> tableData = history.map((HifzProgressModel h) => [
            h.date,
            h.sabaq,
            h.sabqi,
            h.manzil,
            h.mistakes,
            h.qualityGrade,
          ]).toList();

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Banner
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(16),
                decoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFF19436E),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      AppStrings.appNameUrdu,
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.Text(
                      AppStrings.appSubTitleUrdu,
                      style: const pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // Student Info Card
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('طالب علم: ${student.name} (رول #${student.rollNo})',
                            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        pw.Text('ولدیت: ${student.fatherName}', style: const pw.TextStyle(fontSize: 11)),
                        pw.Text('واٹس ایپ نمبر: ${student.phoneNumber}', style: const pw.TextStyle(fontSize: 11)),
                      ],
                    ),
                    pw.Text('میعاد: $rangeTitle',
                        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(0xFF19436E))),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // History Table
              pw.Table.fromTextArray(
                headers: ['تاریخ', 'سبق (Sabaq)', 'سبقی (Sabqi)', 'منزل (Manzil)', 'غلطیاں', 'کیفیت'],
                data: tableData,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF19436E)),
                cellAlignment: pw.Alignment.centerLeft,
                rowDecoration: const pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200)),
                ),
              ),

              pw.Spacer(),

              // Developer Footer
              pw.Divider(),
              pw.Center(
                child: pw.Text(
                  AppStrings.developerCredit,
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromInt(0xFF19436E),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
