import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/task_model.dart';
import '../../data/task_repository.dart';
import '../../features/deadline/deadline_handler.dart';
import '../../features/deep_links/deep_link_handler.dart';

class TaskCreationScreen extends StatefulWidget {
  const TaskCreationScreen({super.key});

  @override
  State<TaskCreationScreen> createState() => _TaskCreationScreenState();
}

class _TaskCreationScreenState extends State<TaskCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contactController = TextEditingController();
  DateTime? _dueDate;
  TaskType _type = TaskType.general;
  bool _isFullForce = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(now.add(const Duration(minutes: 10))),
      );
      if (time != null) {
        setState(() {
          _dueDate = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
        });
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields.')),
      );
      return;
    }

    final repo = TaskRepository();
    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      contactName: _contactController.text.trim().isNotEmpty ? 'Contact' : null,
      contactValue: _contactController.text.trim().isEmpty ? null : _contactController.text.trim(),
      type: _type,
      dueDate: _dueDate!,
      isFullForce: _isFullForce,
    );

    await repo.addTask(task);
    await DeadlineHandler.schedule(task);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task created.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('yyyy-MM-dd HH:mm');
    return Scaffold(
      appBar: AppBar(title: const Text('New Task')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Task title'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contactController,
                decoration: InputDecoration(
                  labelText: _type == TaskType.email
                      ? 'Email address'
                      : _type == TaskType.call || _type == TaskType.sms
                          ? 'Phone number'
                          : 'Contact (optional)',
                ),
                validator: (v) {
                  if (_type == TaskType.call || _type == TaskType.sms) {
                    if (v == null || v.trim().isEmpty) return 'Required for this type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<TaskType>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Task type'),
                items: const [
                  DropdownMenuItem(value: TaskType.general, child: Text('General')),
                  DropdownMenuItem(value: TaskType.call, child: Text('Call')),
                  DropdownMenuItem(value: TaskType.email, child: Text('Email')),
                  DropdownMenuItem(value: TaskType.sms, child: Text('SMS')),
                  DropdownMenuItem(value: TaskType.calendar, child: Text('Calendar')),
                ],
                onChanged: (v) => setState(() => _type = v ?? TaskType.general),
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(_dueDate == null
                    ? 'Pick deadline'
                    : 'Deadline: ${dateFmt.format(_dueDate!)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              SwitchListTile(
                title: const Text('Full Force at deadline'),
                subtitle: const Text(
                    'Launches the deep link immediately when the time comes.'),
                value: _isFullForce,
                onChanged: (v) => setState(() => _isFullForce = v),
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _save, child: const Text('Save Task')),
            ],
          ),
        ),
      ),
    );
  }
}
