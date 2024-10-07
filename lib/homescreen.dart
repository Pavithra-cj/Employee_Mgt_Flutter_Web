import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:emp_mgt_flutter_web/addemployeescreen.dart';
import 'package:emp_mgt_flutter_web/employeedetailscreen.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class HomeScreen extends StatefulWidget {
  final String? token;

  const HomeScreen({super.key, this.token});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> data = [];
  String? role;  // Variable to store the role

  @override
  void initState() {
    super.initState();
    decodeToken();
    fetchData();
  }

  // Function to decode the JWT token and extract the role
  void decodeToken() {
    if (widget.token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(widget.token!);
      setState(() {
        role = decodedToken['role'];  // Assuming the role is stored as 'role' in the token
      });
    }
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8083/api/v1/employees'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> json = jsonDecode(response.body);

        setState(() {
          data = json;
        });
      } else {
        print('Failed to load data: ${response.statusCode} ${response.body}');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  void showEmployeeDetailDialog(dynamic employee) async {
    final result = await showDialog(
      context: context,
      builder: (context) {
        return EmployeeDetailDialog(
          employeeId: employee['id'],
          token: widget.token,
        );
      },
    );

    if (result == true) {
      fetchData();
    }
  }

  void showAddEmployeeDialog() async {
    final result = await showDialog(
      context: context,
      builder: (context) {
        return AddEmployeeDialog(token: widget.token);
      },
    );

    if (result == true) {
      fetchData();
    }
  }

  Future<void> downloadEmployeeListPdf() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8083/api/v1/employees/report'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final contentDisposition = response.headers['content-disposition'];
        final filename = contentDisposition?.split('filename=')[1].replaceAll('"', '') ?? 'Employee_List.pdf';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Management System'),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
        actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: TextButton(
                onPressed: downloadEmployeeListPdf,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Download Employee List PDF',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: showAddEmployeeDialog,
            ),
        ],
      ),
      body: SafeArea(
        child: data.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            final imageUrl = item['profilePicturePath'] ?? 'https://via.placeholder.com/150';

            return GestureDetector(
              onTap: () => showEmployeeDetailDialog(item),
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 7),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(imageUrl),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Name: ${item['name']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            Text(
                              'Position: ${item['position']}',
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (role == 'ROLE_ADMIN')
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            // Implement delete functionality here
                          },
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
