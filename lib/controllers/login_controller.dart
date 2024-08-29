import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../screen/homescreen.dart';

class LoginController extends GetxController {
  var username = ''.obs;
  var password = ''.obs;
  var token = ''.obs;

  Future<void> login() async {
    if (username.value.isEmpty || password.value.isEmpty) {
      Get.snackbar('Error', 'Username and password cannot be empty');
      return;
    }

    final body = {'username': username.value, 'password': password.value};

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8083/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        token.value = response.body;

        if (token.isNotEmpty) {
          Get.snackbar('Success', 'Login successful');
          Get.off(HomeScreen(token: token.value));
        } else {
          Get.snackbar('Error', 'Login failed: No token received');
        }
      } else {
        Get.snackbar('Error', 'Login failed with status: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Login error: $e');
    }
  }
}
