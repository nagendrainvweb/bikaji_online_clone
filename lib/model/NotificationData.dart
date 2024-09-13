import 'package:intl/intl.dart';

class NotificationData {
  String id;
  String title;
  String shortMessage;
  String content;
  bool isRead;
  String date;
  String firebase_status;
  String read_users;
  String deleted_users;

  NotificationData(
      {this.id,
      this.title,
      this.shortMessage,
      this.content,
      this.isRead,
      this.read_users,
      this.deleted_users,
      this.firebase_status,
      this.date});

  NotificationData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    shortMessage = json['short_message'];
    content = json['content'];
    read_users = json['read_users'];
    deleted_users = json['deleted_users'];
    firebase_status = json["firebase_status"];
    final dateTime = json['date'];
    DateFormat dateFormat = DateFormat("yyyy-MM-dd hh:mm");
    DateTime date = dateFormat.parse(dateTime);
    String formattedDate = DateFormat('dd-MM-yyyy hh:mm').format(date);
    this.date = formattedDate;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['short_message'] = this.shortMessage;
    data['long_message'] = this.content;
    data['is_read'] = this.isRead;
    data['firebase_status'] = this.firebase_status;
    data['date_time'] = this.date;
    return data;
  }
}
