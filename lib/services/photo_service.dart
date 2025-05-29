import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class PhotoService {
  Future<String?> getAccessToken() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        'https://www.googleapis.com/auth/drive',
      ],
    );
    final account = await googleSignIn.signIn();
    final auth = await account?.authentication;
    return auth?.accessToken;
  }

  Future<List<String>> getImageUrlsFromFolder(
      String folderId, String accessToken) async {
    final query =
        "mimeType contains 'image/' and '$folderId' in parents and trashed=false";

    final uri = Uri.https('www.googleapis.com', '/drive/v3/files', {
      'q': query,
      'fields': 'files(id, name, webContentLink)',
    });
    try {
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $accessToken',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final files = List<Map<String, dynamic>>.from(data['files']);

        List<String> urls = [];

        for (var file in files) {
          final fileId = file['id'];
          if (fileId == null) continue;

          await _setFilePublic(fileId, accessToken);

          final url = 'https://drive.google.com/uc?export=view&id=$fileId';
          urls.add(url);
        }

        return urls;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<void> start() async {
    String apiUrl = 'http://${dotenv.get('ip_address')}/start';

    try {
      await http.post(Uri.parse(apiUrl));
      print('start app!');
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> stop() async {
    String apiUrl = 'http://${dotenv.get('ip_address')}/stop';

    try {
      await http.post(Uri.parse(apiUrl));
      print('stop app!');
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> requestImageUrl(String url) async {
    String apiUrl = 'http://${dotenv.get('ip_address')}/display';

    final Map<String, dynamic> data = {"url": url};

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        print("Success: ${response.body}");
      } else {
        print("Failed with status: ${response.statusCode}");
        print("Body: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _setFilePublic(String fileId, String accessToken) async {
    final uri =
        Uri.https('www.googleapis.com', '/drive/v3/files/$fileId/permissions');

    final permissionPayload = jsonEncode({
      "role": "reader",
      "type": "anyone",
    });

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: permissionPayload,
    );

    if (response.statusCode != 200) {
      print(
          'Failed to set permission: ${response.statusCode} - ${response.body}');
    }
  }
}
