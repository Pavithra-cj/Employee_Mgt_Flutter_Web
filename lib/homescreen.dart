import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:emp_mgt_flutter_web/addemployeescreen.dart';
import 'package:emp_mgt_flutter_web/employeedetailscreen.dart';

class HomeScreen extends StatefulWidget {
  final String? token;

  HomeScreen({this.token});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> data = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8083/api/v1/employees'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
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
        ],
      ),
      body: SafeArea(
        child: data.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            final imageUrl = item['profilePicturePath'] ?? 'https://via.placeholder.com/150';

            return GestureDetector(
              onTap: () => showEmployeeDetailDialog(item),
              child: Card(
                margin: EdgeInsets.symmetric(horizontal: 25, vertical: 7),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(imageUrl),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Name: ${item['name']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            Text(
                              'Position: ${item['position']}',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddEmployeeDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.lightBlue,
      ),
    );
  }
}
