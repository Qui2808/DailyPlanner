import 'package:daily_planner/config/next_screen.dart';
import 'package:daily_planner/model/task_model.dart';
import 'package:daily_planner/page/add_task_view.dart';
import 'package:daily_planner/page/task_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../data/sqlite.dart';



class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {

  late List<Task> _tasks = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getListTask();
  }

  void _getListTask() async {
    final DatabaseHelper databaseHelper = DatabaseHelper();
    _tasks = await databaseHelper.getAllTasks();

    // Sắp xếp danh sách
    _tasks.sort((task1, task2) {
      // Sắp xếp theo trạng thái hoàn thành trước
      if (task1.complete && !task2.complete) {
        return 1; // task2 chưa hoàn thành nên đặt task2 trước task1
      } else if (!task1.complete && task2.complete) {
        return -1; // task1 chưa hoàn thành nên đặt task1 trước task2
      } else {
        // Nếu cả hai đều đã hoàn thành hoặc chưa hoàn thành, sắp xếp theo ngày
        DateTime date1 = DateTime.parse(task1.date);
        DateTime date2 = DateTime.parse(task2.date);
        return date1.compareTo(date2); // Sắp xếp ngày từ mới đến cũ
      }
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        // backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        title: const Text('Tất cả nhiệm vụ'),
      ),
      body: ReorderableListView(
        onReorder: _onReorder,
        children: _tasks.map((task) => _buildListItem(task)).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){nextScreen(context, AddTaskPage());},
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }


  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final Task item = _tasks.removeAt(oldIndex);
      _tasks.insert(newIndex, item);
    });
  }

  Widget _buildListItem(Task task) {
    DateTime parsedDate = DateTime.parse(task.date);
    String formattedDate = "${parsedDate.day}-${parsedDate.month}";  // Định dạng dd-MM

    return Slidable(
      key: ValueKey(task),
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => _deleteTask(task),
            backgroundColor: Colors.red,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          // Chuyển đến trang TaskDetailPage
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailPage(task: task),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          decoration: BoxDecoration(
            color: task.complete
                ? Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.5)
                : Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
            title: Text(
              task.content,
              style: TextStyle(
                decoration: task.complete ? TextDecoration.lineThrough : null,
              ),
            ),
            leading: GestureDetector(
              onTap: () {
                setState(() {
                  task.complete = !task.complete;
                });
              },
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.complete
                      ? Colors.grey.withOpacity(0.5)
                      : (Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[300]
                      : Colors.white),
                  border: Border.all(
                    color: task.complete ? Colors.grey.withOpacity(0.1) : Colors.grey,
                    width: 2.0,
                  ),
                ),
                child: task.complete
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ),
            trailing: Text(
              formattedDate,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }



  void _deleteTask(Task task) async {
    final DatabaseHelper databaseHelper = DatabaseHelper();
    await databaseHelper.deleteTask(task.idTask!);

    setState(() {
      _tasks.remove(task);
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Nhiệm vụ đã xóa!')));
  }

}
