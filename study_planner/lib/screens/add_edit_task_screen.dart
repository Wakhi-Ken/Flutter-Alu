import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../storage/task_storage.dart';

/// Screen to add or edit a task.
///
/// Lets user specify title, description, due date/time, and optional reminder.
class AddEditTaskScreen extends StatefulWidget {
  final Task? task;
  const AddEditTaskScreen({super.key, this.task});

  @override
  AddEditTaskScreenState createState() => AddEditTaskScreenState();
}

class AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  String? _description;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  bool _reminderEnabled = false;
  TimeOfDay? _reminderTime;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
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
      _title = '';
      _description = '';
      final now = DateTime.now();
      _dueDate = DateTime(now.year, now.month, now.day);
      _dueTime = TimeOfDay(hour: now.hour, minute: now.minute);
      _reminderEnabled = false;
      _reminderTime = null;
    }
  }

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

  Future<void> _save() async {
    if (_formKey.currentState?.validate() ?? false) {
      final due = DateTime(
        _dueDate!.year,
        _dueDate!.month,
        _dueDate!.day,
        (_dueTime ?? TimeOfDay.now()).hour,
        (_dueTime ?? TimeOfDay.now()).minute,
      );
      final reminder = _reminderEnabled && _reminderTime != null
          ? DateTime(
              _dueDate!.year,
              _dueDate!.month,
              _dueDate!.day,
              _reminderTime!.hour,
              _reminderTime!.minute,
            )
          : null;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _save)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Title'),
                initialValue: _title,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _title = value;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                initialValue: _description,
                onChanged: (value) {
                  setState(() {
                    _description = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text('Due Date: ${DateFormat.yMd().format(_dueDate!)}'),
                subtitle: Text('Tap to change'),
                trailing: const Icon(Icons.event),
                onTap: _pickDueDate,
              ),
              ListTile(
                title: Text(
                  'Due Time: ${(_dueTime ?? TimeOfDay.now()).format(context)}',
                ),
                subtitle: const Text('Tap to change'),
                trailing: const Icon(Icons.schedule),
                onTap: _pickDueTime,
              ),
              SwitchListTile(
                title: const Text('Enable Reminder'),
                value: _reminderEnabled,
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
                  ),
                  subtitle: const Text('Tap to change'),
                  trailing: const Icon(Icons.alarm),
                  onTap: _pickReminderTime,
                ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _save, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}
