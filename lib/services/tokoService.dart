import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobileapp2/models/response_data_list.dart';
import 'package:mobileapp2/models/toko_model.dart';
import 'package:mobileapp2/models/user_login.dart';
import 'package:mobileapp2/services/url.dart' as url;

class TokoService {
  Future getToko() async {
    UserLogin userLogin = UserLogin();
    var user = await userLogin.getUserLogin();
    if (user.status == false) {
      return ResponseDataList(
        status: false,
        message: 'anda belum login / token invalid',
      );
    }

    var uri = Uri.parse(url.BaseUrl + "/admin/getbarang");
    Map<String, String> headers = {"Authorization": 'Bearer ${user.token}'};
    var getToko = await http.get(uri, headers: headers);

    if (getToko.statusCode == 200) {
      var data = json.decode(getToko.body);
      if (data["status"] == true) {
        List toko = data["data"].map((r) => TokoModel.fromJson(r)).toList();
        return ResponseDataList(
          status: true,
          message: 'success load data',
          data: toko,
        );
      } else {
        return ResponseDataList(status: false, message: 'Failed load data');
      }
    } else {
      return ResponseDataList(
        status: false,
        message: "gagal load toko dengan code error ${getToko.statusCode}",
      );
    }
  }
  //menamah barang
  //membuat fungsi untuk insert dan update
  Future insertToko(request, image, id) async {
    var user = await UserLogin().getUserLogin();
    if (user.status == false) {
      return ResponseDataList(
        status: false,
        message: 'anda belum login / token invalid',
      );
    }

    Map<String, String> headers = {
      "Authorization": 'Bearer ${user.token}',
    };

    // Tentukan endpoint insert atau update
    final endpoint = id == null
        ? Uri.parse(url.BaseUrl + "/admin/insertbarang")
        : Uri.parse(url.BaseUrl + "/admin/updatebarang/$id");

    var multipartRequest = http.MultipartRequest("POST", endpoint);
    multipartRequest.headers.addAll(headers);

    // Isi fields
    multipartRequest.fields['nama_barang'] = request['nama_barang'].toString();
    multipartRequest.fields['deskripsi']   = request['deskripsi'].toString();
    multipartRequest.fields['stok']        = request['stok'].toString();
    multipartRequest.fields['harga']       = request['harga'].toString();
    multipartRequest.fields['kategori']    = request['kategori'].toString();

    // ── FIX: pakai fromPath agar tidak hang ──
    if (image != null) {
      multipartRequest.files.add(
        await http.MultipartFile.fromPath('image', image.path),
      );
    }

    try {
      var streamedResponse = await multipartRequest.send();
      var result = await http.Response.fromStream(streamedResponse);

      if (streamedResponse.statusCode == 200) {
        var data = json.decode(result.body);
        if (data["status"] == true) {
          return ResponseDataList(
            status: true,
            message: data["message"] ?? "success",
          );
        } else {
          return ResponseDataList(
            status: false,
            message: data["message"] ?? "Failed insert data",
          );
        }
      } else {
        return ResponseDataList(
          status: false,
          message:
              "gagal insert toko dengan code error ${streamedResponse.statusCode}",
        );
      }
    } catch (e) {
      return ResponseDataList(
        status: false,
        message: "Terjadi kesalahan: $e",
      );
    }
  }

  //hapus barang
  //membuat fungsi untuk hapus barang
  Future deleteToko(context, id) async {
    var user = await UserLogin().getUserLogin();
    if (user.status == false) {
      return ResponseDataList(
        status: false,
        message: 'anda belum login / token invalid',
      );
    }
    //hapus barang berdasarkan id
    var uri = Uri.parse(url.BaseUrl + "/admin/hapusbarang/$id");
    Map<String, String> headers = {
      "Authorization": 'Bearer ${user.token}',
    };

    var deleteToko = await http.delete(uri, headers: headers);

    if (deleteToko.statusCode == 200) {
      var result = json.decode(deleteToko.body);
      if (result["status"] == true) {
        return ResponseDataList(
          status: true,
          message: result["message"] ?? 'Sukses hapus data',
        );
      } else {
        return ResponseDataList(
          status: false,
          message: result["message"] ?? 'Failed hapus data',
        );
      }
    } else {
      return ResponseDataList(
        status: false,
        message:
            "gagal hapus toko dengan code error ${deleteToko.statusCode}",
      );
    }
  }
}