import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
          ? Center(child: CircularProgressIndicator())
          : Container(
        width: 300,
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 70,
              backgroundImage: NetworkImage(
                  'http://localhost:8083/api/v1/employees/${widget.employeeId}/profile-picture'),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _positionController,
              decoration: InputDecoration(labelText: 'Position'),
            ),
            SizedBox(height: 16),
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: submitEdit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Edit'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: deleteEmployee,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Delete'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
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
                        child: Text('Cancel'),
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
