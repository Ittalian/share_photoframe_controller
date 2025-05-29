import 'dart:io';

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
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  final PhotoService _photoService = PhotoService();
  List<String> _imageUrls = [];
  bool _isLoading = true;
  bool _isLoggedIn = false;
  bool _isRequesting = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    setState(() => _isLoading = true);
    final token = await _photoService.getAccessToken();
    final urls = await _photoService.getImageUrlsFromFolder(
      dotenv.get('folder_id'),
      token ?? '',
    );
    setState(() {
      urls.shuffle();
      _imageUrls = urls;
      _isLoggedIn = urls.isNotEmpty;
      _isLoading = false;
      _currentIndex = 0;
    });
  }

  Future<void> _showImage(int delta) async {
    final newIndex = (_currentIndex + delta).clamp(0, _imageUrls.length - 1);
    if (newIndex == _currentIndex) return;
    setState(() {
      _currentIndex = newIndex;
      _isRequesting = true;
    });
    try {
      await _photoService.requestImageUrl(_imageUrls[_currentIndex]);
    } catch (e) {
      print('画像の表示に失敗しました');
    } finally {
      sleep(const Duration(seconds: 3));
      setState(() => _isRequesting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : IgnorePointer(
              ignoring: _isRequesting,
              child: AnimatedOpacity(
                opacity: _isRequesting ? 0.5 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Stack(
                children: [
                  ImageContainer(
                    imagePath: 'images/home.jpg',
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            BaseButton(
                              icon: Icons.power_settings_new_outlined,
                              onTap: () => _photoService.start(),
                            ),
                            BaseButton(
                              icon: Icons.stop_circle_outlined,
                              onTap: () => _photoService.stop(),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            BaseButton(
                                icon: Icons.arrow_circle_left_outlined,
                                onTap: () => _showImage(-1)),
                            BaseButton(
                              icon: Icons.arrow_circle_right_outlined,
                              onTap: () => _showImage(1),
                            ),
                          ],
                        ),
                        const Padding(padding: EdgeInsets.only(bottom: 20)),
                      ],
                    ),
                  ),
                  if (!_isLoggedIn)
                    Positioned(
                      top: 24,
                      left: 24,
                      right: 24,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'ログインしてください',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon:
                                  const Icon(Icons.login, color: Colors.white),
                              onPressed: _loadImages,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),)
            ),
    );
  }
}
