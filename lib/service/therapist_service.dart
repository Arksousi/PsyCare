import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;

class TherapistService {
  static String get baseUrl => 
    Platform.isAndroid ? 'http://10.0.2.2:5001/api/therapists' : 'http://localhost:5001/api/therapists';

  Future<List<dynamic>> getTherapists() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      return json.decode(response.body) as List;
    } else {
      throw Exception('Failed to load therapists');
    }
  }
}
