// Opens the packaged CV on platforms that do not support browser downloads.
import 'package:url_launcher/url_launcher.dart';

Future<void> downloadCv() => launchUrl(
  Uri.base.resolve('assets/assets/documents/Abdelrahman_Osama_CV.pdf'),
  mode: LaunchMode.externalApplication,
);
