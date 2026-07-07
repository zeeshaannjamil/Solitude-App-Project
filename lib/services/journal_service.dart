import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/journal_model.dart';

class JournalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? get _journalCollection {
    final userId = _userId;
    if (userId == null) return null;
    return _firestore.collection('users').doc(userId).collection('journals');
  }

  Stream<List<JournalModel>> getJournalsStream() {
    final collection = _journalCollection;
    if (collection == null) return Stream.value([]);

    return collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => JournalModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> addJournal(JournalModel journal) async {
    final collection = _journalCollection;
    if (collection == null) throw Exception('User not logged in');

    await collection.add(journal.toMap());
  }

  Future<void> updateJournal(JournalModel journal) async {
    final collection = _journalCollection;
    if (collection == null) throw Exception('User not logged in');

    await collection.doc(journal.id).update(journal.toMap());
  }

  Future<void> deleteJournal(String journalId) async {
    final collection = _journalCollection;
    if (collection == null) throw Exception('User not logged in');

    await collection.doc(journalId).delete();
  }
}
