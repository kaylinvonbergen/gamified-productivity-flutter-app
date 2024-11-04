import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() => runApp(TaskManagerApp());


class TaskManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: ThemeData.dark(),
      home: TaskManagerScreen(),
    );
  }
}

class Task {
  String name;
  DateTime date;
  Color color;
  String description;
  bool isCompleted;

  Task({
    required this.name,
    required this.date,
    required this.color,
    required this.description,
    this.isCompleted = false,
  });
}

class TaskManagerScreen extends StatefulWidget {
  @override
  _TaskManagerScreenState createState() => _TaskManagerScreenState();
}

class _TaskManagerScreenState extends State<TaskManagerScreen> {
  final List<Task> _tasks = [];
  final _formKey = GlobalKey<FormState>();
  int _points = 0; // Points counter
  String _name = '';
  String _description = '';
  DateTime _selectedDate = DateTime.now();
  Color _selectedColor = Colors.red;

  final List<Color> _colorOptions = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
  ];

  void _addTask() {
    if (_formKey.currentState!.validate()) {  
      _formKey.currentState!.save();
      setState(() { 
        _tasks.add(Task( // sets values
          name: _name,
          date: _selectedDate,
          color: _selectedColor,
          description: _description,
        ));
        _tasks.sort((a, b) => a.date.compareTo(b.date)); // sort in the list (duh)
      });
      Navigator.of(context).pop();
    }
  }

  void _openNewTaskForm(BuildContext context) { // "new task form" is the popup
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Task Name'), // cant be empty
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a task name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _name = value!;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Task Description'), // can be empty
                  onSaved: (value) {
                    _description = value ?? '';
                  },
                ),
                ListTile(
                  title: Text(
                    'Task Date: ${DateFormat.yMd().format(_selectedDate)}',
                  ),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(), //cant be before today
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null && pickedDate != _selectedDate) {
                      setState(() {
                        _selectedDate = pickedDate;
                      });
                    }
                  },
                ),
                DropdownButtonFormField<Color>(
                  alignment: Alignment.center, // doesn't do anything? i don't think?
                  value: _selectedColor,
                  decoration: InputDecoration(labelText: 'Task Color'),
                  items: _colorOptions.map((Color color) {
                    // double screenWidth = MediaQuery.of(context).size.width;
                    return DropdownMenuItem(
                      alignment: Alignment.center,
                      value: color,
                      child: Container(
                        width: 20, // decided this looks best for now, when i have time i'll make this look better its kinda yuck
                        height: 20,
                        color: color,
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedColor = newValue!;
                    });
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addTask,
                  child: Text('Add Task'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmTaskCompletion(int index) async {
    final task = _tasks[index];

    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Task Completed?'),
        content: Text('Are you sure you completed "${task.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // confirmed
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // confirmed
            child: Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _tasks.removeAt(index);
        _points += 10; // for now each task is worth ten
      });
    }
  }

  void _redeemPoints() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Redeem Points'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRedeemOption(
                  10, 'One hour of free time', 'Enjoy one hour of free time!'),
              _buildRedeemOption(
                  50, 'Go do something fun', 'Get out of the house and do something interesting!'),
              _buildRedeemOption(70, 'Treat yourself!',
                  'Order delivery, get dessert, go to the nail salon, or buy something cool!'),
              _buildRedeemOption(
                  120, 'Free day', 'Take a whole day off to relax!'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRedeemOption(int cost, String title, String successMessage) {
    return ListTile(
      title: Text(title),
      subtitle: Text('Costs $cost points'),
      trailing: ElevatedButton(
        onPressed: _points >= cost
            ? () {
                setState(() {
                  _points -= cost;
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(successMessage)),
                );
              }
            : null,
        child: Text('Redeem'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Earn points for being productive!'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Points: $_points',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: task.color, width: 2.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: ListTile(
                    leading: Checkbox(
                      value: task.isCompleted,
                      onChanged: (value) {
                        if (value == true) {
                          _confirmTaskCompletion(index);
                        }
                      },
                    ),
                    title: Text(
                      task.name,
                   
                    ),
                    subtitle: Text(DateFormat.yMd().format(task.date)),
                    trailing: Text(task.description),
                  ),
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 56.0,
                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: _redeemPoints,
                    child: Text('Redeem Points'),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 56.0,
                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: () => _openNewTaskForm(context),
                    child: Text('+ Add Task'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

