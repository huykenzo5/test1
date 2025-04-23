import 'dart:convert';
import 'dart:io';

import '../lib/models/course.dart';
import '../lib/models/student.dart';
import '../lib/services/academy_system.dart';
import '../lib/services/notification_service.dart';

Future<void> main() async {
  final courseFile = File('../../shared/courses.json');
  final courseJsonString = await courseFile.readAsString();
  final courseList = jsonDecode(courseJsonString) as List;
  List<Course> courses = courseList.map((json) => Course.fromJson(json)).toList();

  final studentFile = File('../../shared/students.json');
  final studentJsonString = await studentFile.readAsString();
  final studentList = jsonDecode(studentJsonString) as List;
  List<Student> students = studentList.map((json) => Student.fromJson(json)).toList();

  print('--- Courses ---');
  for (var c in courses) {
    print(c);
  }

  print('\n--- Students ---');
  for (var s in students) {
    print(s);
  }

  // Khởi tạo hệ thống học viện
  var system = AcademySystem(students: students, courses: courses);

  // In lại danh sách học viên và khóa học (demo từ service)
  system.printStudents();
  system.printCourses();

  // Đăng ký học viên vào khóa học
  system.registerStudentToCourse(1, 1); // John đăng ký khóa 1
  system.registerStudentToCourse(2, 2); // Jane đăng ký khóa 2
  system.registerStudentToCourse(1, 2); // John đăng ký khóa 2 nữa

  // Tính học phí
  double totalFee = system.calculateTotalFee([1, 2]);
  print('\n📘 Tổng học phí: \$${totalFee.toStringAsFixed(2)}');

  final notificationService = NotificationService(students);
  notificationService.startHourlyReminder();
}
