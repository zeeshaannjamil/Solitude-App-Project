import 'dart:async';
import 'package:flutter/material.dart';
import '../models/journal_model.dart';
import '../services/journal_service.dart';

enum JournalSortOption { newest, oldest, alphabetical }

class JournalProvider extends ChangeNotifier {
  final JournalService _journalService = JournalService();
  StreamSubscription<List<JournalModel>>? _subscription;

  List<JournalModel> _allJournals = [];
  List<JournalModel> _filteredJournals = [];
  bool _isLoading = true;
  String? _errorMessage;

  String _searchQuery = '';
  JournalSortOption _sortOption = JournalSortOption.newest;
  String? _filterMood;
  String? _filterCategory;
  String? _filterTime; // 'Today', 'Yesterday', 'This Week', 'This Month'

  List<JournalModel> get journals => _filteredJournals;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Statistics
  int get totalEntries => _allJournals.length;
  
  int get entriesThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return _allJournals.where((j) => j.createdAt.isAfter(startOfWeek)).length;
  }
  
  int get entriesThisMonth {
    final now = DateTime.now();
    return _allJournals.where((j) => j.createdAt.year == now.year && j.createdAt.month == now.month).length;
  }

  String get mostUsedMood {
    if (_allJournals.isEmpty) return "None";
    final moodCounts = <String, int>{};
    for (var j in _allJournals) {
      moodCounts[j.mood] = (moodCounts[j.mood] ?? 0) + 1;
    }
    return moodCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  JournalProvider() {
    _initListener();
  }

  void _initListener() {
    _isLoading = true;
    notifyListeners();

    _subscription = _journalService.getJournalsStream().listen(
      (journals) {
        _allJournals = journals;
        _isLoading = false;
        _applyFiltersAndSort();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> addJournal(JournalModel journal) async {
    try {
      await _journalService.addJournal(journal);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateJournal(JournalModel journal) async {
    try {
      await _journalService.updateJournal(journal);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteJournal(String id) async {
    try {
      await _journalService.deleteJournal(id);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Filtering & Sorting
  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    _applyFiltersAndSort();
  }

  void setSortOption(JournalSortOption option) {
    _sortOption = option;
    _applyFiltersAndSort();
  }

  void setFilters({String? mood, String? category, String? time}) {
    _filterMood = mood;
    _filterCategory = category;
    _filterTime = time;
    _applyFiltersAndSort();
  }

  void clearFilters() {
    _filterMood = null;
    _filterCategory = null;
    _filterTime = null;
    _searchQuery = '';
    _applyFiltersAndSort();
  }

  void _applyFiltersAndSort() {
    List<JournalModel> result = List.from(_allJournals);

    // Search
    if (_searchQuery.isNotEmpty) {
      result = result.where((j) =>
          j.title.toLowerCase().contains(_searchQuery) ||
          j.description.toLowerCase().contains(_searchQuery) ||
          j.category.toLowerCase().contains(_searchQuery) ||
          j.mood.toLowerCase().contains(_searchQuery)).toList();
    }

    // Filter Mood
    if (_filterMood != null && _filterMood!.isNotEmpty) {
      result = result.where((j) => j.mood == _filterMood).toList();
    }

    // Filter Category
    if (_filterCategory != null && _filterCategory!.isNotEmpty) {
      result = result.where((j) => j.category == _filterCategory).toList();
    }

    // Filter Time
    if (_filterTime != null && _filterTime!.isNotEmpty) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      if (_filterTime == 'Today') {
        result = result.where((j) => j.createdAt.isAfter(today)).toList();
      } else if (_filterTime == 'Yesterday') {
        final yesterday = today.subtract(const Duration(days: 1));
        result = result.where((j) => j.createdAt.isAfter(yesterday) && j.createdAt.isBefore(today)).toList();
      } else if (_filterTime == 'This Week') {
        final startOfWeek = today.subtract(Duration(days: now.weekday - 1));
        result = result.where((j) => j.createdAt.isAfter(startOfWeek)).toList();
      } else if (_filterTime == 'This Month') {
        final startOfMonth = DateTime(now.year, now.month, 1);
        result = result.where((j) => j.createdAt.isAfter(startOfMonth)).toList();
      }
    }

    // Sort
    switch (_sortOption) {
      case JournalSortOption.newest:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case JournalSortOption.oldest:
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case JournalSortOption.alphabetical:
        result.sort((a, b) => a.title.compareTo(b.title));
        break;
    }

    _filteredJournals = result;
    notifyListeners();
  }
}
