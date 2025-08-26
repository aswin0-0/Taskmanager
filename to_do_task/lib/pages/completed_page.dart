import 'package:flutter/material.dart';
import 'package:to_do_task/util/todolist.dart';
import 'package:to_do_task/services/api_service.dart';

class CompletedPage extends StatefulWidget {
  const CompletedPage({super.key});

  @override
  State<CompletedPage> createState() => _CompletedPageState();
}

class _CompletedPageState extends State<CompletedPage> {
  List<Map<String, dynamic>> completedTasks = [];

  @override
  void initState() {
    super.initState();
    fetchCompletedTasks();
  }

  Future<void> fetchCompletedTasks() async {
    final result = await ApiService.getTasks();
    if (result["success"]) {
      setState(() {
        completedTasks = List<Map<String, dynamic>>.from(result["data"])
            .where((task) => task["completed"] == true)
            .toList();
      });
    } else {
      print("Error fetching tasks: ${result["error"]}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[200],
      appBar: AppBar(
        title: const Text("Completed Tasks"),
        centerTitle: true,
      ),
      body: completedTasks.isEmpty
          ? const Center(
              child: Text(
                "No completed tasks yet",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          : ListView.builder(
              itemCount: completedTasks.length,
              itemBuilder: (context, index) {
                final task = completedTasks[index];
                return TodoList(
                  taskName: task["title"],
                  description: task["description"],
                  category: task["category"],
                  dueDate: DateTime.parse(task["due_date"]),
                  taskCompleted: task["completed"],
                  onChanged: null, // Completed tasks cannot be unchecked
                  deleteFunction: null, // Optional: you can allow deletion
                );
              },
            ),
    );
  }
}
