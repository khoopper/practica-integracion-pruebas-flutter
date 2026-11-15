import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/task.dart';

class TaskFeed {
  const TaskFeed(this.tasks, {this.fromCache = false});

  final List<Task> tasks;
  final bool fromCache;
}

abstract interface class TaskRepository {
  Stream<TaskFeed> watch();
  Future<void> create(TaskDraft draft);
  Future<void> edit(String id, TaskDraft draft);
  Future<void> setDone(String id, bool done);
  Future<void> delete(String id);
}

class FirestoreTaskRepository implements TaskRepository {
  FirestoreTaskRepository(FirebaseFirestore firestore, String uid)
    : _tasks = firestore.collection('users').doc(uid).collection('tasks');

  final CollectionReference<Map<String, dynamic>> _tasks;

  @override
  Stream<TaskFeed> watch() => _tasks
      .orderBy('createdAt', descending: true)
      .snapshots(includeMetadataChanges: true)
      .map(
        (snapshot) => TaskFeed(
          snapshot.docs
              .map((doc) {
                final data = doc.data();
                return Task(
                  id: doc.id,
                  title: data['title'] as String,
                  notes: data['notes'] as String,
                  done: data['done'] as bool,
                );
              })
              .toList(growable: false),
          fromCache: snapshot.metadata.isFromCache,
        ),
      );

  @override
  Future<void> create(TaskDraft draft) => _tasks.doc().set({
    ...draft.toFields(),
    'done': false,
    'createdAt': FieldValue.serverTimestamp(),
  });

  @override
  Future<void> edit(String id, TaskDraft draft) =>
      _tasks.doc(id).update(draft.toFields());

  @override
  Future<void> setDone(String id, bool done) =>
      _tasks.doc(id).update({'done': done});

  @override
  Future<void> delete(String id) => _tasks.doc(id).delete();
}
