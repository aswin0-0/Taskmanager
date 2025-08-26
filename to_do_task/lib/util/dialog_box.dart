import 'package:flutter/material.dart';

class AddTaskDialog extends StatefulWidget {
  final Function(String taskName, String description, String category, DateTime dueDate) onSave;
  final VoidCallback onCancel;

  const AddTaskDialog({
    super.key,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _descController = TextEditingController(); // ✅ new controller
  String _selectedCategory = "Work";
  DateTime _selectedDate = DateTime.now();

  // Date picker
  Future<void> _pickDueDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.yellow[200],
      content: SingleChildScrollView(  // 👈 Wrap in scrollable
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task name
              TextField(
                controller: _taskController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Task name",
                ),
              ),
              const SizedBox(height: 12),

              // Task description
              TextField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Task Description",
                ),
              ),
              const SizedBox(height: 12),

              // Category dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Category",
                ),
                items: ["All", "Work", "Study", "Groceries", "Personal"]
                    .map((category) =>
                        DropdownMenuItem(value: category, child: Text(category)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 12),

              // Due date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Due: ${_selectedDate.toLocal().toString().split(' ')[0]}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  TextButton(
                    onPressed: _pickDueDate,
                    child: const Text("Pick Date"),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_taskController.text.trim().isEmpty) return;
                      widget.onSave(
                        _taskController.text,
                        _descController.text,
                        _selectedCategory,
                        _selectedDate,
                      );
                    },
                    child: const Text("Save"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: widget.onCancel,
                    child: const Text("Cancel"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}
