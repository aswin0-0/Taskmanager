import 'package:flutter/material.dart';
import 'package:to_do_task/util/dialog_box.dart';
import 'package:to_do_task/util/todolist.dart';
import 'package:to_do_task/services/api_service.dart';
import 'completed_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> todoList = [];
  String selectedFilter = "All";
  final List<String> categories = ["All", "Work", "Groceries", "Study", "Personal"];

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  // Fetch tasks from backend
  Future<void> fetchTasks() async {
    final result = await ApiService.getTasks();
    if (result["success"]) {
      setState(() {
        todoList = List<Map<String, dynamic>>.from(result["data"]);
      });
    } else {
      print("Error fetching tasks: ${result["error"]}");
    }
  }

  // Add new task
  Future<void> createTask(
      String taskName, String description, String category, DateTime dueDate) async {
    final taskData = {
      "title": taskName,
      "description": description,
      "category": category,
      "due_date": "${dueDate.toLocal()}".split(' ')[0],
      "completed": false,
    };

    final result = await ApiService.createTask(taskData);
    if (result["success"]) {
      setState(() {
        todoList.add(Map<String, dynamic>.from(result["data"]));
      });
    } else {
      print("Error adding task: ${result["error"]}");
    }
  }

  // Delete task
  Future<void> deleteTask(int index) async {
    final taskId = todoList[index]["id"];
    final result = await ApiService.deleteTask(taskId);
    if (result["success"]) {
      setState(() {
        todoList.removeAt(index);
      });
    } else {
      print("Error deleting task: ${result["error"]}");
    }
  }

  // Mark task completed
  Future<void> checkboxChanged(bool? value, int index) async {
    final taskId = todoList[index]["id"];
    final result = await ApiService.markCompleted(taskId);
    if (result["success"]) {
      setState(() {
        todoList[index] = Map<String, dynamic>.from(result["data"]);
      });
    } else {
      print("Error updating task: ${result["error"]}");
    }
  }

  void sortTasks(String order) {
    setState(() {
      if (order == "Due Asc") {
        todoList.sort((a, b) =>
            DateTime.parse(a["due_date"]).compareTo(DateTime.parse(b["due_date"])));
      } else if (order == "Due Desc") {
        todoList.sort((a, b) =>
            DateTime.parse(b["due_date"]).compareTo(DateTime.parse(a["due_date"])));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredTasks = selectedFilter == "All"
        ? todoList.where((task) => task["completed"] == false).toList()
        : todoList
            .where((task) =>
                task["category"] == selectedFilter && task["completed"] == false)
            .toList();

    return Scaffold(
      backgroundColor: Colors.yellow[200],
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text("To Do"),
        leading: PopupMenuButton<String>(
          icon: const Icon(Icons.menu),
          onSelected: (value) {
            if (value == "Tasks") {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => const HomePage()));
            } else if (value == "Completed") {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const CompletedPage()));
            } else if (value == "Profile") {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const ProfilePage()));
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: "Tasks", child: Text("Tasks")),
            PopupMenuItem(value: "Completed", child: Text("Completed Tasks")),
            PopupMenuItem(value: "Profile", child: Text("Profile")),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) => setState(() => selectedFilter = value),
            itemBuilder: (context) {
              return categories.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) => sortTasks(value),
            itemBuilder: (context) {
              return const [
                PopupMenuItem(value: "Due Asc", child: Text("Due Date ↑")),
                PopupMenuItem(value: "Due Desc", child: Text("Due Date ↓")),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: filteredTasks.isEmpty
                ? const Center(
                    child: Text(
                      "No pending tasks",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      return TodoList(
                        taskName: task["title"],
                        description: task["description"],
                        category: task["category"],
                        dueDate: DateTime.parse(task["due_date"]),
                        taskCompleted: task["completed"],
                        onChanged: (value) => checkboxChanged(value, index),
                        deleteFunction: () => deleteTask(index),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddTaskDialog(
              onSave: (taskName, description, category, dueDate) {
                createTask(taskName, description, category, dueDate);
                Navigator.pop(context);
              },
              onCancel: () => Navigator.pop(context),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
