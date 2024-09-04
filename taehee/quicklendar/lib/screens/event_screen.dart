import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database_helper.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  List<Map<String, dynamic>> _events = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();
  TextEditingController _searchController = TextEditingController();
  bool _showProgress = false;
  List<bool> _checked = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _searchController.addListener(_filterEvents);
  }

  Future<void> _loadEvents() async {
    final events = await _dbHelper.queryAllEvents();
    setState(() {
      _events = events;
      _checked = List<bool>.filled(_events.length, false);
      _updateProgress();
    });
  }

  void _filterEvents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _events = _events.where((event) {
        final title = event['title'].toLowerCase();
        final description = event['description'].toLowerCase();
        return title.contains(query) || description.contains(query);
      }).toList();
    });
  }

  void _updateProgress() {
    final checkedCount = _checked.where((element) => element).length;
    setState(() {
      _showProgress = checkedCount > 0;
    });
  }

  Future<void> _deleteEvent(int id) async {
    await _dbHelper.deleteEvent(id);
    await _loadEvents();
  }

  Future<void> _editEvent(int id, String newTitle, String newDescription) async {
    await _dbHelper.updateEvent(id, newTitle, newDescription);
    await _loadEvents();
  }

  void _showEditDialog(int id, String currentTitle, String currentDescription) {
    final titleController = TextEditingController(text: currentTitle);
    final descriptionController = TextEditingController(text: currentDescription);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(hintText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(hintText: 'Description'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                await _editEvent(id, titleController.text, descriptionController.text);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('이벤트 목록'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: '이벤트 검색',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          if (_showProgress)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: LinearProgressIndicator(color: Colors.blueAccent, value: _checked.where((element) => element).length / _events.length),
            ),
          Expanded(
            child: _events.isEmpty
                ? Center(
              child: Text(
                '이벤트가 없습니다.',
                style: TextStyle(fontSize: 24.0),
              ),
            )
                : ListView.builder(
              itemCount: _events.length,
              itemBuilder: (context, index) {
                final event = _events[index];
                final date = DateTime.parse(event['date']);
                final formattedDate = DateFormat.yMMMd().format(date);
                return ListTile(
                  leading: Checkbox(
                    activeColor: Colors.blueAccent,
                    checkColor: Colors.white,
                    value: _checked[index],
                    onChanged: (bool? value) {
                      setState(() {
                        _checked[index] = value!;
                        _updateProgress();
                      });
                    },
                  ),
                  title: Text(event['title']),
                  subtitle: Text(event['description']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(formattedDate),
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.lightGreen),
                        onPressed: () {
                          _showEditDialog(event['id'], event['title'], event['description']);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () async {
                          await _deleteEvent(event['id']);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
