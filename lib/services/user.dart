import 'package:http/http.dart' as http;
import 'package:mobileapp2/models/response_data_map.dart';
import 'package:mobileapp2/models/response_data_list.dart';
import 'package:mobileapp2/models/user_login.dart';
import 'dart:convert';
import 'package:mobileapp2/services/url.dart' as url;

class UserService {
  // ── Helper: ambil token dari SharedPreferences ────────────
  Future<String?> _getToken() async {
    final userLogin = UserLogin();
    final user = await userLogin.getUserLogin();
    return user.token;
  }

  Map<String, String> _authHeaders(String? token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  // ══════════════════════════════════════════════════════════
  // AUTH
  // ══════════════════════════════════════════════════════════

  Future registerUser(data) async {
    var uri = Uri.parse(url.BaseUrl + '/auth/register');
    var register = await http.post(uri, body: data);

    if (register.statusCode == 200) {
      var data = json.decode(register.body);
      if (data['status'] == true) {
        ResponseDataMap response = ResponseDataMap(
          status: true,
          message: 'Sukses Menambah User',
          data: data['data'],
        );
        return response;
      } else {
        ResponseDataMap response = ResponseDataMap(
          status: false,
          message:
              "gagal menambah user dengan code error ${register.statusCode}",
        );
        return response;
      }
    } else {
      ResponseDataMap response = ResponseDataMap(
        status: false,
        message: "HTTP error: ${register.statusCode}",
      );
      return response;
    }
  }

  Future<UserLogin?> loginUser(Map<String, dynamic> data) async {
    var uri = Uri.parse('${url.BaseUrl}/auth/login');
    var login = await http.post(uri, body: data);

    if (login.statusCode.toString().startsWith('2')) {
      var res = json.decode(login.body);

      if (res['status'] == true) {
        UserLogin userLogin = UserLogin(
          status: res['status'],
          token: res['token'],
          message: res['message'],
          id: res['user']?['id'],
          name: res['user']?['nama_user'],
          email: res['user']?['email'],
          role: res['user']?['role'],
        );

        await userLogin.prefs();
        return userLogin;
      }
    }

    return null;
  }

  // ══════════════════════════════════════════════════════════
  // TOKO — GET semua barang (public)
  // ══════════════════════════════════════════════════════════

  Future<ResponseDataList> getBarang() async {
    try {
      final token = await _getToken();
      final uri   = Uri.parse('${url.BaseUrl}/user/getbarang');
      final res   = await http
          .get(uri, headers: _authHeaders(token))
          .timeout(const Duration(seconds: 10));

      final body = json.decode(res.body);

      if (res.statusCode == 200 && body['status'] == true) {
        return ResponseDataList(
          status: true,
          message: body['message'] ?? 'Berhasil',
          data: body['data'],
        );
      }
      return ResponseDataList(
        status: false,
        message: body['message'] ?? 'Gagal memuat produk',
      );
    } catch (e) {
      return ResponseDataList(
        status: false,
        message: 'Koneksi gagal: $e',
      );
    }
  }

  // ══════════════════════════════════════════════════════════
  // TRANSAKSI — POST buat pesanan baru
  // Body: { "pesan": [{ "barang_id": 1, "qty": 2 }] }
  // ══════════════════════════════════════════════════════════

  Future<ResponseDataMap> buatTransaksi(
      List<Map<String, dynamic>> pesanList) async {
    try {
      final token = await _getToken();
      final uri   = Uri.parse('${url.BaseUrl}/user/transaksi');

      // Kirim sebagai JSON dengan header yang benar
      final res = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({'pesan': pesanList}),
      ).timeout(const Duration(seconds: 15));

      // Debug: print response untuk troubleshooting
      // print('STATUS: ${res.statusCode}');
      // print('BODY: ${res.body}');

      dynamic body;
      try {
        body = json.decode(res.body);
      } catch (e) {
        return ResponseDataMap(
          status: false,
          message: 'Error API: ${res.body.length > 100 ? res.body.substring(0, 100) : res.body}',
        );
      }

      // Handle berbagai format response sukses dari API
      final isSuccess = (res.statusCode == 200 || res.statusCode == 201) &&
          (body['status'] == true ||
           body['status'] == 'success' ||
           body['success'] == true ||
           body['message']?.toString().toLowerCase().contains('berhasil') == true);

      if (isSuccess) {
        return ResponseDataMap(
          status: true,
          message: body['message'] ?? 'Transaksi berhasil',
          data: body['data'] ?? body,
        );
      }

      return ResponseDataMap(
        status: false,
        message: body['message'] ??
            body['error'] ??
            'Transaksi gagal (${res.statusCode})',
      );
    } catch (e) {
      return ResponseDataMap(
        status: false,
        message: 'Koneksi gagal: $e',
      );
    }
  }

  // ══════════════════════════════════════════════════════════
  // TRANSAKSI — GET riwayat transaksi user yang login
  // ══════════════════════════════════════════════════════════

  Future<ResponseDataList> getRiwayatTransaksi() async {
    try {
      final token = await _getToken();
      final uri   = Uri.parse('${url.BaseUrl}/user/history_trans');
      final res   = await http
          .get(uri, headers: _authHeaders(token))
          .timeout(const Duration(seconds: 10));

      final body = json.decode(res.body);

      if (res.statusCode == 200 && body['status'] == true) {
        return ResponseDataList(
          status: true,
          message: body['message'] ?? 'Berhasil',
          data: body['data'],
        );
      }
      return ResponseDataList(
        status: false,
        message: body['message'] ?? 'Gagal memuat riwayat',
      );
    } catch (e) {
      return ResponseDataList(
        status: false,
        message: 'Koneksi gagal: $e',
      );
    }
  }

  // ══════════════════════════════════════════════════════════
  // TRANSAKSI — GET detail satu transaksi by ID
  // ══════════════════════════════════════════════════════════

  Future<ResponseDataMap> getDetailTransaksi(dynamic id) async {
    try {
      final token = await _getToken();
      final uri   = Uri.parse('${url.BaseUrl}/user/transaksi/$id');
      final res   = await http
          .get(uri, headers: _authHeaders(token))
          .timeout(const Duration(seconds: 10));

      final body = json.decode(res.body);

      if (res.statusCode == 200 && body['status'] == true) {
        return ResponseDataMap(
          status: true,
          message: body['message'] ?? 'Berhasil',
          data: body['data'],
        );
      }
      return ResponseDataMap(
        status: false,
        message: body['message'] ?? 'Gagal memuat detail transaksi',
      );
    } catch (e) {
      return ResponseDataMap(
        status: false,
        message: 'Koneksi gagal: $e',
      );
    }
  }
}