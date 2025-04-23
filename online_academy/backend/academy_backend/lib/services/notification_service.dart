import 'dart:async';
import '../models/student.dart';

class NotificationService {
  final List<Student> users;

  NotificationService(this.users);

  // Hàm gửi thông báo (demo: mỗi 2 giây thay vì mỗi 1 giờ)
  void startHourlyReminder() {
    Timer.periodic(Duration(seconds: 2), (timer) async {
      for (var user in users) {
        try {
          await sendNotification(user);
        } catch (e) {
          print('❌ Lỗi gửi thông báo cho ${user.name}: $e');
        }
      }
    });
  }

  // Hàm giả lập gửi thông báo
  Future<void> sendNotification(Student user) async {
    // Giả lập delay khi fetch từ server
    await Future.delayed(Duration(seconds: 1));
    print('🔔 Nhắc nhở học tập gửi đến ${user.name}');
  }
}
