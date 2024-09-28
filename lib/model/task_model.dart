class Task {
  int? idTask;
  String date;
  String content;
  String time;
  String place;
  String preside;
  String note;
  bool complete;

  Task({
    this.idTask,
    required this.date,
    required this.content,
    required this.time,
    required this.place,
    required this.preside,
    required this.note,
    required this.complete,
  });

  // Chuyển Map thành Task
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      idTask: map['idTask'],
      date: map['date'],
      content: map['content'],
      time: map['time'],
      place: map['place'],
      preside: map['preside'],
      note: map['note'],
      complete: map['complete'] == 1,  // SQLite lưu boolean dưới dạng int
    );
  }

  // Chuyển Task thành Map
  Map<String, dynamic> toMap() {
    return {
      'idTask': idTask,
      'date': date,
      'content': content,
      'time': time,
      'place': place,
      'preside': preside,
      'note': note,
      'complete': complete ? 1 : 0,  // Chuyển boolean thành int để lưu
    };
  }

}