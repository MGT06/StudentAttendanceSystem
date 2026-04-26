import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

class ApiServices {
  static const String baseUrl = 'http://10.0.2.2/API_absen/api';

  // Login endpoint
  static const String loginEndpoint = '/login.php';

  // Absensi endpoint
  static const String absensiEndpoint = '/absensi.php';

  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$loginEndpoint'),
        body: {
          'username': username,
          'password': password,
        },  
      );
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi'};
    }
  }

  static Future<Map<String, dynamic>> submitAbsensi({
    required int muridId,
    required String jenis,
    required String keterangan,
    File? buktiFile,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$absensiEndpoint'),
      );

      request.fields['murid_id'] = muridId.toString();
      request.fields['jenis'] = jenis;
      request.fields['keterangan'] = keterangan;

      if (buktiFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'bukti_file',
            buktiFile.path,
          ),
        );
      }

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);

      if (response.statusCode == 200) {
        return jsonResponse;
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan koneksi: ${e.toString()}'
      };
    }
  }

  static Future<Map<String, dynamic>> getRiwayatAbsensi(int muridId,
      {String? tanggal}) async {
    try {
      String url = '$baseUrl$absensiEndpoint?murid_id=$muridId';
      if (tanggal != null) {
        url += '&tanggal=$tanggal';
      }
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi'};
    }
  }

  static Future<Map<String, dynamic>> getAbsensiSummary(
      {String? tanggal}) async {
    String url = '$baseUrl/absensi_summary.php';
    if (tanggal != null) {
      url += '?tanggal=$tanggal';
    }
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      return {'success': false, 'message': 'Server error'};
    }
  }

  static Future<List<Map<String, dynamic>>> getKelasAktifSummary(
      {String? tanggal}) async {
    String url = '$baseUrl/kelas_aktif_summary.php';
    if (tanggal != null) {
      url += '?tanggal=$tanggal';
    }
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['success'] == true && jsonData['data'] != null) {
        return List<Map<String, dynamic>>.from(jsonData['data']);
      }
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> getKelasList() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/history_kelas.php'));
      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        if (decodedResponse['success'] == true && decodedResponse['data'] is List) {
          return List<Map<String, dynamic>>.from(decodedResponse['data']);
        } else {
          print('API Error (getKelasList): ${decodedResponse['message']}');
          return [];
        }
      } else {
        print('HTTP Error (getKelasList): ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching kelas list: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getAbsensiHistory({
    required String tanggal,
    String? idKelas,
  }) async {
    try {
      final queryParams = {
        'tanggal': tanggal,
        if (idKelas != null) 'id_kelas': idKelas,
      };
      final uri = Uri.parse('$baseUrl/history_absensi.php').replace(queryParameters: queryParams);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        if (decodedResponse['success'] == true && decodedResponse['data'] is List) {
          return List<Map<String, dynamic>>.from(decodedResponse['data']);
        } else {
          print('API Error (getAbsensiHistory): ${decodedResponse['message']}');
          return [];
        }
      } else {
        print('HTTP Error (getAbsensiHistory): ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching absensi history: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> getIzinAnak(int orangTuaId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/izin_anak.php?orang_tua_id=$orangTuaId'));
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        return {'success': false, 'message': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi'};
    }
  }

  static Future<Map<String, dynamic>> konfirmasiIzinOrtu(int absensiId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/konfirmasi_izin.php'),
        body: {'absensi_id': absensiId.toString()},
      );
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        return {'success': false, 'message': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi'};
    }
  }

  static Future<List<Map<String, dynamic>>> getDaftarIzin() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/history_absensi.php?izin_list=1'),
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return List<Map<String, dynamic>>.from(decoded['data']);
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
