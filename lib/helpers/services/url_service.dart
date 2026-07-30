import 'package:url_launcher/url_launcher.dart';

class UrlService {
  static Future<void> goToUrl(String url) async {
    await launchUrl(Uri.parse(url));
  }

  static void goToPagger() {
    goToUrl('https://getappui.com/pagger');
  }

  static String getCurrentUrl() {
    var path = Uri.base.path;
    return path.replaceAll('flowkit/web/', '');
  }
}
