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
      ResponseDataList response = ResponseDataList(
        status: false,
        message: 'anda belum login / token invalid',
      );
      return response;
    }
    var uri = Uri.parse(url.BaseUrl + "/admin/getbarang");

    Map<String, String> headers = {"Authorization": 'Bearer ${user.token}'};

    var getToko = await http.get(uri, headers: headers);

    if (getToko.statusCode == 200) {
      var data = json.decode(getToko.body);
      if (data["status"] == true) {
        List toko = data["data"].map((r) => TokoModel.fromJson(r)).toList();
        ResponseDataList response = ResponseDataList(
          status: true,
          message: 'success load data',
          data: toko,
        );
        return response;
      } else {
        ResponseDataList response = ResponseDataList(
          status: false,
          message: 'Failed load data',
        );
        return response;
      }
    } else {
      ResponseDataList response = ResponseDataList(
        status: false,
        message: "gagal load toko dengan code error ${getToko.statusCode}",
      );
      return response;
    }
  }
}
