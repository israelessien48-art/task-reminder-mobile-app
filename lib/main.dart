import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'student_database.dart';

void main() {
  // ✅ Windows / Linux / Mac SQLite initialization
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const StudentApp());
}

class StudentApp extends StatelessWidget {
  const StudentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Management App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const StudentHomePage(),
    );
  }
}

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  List<Map<String, dynamic>> students = [];

  @override
  void initState() {
    super.initState();
    loadStudents();
  }

  Future<void> loadStudents() async {
    final data = await StudentDatabase.getStudents();

    setState(() {
      students = data;
    });
  }

  Future<void> addStudent() async {
    TextEditingController idController = TextEditingController();
    TextEditingController nameController = TextEditingController();
    TextEditingController courseController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Student"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: idController,
              decoration: const InputDecoration(labelText: "Student ID"),
            ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: courseController,
              decoration: const InputDecoration(labelText: "Course"),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              await StudentDatabase.insertStudent(
                idController.text,
                nameController.text,
                courseController.text,
              );

              Navigator.pop(context);
              loadStudents();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> editStudent(Map<String, dynamic> student) async {
    TextEditingController idController =
        TextEditingController(text: student["studentId"]);

    TextEditingController nameController =
        TextEditingController(text: student["name"]);

    TextEditingController courseController =
        TextEditingController(text: student["course"]);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Student"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: idController,
              decoration: const InputDecoration(labelText: "Student ID"),
            ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: courseController,
              decoration: const InputDecoration(labelText: "Course"),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              await StudentDatabase.updateStudent(
                student["id"],
                idController.text,
                nameController.text,
                courseController.text,
              );

              Navigator.pop(context);
              loadStudents();
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  Future<void> deleteStudent(int id) async {
    await StudentDatabase.deleteStudent(id);
    loadStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Management App"),
      ),
      body: students.isEmpty
          ? const Center(child: Text("No Students Added"))
          : ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(student["name"]),
                    subtitle: Text(
                      "ID: ${student["studentId"]}\nCourse: ${student["course"]}",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => editStudent(student),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => deleteStudent(student["id"]),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: addStudent,
        child: const Icon(Icons.add),
      ),
    );
  }
}