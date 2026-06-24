import 'package:flutter/material.dart';
import 'core/task_model.dart';
import 'data/task_repository.dart';
import 'features/task_creation/task_creation_screen.dart';
import 'features/deadline/deadline_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TaskRepository.init();
  await DeadlineHandler.init();
  // Reschedule all pending tasks on startup.
  for (final task in TaskRepository().getAllTasks()) {
    if (!task.isCompleted) {
      await DeadlineHandler.schedule(task);
    }
  }
  runApp(const GoingToDoItApp());
}

class GoingToDoItApp extends StatelessWidget {
  const GoingToDoItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoingToDoIt',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TaskListScreen(),
    );
  }
}

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = TaskRepository();
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([repo]),
        builder: (context, _) {
          final tasks = repo.getAllTasks();
          if (tasks.isEmpty) {
            return const Center(child: Text('No tasks yet. Tap + to add one.'));
          }
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return ListTile(
                title: Text(task.title),
                subtitle: Text(
                  'Due: ${task.dueDate.toString()}\n'
                  'Missed: ${task.missedCount} time(s)',
                ),
                trailing: task.isCompleted
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : IconButton(
                        icon: const Icon(Icons.play_arrow),
                        onPressed: () => _launchTask(context, task),
                      ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TaskCreationScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _launchTask(BuildContext context, Task task) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Launching: ${task.title}')),
    );
  }
}
