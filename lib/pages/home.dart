
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:share_photoframe_controller/services/photo_service.dart';
import 'package:share_photoframe_controller/widgets/base_button.dart';
import 'package:share_photoframe_controller/widgets/image_container.dart';

class Home extends StatefulWidget {
  const Home({
    super.key,
  });

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  List<String> imageUrls = [];
  bool isLoading = true;
  int urlsIndex = 0;
  PhotoService photoService = PhotoService();

  @override
  void initState() {
    super.initState();
    fetchImageUrls();
  }

  Future<void> fetchImageUrls() async {
    final accessToken = await photoService.getAccessToken();
    final folderId = dotenv.get('folder_id');
    final urls =
        await photoService.getImageUrlsFromFolder(folderId, accessToken ?? '');

    setState(() {
      imageUrls = urls;
      isLoading = false;
    });

    await _requestImage();
  }

  Future<void> _requestImage() async {
    final url = imageUrls[urlsIndex];
    photoService.requestImageUrl(url);
  }

  Future<void> _requestNextImage() async {
    if (urlsIndex < imageUrls.length) {
      setState(() {
        urlsIndex++;
      });

      final url = imageUrls[urlsIndex];
      photoService.requestImageUrl(url);
    }
  }

  Future<void> _requestPreviousImage() async {
    if (urlsIndex > 0) {
      setState(() {
        urlsIndex--;
      });

      final url = imageUrls[urlsIndex];
      photoService.requestImageUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ImageContainer(
              imagePath: 'images/home.jpg',
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BaseButton(
                        icon: Icons.power_settings_new_outlined,
                        onTap: () {
                          print(1);
                        },
                      ),
                      BaseButton(
                        icon: Icons.stop_circle_outlined,
                        onTap: () {
                          print(2);
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BaseButton(
                        icon: Icons.arrow_circle_left_outlined,
                        onTap: () async {
                          await _requestPreviousImage();
                        },
                      ),
                      BaseButton(
                        icon: Icons.arrow_circle_right_outlined,
                        onTap: () async {
                          await _requestNextImage();
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
    );
  }
}
