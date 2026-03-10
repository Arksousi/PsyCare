import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;

class BookingService {
  static String get baseUrl => 
    Platform.isAndroid ? 'http://10.0.2.2:5001/api' : 'http://localhost:5001/api';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> _headers() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<String> bookSlot({required String slotId}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bookings/book'),
      headers: await _headers(),
      body: json.encode({'slotId': slotId}),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return data['_id'];
    } else {
      throw Exception('Failed to book slot: ${json.decode(response.body)['message']}');
    }
  }

  Future<void> therapistAcceptBooking({required String bookingId}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bookings/$bookingId/accept'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to accept booking: ${json.decode(response.body)['message']}');
    }
  }

  Future<void> therapistRejectBooking({required String bookingId}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bookings/$bookingId/reject'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to reject booking: ${json.decode(response.body)['message']}');
    }
  }

  Future<List<dynamic>> getSlots({String? therapistId}) async {
    final uri = therapistId != null 
      ? Uri.parse('$baseUrl/slots?therapistId=$therapistId')
      : Uri.parse('$baseUrl/slots');
      
    final response = await http.get(uri, headers: await _headers());
    if (response.statusCode == 200) {
      return json.decode(response.body) as List;
    } else {
      throw Exception('Failed to load slots');
    }
  }

  Future<List<dynamic>> getMySlots() async {
    final response = await http.get(
      Uri.parse('$baseUrl/slots/me'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body) as List;
    } else {
      throw Exception('Failed to load my slots');
    }
  }

  Future<void> createSlot(DateTime startAt, DateTime endAt) async {
    final response = await http.post(
      Uri.parse('$baseUrl/slots'),
      headers: await _headers(),
      body: json.encode({
        'startAt': startAt.toIso8601String(),
        'endAt': endAt.toIso8601String(),
      }),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create slot');
    }
  }

  Future<List<dynamic>> getMyBookings() async {
    final response = await http.get(
      Uri.parse('$baseUrl/bookings/me'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body) as List;
    } else {
      throw Exception('Failed to load bookings');
    }
  }
}
