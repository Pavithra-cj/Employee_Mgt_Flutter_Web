import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/employee_controller.dart';

class EmployeeDetailDialog extends StatelessWidget {
  final Map<String, dynamic> employee;
  final String token;

  EmployeeDetailDialog({required this.employee, required this.token});

  @override
  Widget build(BuildContext context) {
    final EmployeeController employeeController = Get.find<EmployeeController>();

    employeeController.nameController.text = employee['name'];
    employeeController.positionController.text = employee['position'];

    return AlertDialog(
      title: Text('Employee Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: employeeController.nameController,
            decoration: InputDecoration(
              labelText: 'Name',
            ),
          ),
          TextFormField(
            controller: employeeController.positionController,
            decoration: InputDecoration(
              labelText: 'Position',
            ),
          ),
          TextFormField(
            controller: employeeController.emailController,
            decoration: InputDecoration(
              labelText: 'Email',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('Close'),
        ),
        TextButton(
          onPressed: () {
            employeeController.updateEmployee(token, employee['id']);
            Get.back(); // Close the dialog after updating
          },
          child: Text('Update'),
        ),
        TextButton(
          onPressed: () {
            employeeController.deleteEmployee(token, employee['id']);
            Get.back(); // Close the dialog after deletion
          },
          child: Text('Delete'),
          style: TextButton.styleFrom(
            backgroundColor: Colors.red,
          ),
        ),
      ],
    );
  }
}
