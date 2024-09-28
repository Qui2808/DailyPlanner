import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/sqlite.dart';
import '../model/task_model.dart';
import 'add_task_view.dart';
import 'home_page.dart';

class TaskDetailPage extends StatefulWidget {
  final Task task;

  TaskDetailPage({required this.task});

  @override
  _TaskDetailPageState createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _dateController;
  late TextEditingController _placeController;
  late TextEditingController _presideController;
  late TextEditingController _noteController;
  late TextEditingController _timeController;
  late DateTime _selectedDate;
  late TimeOfDay _startTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.content);
    _dateController = TextEditingController(text: widget.task.date);
    _placeController = TextEditingController(text: widget.task.place);
    _presideController = TextEditingController(text: widget.task.preside);
    _noteController = TextEditingController(text: widget.task.note);
    _timeController = TextEditingController(text: widget.task.time);
    _selectedDate = DateFormat('yyyy-MM-dd').parse(widget.task.date);
    _startTime = TimeOfDay.fromDateTime(DateFormat('HH:mm').parse(widget.task.time));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết Nhiệm vụ'),
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: Theme.of(context).colorScheme.primary,),
            onPressed: _updateTask,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MyInputField('Tiêu đề', 'Nhập tiêu đề', _titleController, widget),
                MyInputField(
                  'Ngày',
                  DateFormat('yyyy-MM-dd').format(_selectedDate),
                  _dateController,
                  widget,
                  isDatePicker: true,
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _selectedDate = pickedDate;
                        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
                      });
                    }
                  },
                ),
                MyInputField(
                  'Thời gian',
                  _timeController.text,
                  _timeController,
                  widget,
                  isDatePicker: false,
                  onTap: () async {
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: _startTime,
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _startTime = pickedTime;
                        _timeController.text = _startTime.format(context);
                      });
                    }
                  },
                ),
                MyInputField('Địa điểm', 'Nhập địa điểm', _placeController, widget),
                MyInputField('Chủ trì', 'Nhập người chủ trì', _presideController, widget),
                MyInputField('Ghi chú', 'Nhập ghi chú', _noteController, widget),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _updateTask() async {
    print(widget.task.idTask!);
    if (_formKey.currentState!.validate()) {
      Task updatedTask = Task(
        idTask: widget.task.idTask!,
        date: _dateController.text,
        content: _titleController.text,
        time: _timeController.text,
        place: _placeController.text,
        preside: _presideController.text,
        note: _noteController.text,
        complete: widget.task.complete,
      );

      final DatabaseHelper databaseHelper = DatabaseHelper();
      await databaseHelper.updateTask(widget.task.idTask!, updatedTask); // Giả sử bạn có id cho mỗi Task

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Nhiệm vụ đã được cập nhật!')));
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
            (Route<dynamic> route) => false,
      );
    }
  }
}
