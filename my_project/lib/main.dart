import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:Todo/models/todo.dart';
import 'package:Todo/utils/todo_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TodoAdapter());
  await Hive.openBox<Todo>('mybox');

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _controller = TextEditingController();
  final Box<Todo> todoBox = Hive.box<Todo>('mybox');

  void addTodo() {
    final todo = Todo(title: _controller.text);
    todoBox.add(todo);
    _controller.clear();
  }

  void toggleTodoStatus(int index) {
    final todo = todoBox.getAt(index);
    todo?.isCompleted = !(todo.isCompleted);
    todo?.save();
  }

  void deleteTodo(int index) {
    todoBox.deleteAt(index);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.deepPurple.shade300,
        appBar: AppBar(
          title: const Text('Todo App'),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
        body: ValueListenableBuilder(
          valueListenable: todoBox.listenable(),
          builder: (context, Box<Todo> box, _) {
            return ListView.builder(
              itemCount: box.length,
              itemBuilder: (context, index) {
                final todo = box.getAt(index);
                return ToDoList(
                  taskName: todo!.title,
                  taskCompleted: todo.isCompleted,
                  onChanged: (_) => toggleTodoStatus(index),
                  deleteFunction: (_) => deleteTodo(index),
                );
              },
            );
          },
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Add a new todo item',
                      filled: true,
                      fillColor: Colors.deepPurple.shade200,
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.deepPurple),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.deepPurple),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ),
              FloatingActionButton(
                onPressed: addTodo,
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
