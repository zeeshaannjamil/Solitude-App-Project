import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../config/colors.dart';
import '../../../providers/journal_provider.dart';
import 'journal_editor_screen.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<JournalProvider>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Journal", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort_rounded),
            onPressed: () => _showSortOptions(context, provider),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () => _showFilterOptions(context, provider),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: provider.setSearchQuery,
              decoration: InputDecoration(
                hintText: "Search journals...",
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          provider.setSearchQuery('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ).animate().fade(duration: 400.ms).slideY(begin: -0.1),

          // Statistics Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${provider.totalEntries} Entries", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                if (provider.mostUsedMood != "None")
                  Text("Top Mood: ${provider.mostUsedMood}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              ],
            ),
          ).animate().fade(delay: 200.ms),

          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.journals.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit_note_rounded, size: 80, color: Colors.grey.shade300)
                                .animate()
                                .scale(duration: 500.ms, curve: Curves.easeOutBack),
                            const SizedBox(height: 16),
                            Text(
                              "No entries found",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                            ).animate().fade(delay: 200.ms),
                          ],
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        itemCount: provider.journals.length,
                        itemBuilder: (context, index) {
                          final entry = provider.journals[index];
                          final dateStr = DateFormat("MMM dd, yyyy • hh:mm a").format(entry.createdAt);

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => JournalEditorScreen(existingJournal: entry),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        dateStr,
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              children: [
                                                Text(entry.emoji, style: const TextStyle(fontSize: 14)),
                                                const SizedBox(width: 4),
                                                Text(
                                                  entry.mood,
                                                  style: const TextStyle(
                                                    color: AppColors.primary,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            constraints: const BoxConstraints(),
                                            padding: EdgeInsets.zero,
                                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                            onPressed: () => _confirmDelete(context, provider, entry.id),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  if (entry.title.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Text(
                                      entry.title,
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Text(
                                    entry.description,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 15, height: 1.5, color: Colors.grey.shade700),
                                  ),
                                  if (entry.category.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        entry.category,
                                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ]
                                ],
                              ),
                            ),
                          ).animate().fade(delay: Duration(milliseconds: 50 * index)).slideY(begin: 0.1);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const JournalEditorScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("New Entry", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ).animate().scale(delay: 500.ms, curve: Curves.easeOutBack),
    );
  }

  void _showSortOptions(BuildContext context, JournalProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Newest First'),
                leading: const Icon(Icons.arrow_downward),
                onTap: () {
                  provider.setSortOption(JournalSortOption.newest);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Oldest First'),
                leading: const Icon(Icons.arrow_upward),
                onTap: () {
                  provider.setSortOption(JournalSortOption.oldest);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Alphabetical'),
                leading: const Icon(Icons.sort_by_alpha),
                onTap: () {
                  provider.setSortOption(JournalSortOption.alphabetical);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFilterOptions(BuildContext context, JournalProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Filter Time", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['Today', 'Yesterday', 'This Week', 'This Month'].map((time) {
                    return ActionChip(
                      label: Text(time),
                      onPressed: () {
                        provider.setFilters(time: time);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      provider.clearFilters();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                    child: const Text("Clear Filters"),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, JournalProvider provider, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Entry"),
        content: const Text("Are you sure you want to delete this journal entry? This action cannot be undone."),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteJournal(id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
