import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../data/sqlite.dart';
import '../model/task_model.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  late final List<Task> tasks;
  int completedTasks = 0;
  int uncompletedTasks = 0;
  int overdueTasks = 0;
  int inProgressTasks = 0;
  int doneTasks = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getListTask();
  }

  void _getListTask() async{
    final DatabaseHelper databaseHelper = DatabaseHelper();
    tasks = await databaseHelper.getAllTasks();

    setState(() {
      completedTasks = tasks.where((task) => task.complete).length;
      uncompletedTasks = tasks.where((task) => !task.complete).length;
      overdueTasks = tasks.where((task) => !task.complete && DateTime.parse(task.date).isBefore(DateTime.now())).length;
      inProgressTasks = tasks.where((task) => !task.complete && DateTime.parse(task.date).isAfter(DateTime.now())).length;
      doneTasks = completedTasks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Thống kê'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTaskCard(
                    title: "Đã hoàn thành",
                    count: completedTasks,
                    color: Colors.blue.shade700,
                  ),
                  _buildTaskCard(
                    title: "Chưa hoàn thành",
                    count: uncompletedTasks,
                    color: Colors.orange.shade800,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: PieChart(
                PieChartData(
                  sections: _buildPieChartSections(overdueTasks, inProgressTasks, doneTasks),
                  centerSpaceRadius: 60, // Tùy chỉnh khoảng trắng giữa biểu đồ
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Thêm chú thích cho biểu đồ
            _buildLegend(),

            const SizedBox(height: 70),
          ],
        ),
      ),
    );
  }

  // Widget tạo các ô vuông hiển thị số Task
  Widget _buildTaskCard({required String title, required int count, required Color color}) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Tạo các phần cho biểu đồ hình tròn
  List<PieChartSectionData> _buildPieChartSections(int overdueTasks, int inProgressTasks, int doneTasks) {
    final total = overdueTasks + inProgressTasks + doneTasks;
    if (total == 0) {
      return []; // Nếu không có task nào thì trả về rỗng
    }

    return [
      PieChartSectionData(
        color: Colors.red,
        value: (overdueTasks / total) * 100,
        title: '$overdueTasks',
        radius: 50,
        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: Colors.yellow,
        value: (inProgressTasks / total) * 100,
        title: '$inProgressTasks',
        radius: 50,
        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
      ),
      PieChartSectionData(
        color: Colors.blue,
        value: (doneTasks / total) * 100,
        title: '$doneTasks',
        radius: 50,
        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ];
  }

  // Widget tạo chú thích (legend) cho biểu đồ hình tròn
  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendItem(color: Colors.red, text: 'Quá hạn'),
        _buildLegendItem(color: Colors.yellow, text: 'Đang thực hiện'),
        _buildLegendItem(color: Colors.blue, text: 'Đã thực hiện'),
      ],
    );
  }

  // Widget tạo 1 item trong legend
  Widget _buildLegendItem({required Color color, required String text}) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 16)),
      ],
    );
  }

}
