import 'package:url_launcher/url_launcher.dart';

const String imgAssetsDir = 'assets/cooked/images';

void goToDefinition(String word) async {
  word = word.replaceAll('\u0301', '');
  final Uri url = Uri.parse('https://verbum.by/?q=$word');
  if (!await launchUrl(url)) {
    throw Exception("Could not launch $url");
  }
}
