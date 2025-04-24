import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/firebase_service.dart';
import 'models/time_record.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initializeFirebase();
  runApp(MyApp());
}

final ButtonStyle orangeButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: Colors.orange,
  foregroundColor: Colors.white,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
    side: BorderSide(color: Colors.orange),
  ),
  padding: EdgeInsets.symmetric(vertical: 14),
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Time Tracker',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: NewRecordPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class NewRecordPage extends StatefulWidget {
  @override
  State<NewRecordPage> createState() => _NewRecordPageState();
}

class _NewRecordPageState extends State<NewRecordPage> {
  List<String> _projects = [];
  List<String> _tasks = [];

  String? _selectedProject;
  String? _selectedTask;
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  TextEditingController userInfoController = TextEditingController();
  TextEditingController durationController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProjectsAndTasks();
  }

  Future<void> loadProjectsAndTasks() async {
    final projectSnapshot = await FirebaseFirestore.instance.collection('projects').get();
    final taskSnapshot = await FirebaseFirestore.instance.collection('tasks').get();

    setState(() {
      _projects = projectSnapshot.docs.map((doc) => doc['name'].toString()).toList();
      _tasks = taskSnapshot.docs.map((doc) => doc['name'].toString()).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit New Record'),
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ManageProjectsPage()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: userInfoController,
              decoration: InputDecoration(
                hintText: 'Ajouter titre',
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedProject,
              hint: Text("Select a Project"),
              onChanged: (value) => setState(() => _selectedProject = value),
              items: _projects.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedTask,
              hint: Text("Select a Task"),
              onChanged: (value) => setState(() => _selectedTask = value),
              items: _tasks.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            ),
            const SizedBox(height: 16),
            buildDatePicker(),
            const SizedBox(height: 16),
            buildTimePicker("Start Time", _startTime, (t) => setState(() => _startTime = t)),
            const SizedBox(height: 16),
            buildTimePicker("End Time", _endTime, (t) => setState(() => _endTime = t)),
            const SizedBox(height: 16),
            TextField(
              controller: durationController,
              decoration: InputDecoration(
                labelText: 'Duration',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Note:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveRecord,
                style: orangeButtonStyle,
                child: Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) setState(() => _selectedDate = picked);
      },
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: Colors.black),
          SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                _selectedDate == null ? '8:2018' : DateFormat('MM:yyyy').format(_selectedDate!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTimePicker(String label, TimeOfDay? selectedTime, Function(TimeOfDay) onTimePicked) {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: selectedTime ?? TimeOfDay.now(),
        );
        if (picked != null) onTimePicked(picked);
      },
      child: Row(
        children: [
          Icon(Icons.access_time, color: Colors.black),
          SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                selectedTime == null ? '5:12' : selectedTime.format(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> saveRecord() async {
    final timeRecord = TimeRecord(
      project: _selectedProject,
      task: _selectedTask,
      date: _selectedDate,
      startTime: _startTime?.format(context),
      endTime: _endTime?.format(context),
      duration: durationController.text,
      note: noteController.text,
    );

    try {
      await FirebaseService.saveTimeRecord(timeRecord.toMap());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Données sauvegardées avec succès!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
    }
  }
}

class ManageProjectsPage extends StatefulWidget {
  @override
  _ManageProjectsPageState createState() => _ManageProjectsPageState();
}

class _ManageProjectsPageState extends State<ManageProjectsPage> {
  final TextEditingController _projectController = TextEditingController();
  final TextEditingController _taskController = TextEditingController();

  Future<void> _addEntry(String type, String name) async {
    if (name.isNotEmpty) {
      await FirebaseFirestore.instance.collection(type).add({'name': name});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$type ajouté avec succès')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ajouter Projet/Tâche'), backgroundColor: Colors.orange),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _projectController,
              decoration: InputDecoration(labelText: "Nouveau projet"),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _addEntry('projects', _projectController.text),
              style: orangeButtonStyle,
              child: Text("Ajouter Projet"),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _taskController,
              decoration: InputDecoration(labelText: "Nouvelle tâche"),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _addEntry('tasks', _taskController.text),
              style: orangeButtonStyle,
              child: Text("Ajouter Tâche"),
            ),
          ],
        ),
      ),
    );
  }
}
