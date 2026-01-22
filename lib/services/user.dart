import 'package:http/http.dart' as http;
import 'package:mobileapp2/models/response_data_map.dart';
import 'package:mobileapp2/models/user_login.dart';
import 'dart:convert';
import 'package:mobileapp2/services/url.dart' as url;

class UserService {
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
}
