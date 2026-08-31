// Downloads the packaged CV through a browser anchor on Flutter Web.
import 'dart:html' as html;

Future<void> downloadCv() {
  final url = Uri.base
      .resolve('assets/assets/documents/Abdelrahman_Osama_CV.pdf')
      .toString();
  html.AnchorElement(href: url)
    ..download = 'Abdelrahman_Osama_CV.pdf'
    ..click();
  return Future.value();
}
