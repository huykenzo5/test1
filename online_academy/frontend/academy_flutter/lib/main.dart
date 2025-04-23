import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() {
  runApp(const MyApp());
}

class Course {
  final String name;
  final String teacher;
  final double price;
  final int id;

  Course({required this.id, required this.name, required this.teacher, required this.price});

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        id: json['id'],
        name: json['name'],
        teacher: json['teacher'],
        price: (json['price'] as num).toDouble(),
      );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Online Academy',
      home: DefaultTabController(
        length: 3, // Số tab
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Online Academy'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Khóa học'),
                Tab(text: 'Học viên'),
                Tab(text: 'Đăng ký'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              CourseListTab(),
              StudentListTab(),
              RegisterTab(),
            ],
          ),
        ),
      ),
    );
  }
}

class Student {
  final int id;
  final String name;
  final int age;

  Student({required this.id, required this.name, required this.age});

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      name: json['name'],
      age: json['age'],
    );
  }
}

class StudentListTab extends StatelessWidget {
  const StudentListTab({super.key});

  Future<List<Student>> loadStudents() async {
    final jsonString = await rootBundle.loadString('assets/students.json');
    final List data = jsonDecode(jsonString);
    return data.map((e) => Student.fromJson(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Student>>(
      future: loadStudents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }

        final students = snapshot.data!;
        return ListView.builder(
          itemCount: students.length,
          itemBuilder: (context, index) {
            final s = students[index];
            return ListTile(
              title: Text(s.name),
              subtitle: Text('Tuổi: ${s.age}'),
              leading: CircleAvatar(child: Text('${s.id}')),
            );
          },
        );
      },
    );
  }
}

class CourseListTab extends StatelessWidget {
  const CourseListTab({super.key});

  Future<List<Course>> loadCourses() async {
    final jsonString = await rootBundle.loadString('assets/courses.json');
    final List data = jsonDecode(jsonString);
    return data.map((e) => Course.fromJson(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Course>>(
      future: loadCourses(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text('Lỗi: ${snapshot.error}');
        }

        final courses = snapshot.data!;
        return ListView.builder(
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final c = courses[index];
            return ListTile(
              title: Text(c.name),
              subtitle: Text('GV: ${c.teacher}'),
              trailing: Text('\$${c.price.toStringAsFixed(2)}'),
            );
          },
        );
      },
    );
  }
}

class RegisterTab extends StatefulWidget {
  const RegisterTab({super.key});

  @override
  State<RegisterTab> createState() => _RegisterTabState();
}

class _RegisterTabState extends State<RegisterTab> {
  List<Student> students = [];
  List<Course> courses = [];

  Student? selectedStudent;
  Course? selectedCourse;
  String resultMessage = '';
  Map<int, List<int>> studentCourseMap = {}; // studentId → List<courseId>

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final studentJson = await rootBundle.loadString('assets/students.json');
    final studentList = jsonDecode(studentJson) as List;
    students = studentList.map((e) => Student.fromJson(e)).toList();

    final courseJson = await rootBundle.loadString('assets/courses.json');
    final courseList = jsonDecode(courseJson) as List;
    courses = courseList.map((e) => Course.fromJson(e)).toList();

    setState(() {});
  }

  void register() {
    if (selectedStudent == null || selectedCourse == null) {
      setState(() {
        resultMessage = '❌ Vui lòng chọn học viên và khóa học';
      });
    } else {
      final studentId = selectedStudent!.id;
      final courseId = selectedCourse!.id;

      studentCourseMap.putIfAbsent(studentId, () => []);
      if (!studentCourseMap[studentId]!.contains(courseId)) {
        studentCourseMap[studentId]!.add(courseId);
        setState(() {
          resultMessage =
              '✅ ${selectedStudent!.name} đã đăng ký khóa "${selectedCourse!.name}"';
        });
      } else {
        setState(() {
          resultMessage = '⚠️ Học viên đã đăng ký khóa này rồi!';
        });
      }
    }
  }

  double calculateFee(int studentId) {
    final courseIds = studentCourseMap[studentId] ?? [];
    double total = 0;
    for (var id in courseIds) {
      final course = courses.firstWhere((c) => c.id == id);
      total += course.price;
    }
    return total;
  }

  void exportToFile() {
  final exportData = <String, List<int>>{};
  for (var entry in studentCourseMap.entries) {
    exportData[entry.key.toString()] = entry.value;
  }

  final jsonString = jsonEncode(exportData);

  if (!kIsWeb) {
    try {
      final file = File('registered_courses.json');
      file.writeAsStringSync(jsonString);
      setState(() {
        resultMessage = '✅ Đã xuất file registered_courses.json thành công!';
      });
    } catch (e) {
      setState(() {
        resultMessage = '❌ Không thể ghi file: $e';
      });
    }
  } else {
    // Nếu là web, chỉ hiển thị nội dung ra màn hình
    setState(() {
      resultMessage = '🌐 Web không hỗ trợ ghi file. Dữ liệu:\n$jsonString';
    });
  }
}


  @override
  Widget build(BuildContext context) {
    if (students.isEmpty || courses.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          DropdownButton<Student>(
            value: selectedStudent,
            hint: const Text('Chọn học viên'),
            isExpanded: true,
            items: students.map((s) {
              return DropdownMenuItem(
                value: s,
                child: Text(s.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedStudent = value;
              });
            },
          ),
          const SizedBox(height: 16),
          DropdownButton<Course>(
            value: selectedCourse,
            hint: const Text('Chọn khóa học'),
            isExpanded: true,
            items: courses.map((c) {
              return DropdownMenuItem(
                value: c,
                child: Text(c.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedCourse = value;
              });
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: register,
            child: const Text('Đăng ký'),
          ),
          const SizedBox(height: 16),
          Text(resultMessage),
          if (selectedStudent != null) ...[
            const SizedBox(height: 16),
            Text(
              '📘 Tổng học phí: \$${calculateFee(selectedStudent!.id).toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: exportToFile,
            child: const Text('📤 Xuất danh sách đăng ký'),
          ),
        ],
      ),
    );
  }
}
