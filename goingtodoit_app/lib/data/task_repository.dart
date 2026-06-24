import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../core/task_model.dart';

class TaskRepository extends ChangeNotifier {
  TaskRepository._internal();
  static final TaskRepository _instance = TaskRepository._internal();
  factory TaskRepository() => _instance;

  static const _fileName = 'tasks.json';
  List<Task> _tasks = [];
  bool _initialized = false;

  /// Initializes the shared repository. Safe to call multiple times.
  static Future<void> init() => _instance._init();

  Future<void> _init() async {
    if (_initialized) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_fileName');
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> raw = jsonDecode(content);
        _tasks =
            raw.map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('TaskRepository init error: $e');
      _tasks = [];
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> _save() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_fileName');
      final raw = _tasks.map((t) => t.toJson()).toList();
      await file.writeAsString(jsonEncode(raw));
    } catch (e) {
      debugPrint('TaskRepository save error: $e');
    }
  }

  Future<void> addTask(Task task) async {
    await _init();
    _tasks.add(task);
    await _save();
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    await _init();
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx >= 0) {
      _tasks[idx] = task;
      await _save();
      notifyListeners();
    }
  }

  Future<void> deleteTask(String id) async {
    await _init();
    _tasks.removeWhere((t) => t.id == id);
    await _save();
    notifyListeners();
  }

  List<Task> getAllTasks() => List.unmodifiable(_tasks);

  Task? getTask(String id) {
    try {
      return _tasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }
}
