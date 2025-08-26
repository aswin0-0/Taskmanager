import 'package:flutter/material.dart';
import 'package:to_do_task/services/api_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    final result = await ApiService.getCurrentUser();
    if (result["success"]) {
      setState(() {
        userData = Map<String, dynamic>.from(result["data"]);
      });
    } else {
      print("Error fetching user data: ${result["error"]}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[200],
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
      ),
      body: userData == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "User Info",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text("Username: ${userData!["username"]}", style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  Text("Email: ${userData!["email"]}", style: const TextStyle(fontSize: 18)),
                ],
              ),
            ),
    );
  }
}
