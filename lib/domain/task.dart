class Task {
  const Task({
    required this.id,
    required this.title,
    required this.notes,
    required this.done,
  });

  final String id;
  final String title;
  final String notes;
  final bool done;
}

class TaskDraft {
  TaskDraft(String title, String notes)
    : title = title.trim(),
      notes = notes.trim();

  final String title;
  final String notes;

  Map<String, Object> toFields() => {'title': title, 'notes': notes};
}

String? validateTitle(String? value) {
  final title = value?.trim() ?? '';
  if (title.length < 3) return 'Escribe al menos 3 caracteres.';
  if (title.length > 80) return 'Usa hasta 80 caracteres.';
  return null;
}

String? validateNotes(String? value) {
  if ((value?.trim().length ?? 0) > 260) return 'Usa hasta 260 caracteres.';
  return null;
}
