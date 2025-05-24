import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:share_photoframe_controller/pages/home.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  runApp(const SharePhotoframeController());
}

class SharePhotoframeController extends StatelessWidget {
  const SharePhotoframeController({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}