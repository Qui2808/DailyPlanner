import 'package:daily_planner/model/task_model.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../data/sqlite.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime today = DateTime.now();

  late final ValueNotifier<List<Task>> _selectedTask;
  Map<DateTime, List<Task>> _listTask= {};

  @override
  void initState() {
    super.initState();
    DateTime todayWithoutTime = DateTime(today.year, today.month, today.day);
    today = todayWithoutTime;
    _selectedTask = ValueNotifier<List<Task>>([]);
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final DatabaseHelper databaseHelper = DatabaseHelper();
    List<Task> tasks = await databaseHelper.getAllTasks();
    for (var task in tasks) {
      // Chuyển đổi chuỗi date thành DateTime
      print(task.date);
      DateTime taskDate = DateTime.parse(task.date); // Sử dụng DateTime.parse
      // Thêm task vào _listTask theo ngày
      DateTime formattedDate = DateTime(taskDate.year, taskDate.month, taskDate.day);
      if (_listTask[formattedDate] == null) {
        _listTask[formattedDate] = [];
      }
      _listTask[formattedDate]!.add(task);
    }

    _selectedTask.value = _listTask[today] ?? [];

    setState(() {});
  }

// Hàm để lấy các task cho một ngày cụ thể
  List<Task> _getTasksForDate(DateTime date) {
    DateTime dayWithoutTime = DateTime(date.year, date.month, date.day);
    // Trả về danh sách task cho ngày
    return _listTask[dayWithoutTime] ?? [];
  }

  void _onDaySelected(DateTime day, DateTime focusedDay){
    setState(() {
      today = day;
      _selectedTask.value = _getTasksForDate(today);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Lịch'),
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: 'en_US',
            focusedDay: today,
            rowHeight: 43,
            headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
            availableGestures: AvailableGestures.all,
            selectedDayPredicate: (day) => isSameDay(day, today),
            eventLoader: _getTasksForDate,
            firstDay: DateTime.utc(2015),
            lastDay: DateTime.utc(2035),
            onDaySelected: _onDaySelected,
            startingDayOfWeek: StartingDayOfWeek.monday,
          ),

          const SizedBox(height: 22),

          Expanded(
            child: ValueListenableBuilder<List<Task>>(
              valueListenable: _selectedTask,
              builder: (context, value, _) {
                return ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Row(
                        children: [

                          Container(
                            width: 5,
                            height: 55,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 0),

                          // Nội dung của ListTile
                          Expanded(
                            child: Container(
                              color: Theme.of(context).colorScheme.surfaceContainer,
                              child: ListTile(
                                onTap: () {},
                                title: Text(
                                  value[index].content,
                                  style: TextStyle(
                                    decoration: value[index].complete ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );

              },
            ),
          ),
        ],
      ),
    );
  }

}
