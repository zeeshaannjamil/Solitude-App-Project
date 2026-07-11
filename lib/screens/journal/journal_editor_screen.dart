import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/colors.dart';
import '../../../models/journal_model.dart';
import '../../../providers/journal_provider.dart';

class JournalEditorScreen extends StatefulWidget {
  final JournalModel? existingJournal;

  const JournalEditorScreen({super.key, this.existingJournal});

  @override
  State<JournalEditorScreen> createState() => _JournalEditorScreenState();
}

class _JournalEditorScreenState extends State<JournalEditorScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  String _selectedMood = 'Happy';
  String _selectedEmoji = '😊';
  String _selectedCategory = 'General';

  final List<Map<String, String>> _moods = [
    {'mood': 'Happy', 'emoji': '😊'},
    {'mood': 'Calm', 'emoji': '😌'},
    {'mood': 'Focused', 'emoji': '🎯'},
    {'mood': 'Stressed', 'emoji': '😫'},
    {'mood': 'Sad', 'emoji': '😢'},
  ];

  final List<String> _categories = [
    'General', 'Work', 'Study', 'Personal', 'Ideas'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingJournal != null) {
      _titleController.text = widget.existingJournal!.title;
      _descController.text = widget.existingJournal!.description;
      _selectedMood = widget.existingJournal!.mood;
      _selectedEmoji = widget.existingJournal!.emoji;
      _selectedCategory = widget.existingJournal!.category;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _saveEntry() {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();

    if (title.isEmpty && desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title or description.')),
      );
      return;
    }

    final provider = Provider.of<JournalProvider>(context, listen: false);
    final now = DateTime.now();

    if (widget.existingJournal == null) {
      // Create new
      final newJournal = JournalModel(
        id: '', // Firestore assigns ID
        title: title,
        description: desc,
        mood: _selectedMood,
        emoji: _selectedEmoji,
        category: _selectedCategory,
        createdAt: now,
        updatedAt: now,
      );
      provider.addJournal(newJournal);
    } else {
      // Update
      final updatedJournal = widget.existingJournal!.copyWith(
        title: title,
        description: desc,
        mood: _selectedMood,
        emoji: _selectedEmoji,
        category: _selectedCategory,
        updatedAt: now,
      );
      provider.updateJournal(updatedJournal);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.existingJournal != null;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(isEditing ? "Edit Journal" : "New Journal"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded, color: AppColors.primary),
            onPressed: _saveEntry,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Input
            TextField(
              controller: _titleController,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: "Title",
                border: InputBorder.none,
              ),
            ),
            const Divider(),

            // Mood & Category Selectors
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedMood,
                    decoration: InputDecoration(
                      labelText: "Mood",
                      filled: true,
                      fillColor: theme.cardColor,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                    items: _moods.map((m) {
                      return DropdownMenuItem(
                        value: m['mood'],
                        child: Text("${m['emoji']} ${m['mood']}"),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedMood = val;
                          _selectedEmoji = _moods.firstWhere((m) => m['mood'] == val)['emoji']!;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: "Category",
                      filled: true,
                      fillColor: theme.cardColor,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                    items: _categories.map((c) {
                      return DropdownMenuItem(value: c, child: Text(c));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategory = val);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Description Input
            TextField(
              controller: _descController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              style: const TextStyle(fontSize: 16, height: 1.5),
              decoration: const InputDecoration(
                hintText: "Write your thoughts here...",
                border: InputBorder.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
