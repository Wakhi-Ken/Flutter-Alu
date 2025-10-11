import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../storage/storage.dart';

class AddEditTaskScreen extends StatefulWidget {
  final Task? task;
  const AddEditTaskScreen({super.key, this.task});

  @override
  AddEditTaskScreenState createState() => AddEditTaskScreenState();
}

// State for AddEditTaskScreen
class AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  String? _description;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  bool _reminderEnabled = false;
  TimeOfDay? _reminderTime;
  //
  final Color _iconColor = const Color(0xFF0051FF); // Blue icons
  final Color _textColor = Colors.white; // White text

  @override
  // Initialize state
  void initState() {
    super.initState();
    final t = widget.task;
    // If editing an existing task, populate fields
    if (t != null) {
      _title = t.title;
      _description = t.description;
      _dueDate = DateTime(t.dueDate.year, t.dueDate.month, t.dueDate.day);
      _dueTime = TimeOfDay(hour: t.dueDate.hour, minute: t.dueDate.minute);
      _reminderEnabled = t.reminder != null;
      _reminderTime = t.reminder != null
          ? TimeOfDay(hour: t.reminder!.hour, minute: t.reminder!.minute)
          : null;
    } else {
      //
      _title = '';
      _description = '';
      final now = DateTime.now();
      _dueDate = DateTime(now.year, now.month, now.day);
      _dueTime = TimeOfDay(hour: now.hour, minute: now.minute);
      _reminderEnabled = false;
      _reminderTime = null;
    }
  }

  /// Pick due date
  Future<void> _pickDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        _dueDate = date;
      });
    }
  }

  /// Pick due time
  Future<void> _pickDueTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        _dueTime = time;
      });
    }
  }

  /// Pick reminder time
  Future<void> _pickReminderTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? (_dueTime ?? TimeOfDay.now()),
    );
    if (time != null) {
      setState(() {
        _reminderTime = time;
      });
    }
  }

  /// Save task
  Future<void> _save() async {
    if (_formKey.currentState?.validate() ?? false) {
      final due = DateTime(
        _dueDate!.year,
        _dueDate!.month,
        _dueDate!.day,
        (_dueTime ?? TimeOfDay.now()).hour,
        (_dueTime ?? TimeOfDay.now()).minute,
      );

      // If reminder is enabled, set reminder datetime
      final reminder = _reminderEnabled && _reminderTime != null
          ? DateTime(
              _dueDate!.year,
              _dueDate!.month,
              _dueDate!.day,
              _reminderTime!.hour,
              _reminderTime!.minute,
            )
          : null;
      // Create or update task
      final task = Task(
        id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch,
        title: _title,
        description: _description,
        dueDate: due,
        reminder: reminder,
      );
      if (widget.task != null) {
        await TaskStorage.updateTask(task);
      } else {
        await TaskStorage.addTask(task);
      }
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  // Build UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1B1B), // Dark background
      appBar: AppBar(
        title: Text(
          widget.task == null ? 'Add Task' : 'Edit Task',
          style: TextStyle(color: _textColor),
        ),
        backgroundColor: const Color.fromARGB(255, 2, 5, 175),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        iconTheme: IconThemeData(
          color: const Color.fromARGB(255, 255, 255, 255),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            color: const Color.fromARGB(255, 255, 255, 255),
            onPressed: _save,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                style: TextStyle(color: _textColor),
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: TextStyle(color: _iconColor),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: _iconColor),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: _iconColor),
                  ),
                ),
                initialValue: _title,
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Please enter a title'
                    : null,
                onChanged: (value) => setState(() => _title = value),
              ),
              TextFormField(
                style: TextStyle(color: _textColor),
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: _iconColor),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: _iconColor),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: _iconColor),
                  ),
                ),
                initialValue: _description,
                onChanged: (value) => setState(() => _description = value),
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(
                  'Due Date: ${DateFormat.yMd().format(_dueDate!)}',
                  style: TextStyle(color: _textColor),
                ),
                subtitle: Text(
                  'Tap to change',
                  style: TextStyle(color: Colors.white70),
                ),
                trailing: Icon(Icons.event, color: _iconColor),
                onTap: _pickDueDate,
              ),
              ListTile(
                title: Text(
                  'Due Time: ${(_dueTime ?? TimeOfDay.now()).format(context)}',
                  style: TextStyle(color: _textColor),
                ),
                subtitle: Text(
                  'Tap to change',
                  style: TextStyle(color: Colors.white70),
                ),
                trailing: Icon(Icons.schedule, color: _iconColor),
                onTap: _pickDueTime,
              ),
              SwitchListTile(
                title: Text(
                  'Enable Reminder',
                  style: TextStyle(color: _textColor),
                ),
                value: _reminderEnabled,
                activeColor: _iconColor,
                onChanged: (v) {
                  setState(() {
                    _reminderEnabled = v;
                    if (v && _reminderTime == null) {
                      _reminderTime = _dueTime ?? TimeOfDay.now();
                    }
                  });
                },
              ),
              if (_reminderEnabled)
                ListTile(
                  title: Text(
                    'Reminder Time: ${(_reminderTime ?? (_dueTime ?? TimeOfDay.now())).format(context)}',
                    style: TextStyle(color: _textColor),
                  ),
                  subtitle: Text(
                    'Tap to change',
                    style: TextStyle(color: Colors.white70),
                  ),
                  trailing: Icon(Icons.alarm, color: _iconColor),
                  onTap: _pickReminderTime,
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _iconColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _save,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
