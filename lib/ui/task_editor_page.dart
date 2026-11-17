import 'package:material_ui/material_ui.dart';

import '../data/task_repository.dart';
import '../domain/task.dart';
import 'cuaderno.dart';
import 'theme.dart';

class TaskEditorPage extends StatefulWidget {
  const TaskEditorPage({super.key, required this.repository, this.task});

  final TaskRepository repository;
  final Task? task;

  @override
  State<TaskEditorPage> createState() => _TaskEditorPageState();
}

class _TaskEditorPageState extends State<TaskEditorPage> {
  final _form = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.task?.title ?? '');
  late final _notes = TextEditingController(text: widget.task?.notes ?? '');
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_form.currentState!.validate()) return;
    final draft = TaskDraft(_title.text, _notes.text);
    final task = widget.task;
    await _write(
      () => task == null
          ? widget.repository.create(draft)
          : widget.repository.edit(task.id, draft),
      'No se pudo guardar la tarea.',
    );
  }

  Future<void> _confirmDelete(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¿Eliminar esta tarea?'),
        content: Text(task.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar definitivamente'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _write(
        () => widget.repository.delete(task.id),
        'No se pudo eliminar la tarea.',
      );
    }
  }

  Future<void> _write(
    Future<void> Function() action,
    String failureMessage,
  ) async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await action();
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = failureMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    return PopScope(
      canPop: !_saving,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: !_saving,
          title: Text(task == null ? 'Nueva tarea' : 'Detalle de tarea'),
        ),
        body: PapelCuadriculado(
          child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 34, 26, 48),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Hoja(
                  padding: const EdgeInsets.fromLTRB(26, 22, 26, 18),
                  child: Form(
                    key: _form,
                    autovalidateMode: AutovalidateMode.onUserInteractionIfError,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                task == null ? 'TAREA NUEVA' : 'FICHA DE TAREA',
                                style: Letra.etiqueta,
                              ),
                            ),
                            if (task != null)
                              Sello(
                                task.done ? 'Completada' : 'Pendiente',
                                activo: task.done,
                              ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _title,
                          enabled: !_saving,
                          decoration: const InputDecoration(
                            labelText: 'Título',
                          ),
                          textInputAction: TextInputAction.next,
                          validator: validateTitle,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _notes,
                          enabled: !_saving,
                          decoration: const InputDecoration(
                            labelText: 'Notas (opcional)',
                            alignLabelWithHint: true,
                          ),
                          minLines: 3,
                          maxLines: 5,
                          validator: validateNotes,
                        ),
                        if (_error case final error?) ...[
                          const SizedBox(height: 14),
                          Aviso(etiqueta: 'ERROR', mensaje: error),
                        ],
                        const SizedBox(height: 22),
                        FilledButton(
                          onPressed: _saving ? null : _save,
                          child: Text(_saving ? 'Guardando…' : 'Guardar tarea'),
                        ),
                        if (task != null) ...[
                          const SizedBox(height: 6),
                          const Divider(height: 22),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: _saving
                                  ? null
                                  : () => _confirmDelete(task),
                              icon: const Icon(Icons.delete_outline, size: 20),
                              label: const Text('Eliminar tarea'),
                              style: TextButton.styleFrom(
                                foregroundColor: Paleta.tinta,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
