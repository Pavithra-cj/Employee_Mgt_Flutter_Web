import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'dart:convert';

import 'package:path_provider/path_provider.dart';

class EmployeeController extends GetxController {
  var employees = [].obs;
  var isLoading = false.obs;

  final nameController = TextEditingController();
  final positionController = TextEditingController();
  final emailController = TextEditingController();

  // Fetch employees data from the server
  Future<void> fetchEmployees(String token) async {
    isLoading(true);

    try {
      final response = await http.get(
        Uri.parse('http://localhost:8083/api/v1/employees'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        employees.value = jsonDecode(response.body);
      } else {
        Get.snackbar('Error', 'Failed to load data');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error fetching data: $e');
    } finally {
      isLoading(false);
    }
  }

  // Add a new employee to the server
  Future<void> addEmployee(String token) async {
    final body = {
      'name': nameController.text,
      'position': positionController.text,
      'email': emailController.text,
    };

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8083/api/v1/employees'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Employee added successfully');
        await Future.delayed(Duration(milliseconds: 500));

        await fetchEmployees(token);
        Get.back(result: true);
      } else {
        Get.snackbar('Error', 'Failed to add employee: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error adding employee: $e');
    }
  }

  // Update an existing employee on the server
  Future<void> updateEmployee(String token, int id) async {
    final body = {
      'name': nameController.text,
      'position': positionController.text,
      'email': emailController.text,
    };

    try {
      final response = await http.put(
        Uri.parse('http://localhost:8083/api/v1/employees/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Employee updated successfully');
        await Future.delayed(Duration(milliseconds: 500));

        await fetchEmployees(token);
        Get.back(result: true);
      } else {
        Get.snackbar('Error', 'Failed to update employee: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error updating employee: $e');
    }
  }

  // Delete an employee from the server
  Future<void> deleteEmployee(String token, int id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:8083/api/v1/employees/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Employee deleted successfully');
        await fetchEmployees(token);
      } else {
        Get.snackbar('Error', 'Failed to delete employee: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error deleting employee: $e');
    }
  }

  //Download employee list report pdf
  Future<void> downloadEmployeeListPdf(String token) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8083/api/v1/employees/report'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final contentDisposition = response.headers['content-disposition'];
        final filename = contentDisposition?.split('filename=')[1]?.replaceAll('"', '') ?? 'Employee_List.pdf';

        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/$filename';

        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        await OpenFile.open(filePath);
      } else {
        print('Failed to download PDF: ${response.statusCode} ${response.body}');
      }
    } catch (error) {
      print('Error downloading or opening PDF: $error');
    }
  }

  //Upload employee profile picture
  Future<void> uploadProfilePicture(String token, int id, File file) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:8083/api/v1/employees/$id/profile-picture'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Profile picture uploaded successfully');
      } else {
        Get.snackbar('Error', 'Failed to upload profile picture: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error uploading profile picture: $e');
    }
  }

  //Get employee profile picture
  Future<void> getProfilePicture(String token, int id) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8083/api/v1/employees/$id/profile-picture'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final image = Image.memory(bytes);

        // Show the image in an alert dialog or another widget
        Get.dialog(AlertDialog(
          content: image,
        ));
      } else {
        Get.snackbar('Error', 'Failed to fetch profile picture: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error fetching profile picture: $e');
    }
  }


  @override
  void onClose() {
    nameController.dispose();
    positionController.dispose();
    super.onClose();
  }
}
