import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class EmployeeDetailDialog extends StatefulWidget {
  final int employeeId;
  final String? token;

  const EmployeeDetailDialog({
    super.key,
    required this.employeeId,
    required this.token,
  });

  @override
  _EmployeeDetailDialogState createState() => _EmployeeDetailDialogState();
}

class _EmployeeDetailDialogState extends State<EmployeeDetailDialog> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _positionController;
  bool isLoading = false;
  File? _imageFile; // Store the selected image file
  String? _imageUrl; // Store the URL of the image

  @override
  void initState() {
    super.initState();
    fetchEmployeeDetails();
  }

  Future<void> fetchEmployeeDetails() async {
    setState(() {
      isLoading = true;
    });
    final response = await http.get(
      Uri.parse('http://localhost:8083/api/v1/employees/${widget.employeeId}'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );
    if (response.statusCode == 200) {
      final employee = jsonDecode(response.body);
      _nameController = TextEditingController(text: employee['name']);
      _emailController = TextEditingController(text: employee['email']);
      _positionController = TextEditingController(text: employee['position']);
      _imageUrl = 'http://localhost:8083/api/v1/employees/${widget.employeeId}/profile-picture'; // Set the image URL
    } else {
      throw Exception('Failed to load employee details');
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> submitEdit() async {
    final response = await http.put(
      Uri.parse('http://localhost:8083/api/v1/employees/${widget.employeeId}'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': _nameController.text,
        'email': _emailController.text,
        'position': _positionController.text,
      }),
    );

    if (response.statusCode == 200) {
      _showAlert('Success', 'Employee Updated Successfully', true);
    } else {
      _showAlert('Error', 'Failed to update employee: ${response.statusCode} ${response.body}', false);
    }
  }

  Future<void> deleteEmployee() async {
    final response = await http.delete(
      Uri.parse('http://localhost:8083/api/v1/employees/${widget.employeeId}'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      _showAlert('Success', 'Employee deleted.', true);
    } else {
      _showAlert('Error', 'Failed to delete employee: ${response.statusCode} ${response.body}', false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:8083/api/v1/employees/${widget.employeeId}/profile-picture'),
    );
    request.headers['Authorization'] = 'Bearer ${widget.token}';
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        await _imageFile!.readAsBytes(),
        filename: path.basename(_imageFile!.path),
      ),
    );

    final response = await request.send();
    if (response.statusCode == 200) {
      _showAlert('Success', 'Image uploaded successfully', true);
    } else {
      _showAlert('Error', 'Failed to upload image: ${response.statusCode}', false);
    }
  }

  void _showAlert(String title, String message, bool isSuccess) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (isSuccess) {
                  Navigator.of(context).pop(true);
                }
              },
              child: Text(isSuccess ? 'OK' : 'Retry'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
        width: 300,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 70,
              backgroundImage: _imageFile != null
                  ? FileImage(_imageFile!)
                  : _imageUrl != null
                  ? NetworkImage(_imageUrl!)
                  : const AssetImage('assets/default_avatar.png') as ImageProvider,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _pickImage,
              child: const Text('Upload an image'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _positionController,
              decoration: const InputDecoration(labelText: 'Position'),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await submitEdit();
                          if (_imageFile != null) {
                            await _uploadImage();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Edit'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: deleteEmployee,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Delete'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
