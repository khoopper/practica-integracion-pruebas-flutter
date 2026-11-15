import 'package:material_ui/material_ui.dart';

import '../data/task_repository.dart';
import '../domain/task.dart';
import 'task_editor_page.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({
    super.key,
    required this.repository,
    required this.signOut,
  });

  final TaskRepository repository;
  final Future<void> Function() signOut;

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  late Stream<TaskFeed> _feed = widget.repository.watch();
  final _changing = <String>{};
  bool _signingOut = false;

  void _openEditor([Task? task]) => Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => TaskEditorPage(repository: widget.repository, task: task),
    ),
  );

  Future<void> _changeDone(Task task, bool? value) async {
    if (value == null || _changing.contains(task.id)) return;
    setState(() => _changing.add(task.id));
    try {
      await widget.repository.setDone(task.id, value);
    } catch (_) {
      if (mounted) _message('No se pudo cambiar el estado de la tarea.');
    } finally {
      if (mounted) setState(() => _changing.remove(task.id));
    }
  }

  Future<void> _signOut() async {
    if (_signingOut) return;
    setState(() => _signingOut = true);
    try {
      await widget.signOut();
    } catch (_) {
      if (mounted) _message('No se pudo cerrar la sesión.');
    } finally {
      if (mounted) setState(() => _signingOut = false);
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pendientes de clase'),
        actions: [
          TextButton.icon(
            onPressed: _signingOut ? null : _signOut,
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Salir'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, layout) {
          final inset = layout.maxWidth > 768
              ? (layout.maxWidth - 720) / 2
              : 24.0;
          return StreamBuilder<TaskFeed>(
            stream: _feed,
            builder: (context, snapshot) {
              final feed = snapshot.data;
              final tasks = feed?.tasks ?? const <Task>[];
              final done = tasks.where((task) => task.done).length;
              return ListView(
                padding: EdgeInsets.fromLTRB(inset, 28, inset, 40),
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Mis tareas',
                                style: theme.textTheme.headlineSmall,
                              ),
                              if (feed != null)
                                Text(
                                  '${tasks.length - done} pendientes · $done completadas',
                                ),
                            ],
                          ),
                          FilledButton.icon(
                            onPressed: () => _openEditor(),
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Nueva tarea'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (snapshot.hasError)
                    Card.outlined(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Text('No se pudieron cargar las tareas.'),
                            TextButton(
                              onPressed: () => setState(
                                () => _feed = widget.repository.watch(),
                              ),
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (feed == null)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else ...[
                    if (feed.fromCache)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Text(
                          'Mostrando datos locales. Verificando conexión.',
                        ),
                      ),
                    if (tasks.isEmpty)
                      const Card.outlined(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text('Todavía no tienes tareas.'),
                        ),
                      )
                    else
                      for (final task in tasks)
                        Card.outlined(
                          key: ValueKey(task.id),
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            onTap: () => _openEditor(task),
                            leading: Checkbox(
                              value: task.done,
                              semanticLabel: 'Completada: ${task.title}',
                              onChanged: _changing.contains(task.id)
                                  ? null
                                  : (value) => _changeDone(task, value),
                            ),
                            title: Text(
                              task.title,
                              style: task.done
                                  ? const TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                    )
                                  : null,
                            ),
                            subtitle: task.notes.isEmpty
                                ? null
                                : Text(
                                    task.notes,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                            trailing: const Icon(Icons.chevron_right_rounded),
                          ),
                        ),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }
}
