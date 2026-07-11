import 'package:cloud_firestore/cloud_firestore.dart';

class JournalModel {
  final String id;
  final String title;
  final String description;
  final String mood;
  final String emoji;
  final String category;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  JournalModel({
    required this.id,
    required this.title,
    required this.description,
    required this.mood,
    required this.emoji,
    required this.category,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'mood': mood,
      'emoji': emoji,
      'category': category,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory JournalModel.fromMap(Map<String, dynamic> map, String documentId) {
    return JournalModel(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      mood: map['mood'] ?? 'Neutral',
      emoji: map['emoji'] ?? '😐',
      category: map['category'] ?? 'General',
      tags: List<String>.from(map['tags'] ?? []),
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  JournalModel copyWith({
    String? id,
    String? title,
    String? description,
    String? mood,
    String? emoji,
    String? category,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JournalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      mood: mood ?? this.mood,
      emoji: emoji ?? this.emoji,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
