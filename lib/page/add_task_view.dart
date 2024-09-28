import 'package:daily_planner/config/next_screen.dart';
import 'package:daily_planner/page/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../data/sqlite.dart';
import '../model/task_model.dart';

class AddTaskPage extends StatefulWidget {
  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _placeController = TextEditingController();
  final _presideController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final _timeController = TextEditingController();
  TimeOfDay _startTime = const TimeOfDay(hour: 11, minute: 15);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Đặt giá trị cho _dateController
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
    _timeController.text = _startTime.format(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm Nhiệm vụ'),
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
                  isDatePicker: false, // Thay đổi thành false
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

                Padding(
                  padding: const EdgeInsets.only(top: 18.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        Task newTask = Task(
                          date: _dateController.text,
                          content: _titleController.text,
                          time: _timeController.text,
                          place: _placeController.text,
                          preside: _presideController.text,
                          note: _noteController.text,
                          complete: false,
                        );
                        final DatabaseHelper databaseHelper = DatabaseHelper();
                        await databaseHelper.insertTask(newTask);

                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Nhiệm vụ đã được tạo!')));

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                              (Route<dynamic> route) => false,
                        );
                      }
                    },
                    child: Text('Tạo Nhiệm vụ'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyInputField extends StatelessWidget {
  final String title;
  final String hint;
  final TextEditingController? controller;
  final Widget widget;
  final VoidCallback? onTap; // Thêm onTap vào constructor
  final bool isDatePicker; // Thêm biến để xác định đây có phải là trường chọn ngày không

  const MyInputField(
      this.title,
      this.hint,
      this.controller,
      this.widget, {
        this.onTap,
        this.isDatePicker = false,
        super.key,
      });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          GestureDetector( // Thêm GestureDetector để bắt sự kiện nhấn
            onTap: onTap, // Cho phép chọn ngày hoặc thời gian
            child: Container(
              height: 52,
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.only(left: 14, right: 40), // Thêm padding bên phải để tránh che icon
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      autofocus: false,
                      cursorColor: Colors.grey,
                      controller: controller,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                      decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.grey[400]),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                            width: 0,
                          ),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                            width: 0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (title == 'Ngày') // Hiển thị icon lịch nếu trường là "Ngày"
                    Icon(Icons.calendar_today),
                  if (title == 'Thời gian') // Hiển thị icon đồng hồ nếu trường là "Thời gian"
                    Icon(Icons.access_time),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
