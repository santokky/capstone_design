import 'package:flutter/material.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  final List<Todo> _todos = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  int _completedCount = 0;
  String _searchQuery = '';

  void _addTodo() {
    setState(() {
      _todos.add(Todo(
        title: _titleController.text,
        description: _descriptionController.text,
        date: DateTime.now(),
        isCompleted: false,
      ));
      _titleController.clear();
      _descriptionController.clear();
    });
    Navigator.of(context).pop();
  }

  void _showAddTodoDialog({Todo? todo, int? index}) {
    if (todo != null) {
      _titleController.text = todo.title;
      _descriptionController.text = todo.description;
    } else {
      _titleController.clear();
      _descriptionController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          scrollable: true,
          title: const Text("나의 할일"),
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(hintText: "글 제목"),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(hintText: "글 내용"),
                ),
              ],
            ),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (todo != null && index != null) {
                    _editTodo(index);
                  } else {
                    _addTodo();
                  }
                },
                child: Text(todo != null ? "수정 하기" : "추가 하기"),
              ),
            ),
          ],
        );
      },
    );
  }

  void _editTodo(int index) {
    setState(() {
      _todos[index].title = _titleController.text;
      _todos[index].description = _descriptionController.text;
    });
    Navigator.of(context).pop();
  }

  void _toggleCompletion(int index) {
    setState(() {
      _todos[index].isCompleted = !_todos[index].isCompleted;
      _completedCount = _todos.where((todo) => todo.isCompleted).length;
    });
  }

  void _searchTodos(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    double progress = _todos.isEmpty ? 0 : _completedCount / _todos.length;
    final filteredTodos = _todos.where((todo) {
      return todo.title.contains(_searchQuery) ||
          todo.description.contains(_searchQuery);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('이벤트'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: "일정 검색",
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: _searchTodos,
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredTodos.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    leading: Checkbox(
                      value: filteredTodos[index].isCompleted,
                      onChanged: (bool? value) {
                        _toggleCompletion(index);
                      },
                    ),
                    title: Text(
                      filteredTodos[index].title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: filteredTodos[index].isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          filteredTodos[index].description,
                          style: TextStyle(
                              color: filteredTodos[index].isCompleted
                                  ? Colors.grey
                                  : Colors.black54),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '등록 일시: ${filteredTodos[index].date}',
                          style: const TextStyle(color: Colors.black45),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.green),
                          onPressed: () {
                            _showAddTodoDialog(
                                todo: filteredTodos[index], index: index);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () {
                            setState(() {
                              if (filteredTodos[index].isCompleted) {
                                _completedCount--;
                              }
                              _todos.remove(filteredTodos[index]);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoDialog(),
        backgroundColor: Colors.blueAccent,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}

class Todo {
  String title;
  String description;
  DateTime date;
  bool isCompleted;

  Todo({
    required this.title,
    required this.description,
    required this.date,
    this.isCompleted = false,
  });
}
