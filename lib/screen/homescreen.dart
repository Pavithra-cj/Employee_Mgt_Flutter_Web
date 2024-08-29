import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emp_mgt_flutter_web/controllers/employee_controller.dart';

import '../dialog/add_employee_dialog.dart';
import '../dialog/employee_details_dialog.dart';

class HomeScreen extends StatelessWidget {
  final String token;
  final EmployeeController employeeController = Get.put(EmployeeController());

  HomeScreen({required this.token}) {
    employeeController.fetchEmployees(token);
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
              onPressed: () {
                employeeController.downloadEmployeeListPdf(token);
              },
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
      body: Obx(() {
        if (employeeController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        } else if (employeeController.employees.isEmpty) {
          return Center(child: Text('No employees found'));
        } else {
          return ListView.builder(
            itemCount: employeeController.employees.length,
            itemBuilder: (context, index) {
              final employee = employeeController.employees[index];

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 3,
                child: ListTile(
                  leading: CircleAvatar(
                    // backgroundImage: NetworkImage(imageUrl),
                    radius: 30,  // Adjust the radius as needed
                  ),
                  title: Text(employee['name']),
                  subtitle: Text(employee['position']),
                  onTap: () {
                    Get.dialog(EmployeeDetailDialog(
                      employee: employee,
                      token: token,
                    ));
                  },
                ),
              );
            },
          );
        }
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.dialog(AddEmployeeDialog(token: token));
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.lightBlue,
      ),
    );
  }
}
