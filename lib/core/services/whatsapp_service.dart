import 'package:url_launcher/url_launcher.dart';

class WhatsAppService {
  static Future<bool> sendAbsenteeAlert({
    required String phoneNumber,
    required String studentName,
    String? date,
  }) async {
    String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleanPhone.startsWith('03')) {
      cleanPhone = '92${cleanPhone.substring(1)}';
    } else if (cleanPhone.startsWith('+')) {
      cleanPhone = cleanPhone.substring(1);
    }

    final String message = 
        "محترم والدین!\n"
        "السلام علیکم، آپ کا بچہ *$studentName* آج مدرسے سے غیر حاضر ہے۔ برائے مہربانی غیر حاضری کی وجہ سے مطلع فرمائیں۔شکریہ!\n\n"
        "انتظامیہ\n"
        "Al Mukhtar Islamic Institute";

    final Uri url = Uri.parse("https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}");

    try {
      if (await canLaunchUrl(url)) {
        return await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        return await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      return false;
    }
  }
}
