import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/employee_controller.dart';

class AddEmployeeDialog extends StatelessWidget {
  final String token;

  AddEmployeeDialog({required this.token});

  @override
  Widget build(BuildContext context) {
    final employeeController = Get.put(EmployeeController());

    return AlertDialog(
      title: Text('Add Employee'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: employeeController.nameController,
            decoration: InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: employeeController.positionController,
            decoration: InputDecoration(labelText: 'Position'),
          ),
          TextField(
            controller: employeeController.emailController,
            decoration: InputDecoration(labelText: 'Email'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            print("Cancel");
            Get.back();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            Get.back();
            await employeeController.addEmployee(token);
            if (Get.isDialogOpen == false) {
              await Get.find<EmployeeController>().fetchEmployees(token);
            }

          },
          child: Text('Add'),
        ),
      ],
    );
  }
}
