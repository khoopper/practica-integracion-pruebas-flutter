import 'package:material_ui/material_ui.dart';

import '../data/task_repository.dart';
import '../domain/task.dart';
import 'cuaderno.dart';
import 'task_editor_page.dart';
import 'theme.dart';

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
            style: TextButton.styleFrom(foregroundColor: Paleta.papel),
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Salir'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: PapelCuadriculado(
        child: LayoutBuilder(
          builder: (context, layout) {
            final inset = layout.maxWidth > 808
                ? (layout.maxWidth - 760) / 2
                : 20.0;
            return StreamBuilder<TaskFeed>(
              stream: _feed,
              builder: (context, snapshot) {
                final feed = snapshot.data;
                final tasks = feed?.tasks ?? const <Task>[];
                final done = tasks.where((task) => task.done).length;
                return ListView(
                  padding: EdgeInsets.fromLTRB(inset, 34, inset + 6, 48),
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.end,
                      spacing: 20,
                      runSpacing: 18,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              fechaDeAgenda(DateTime.now()),
                              style: Letra.etiqueta,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Mis tareas',
                              style: theme.textTheme.headlineMedium,
                            ),
                            if (feed != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                _conteo(tasks.length - done, done),
                                style: Letra.etiqueta.copyWith(
                                  color: Paleta.tinta,
                                ),
                              ),
                            ],
                          ],
                        ),
                        FilledButton.icon(
                          onPressed: () => _openEditor(),
                          icon: const Icon(Icons.add, size: 20),
                          label: const Text('Nueva tarea'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Divider(color: Paleta.tinta, thickness: 2, height: 2),
                    const SizedBox(height: 22),
                    if (snapshot.hasError)
                      Hoja(
                        padding: const EdgeInsets.fromLTRB(20, 18, 12, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ERROR DE LECTURA',
                              style: Letra.etiqueta,
                            ),
                            const SizedBox(height: 6),
                            const Text('No se pudieron cargar las tareas.'),
                            const SizedBox(height: 4),
                            TextButton(
                              onPressed: () => setState(
                                () => _feed = widget.repository.watch(),
                              ),
                              child: const Text('Reintentar'),
                            ),
                          ],
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
                      if (feed.fromCache) ...[
                        const Aviso(
                          etiqueta: 'SIN CONEXIÓN',
                          mensaje:
                              'Mostrando datos locales. Verificando conexión.',
                        ),
                        const SizedBox(height: 18),
                      ],
                      if (tasks.isEmpty)
                        Hoja(
                          padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'HOJA EN BLANCO',
                                style: Letra.etiqueta,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Todavía no tienes tareas.',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Pulsa «Nueva tarea» para anotar la primera.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Paleta.grafito,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Hoja(
                          child: Column(
                            children: [
                              for (final (index, task) in tasks.indexed) ...[
                                if (index > 0) const Divider(),
                                _TaskRow(
                                  key: ValueKey(task.id),
                                  task: task,
                                  onOpen: () => _openEditor(task),
                                  onChanged: _changing.contains(task.id)
                                      ? null
                                      : (value) => _changeDone(task, value),
                                ),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

String _conteo(int pending, int done) {
  String dos(int n) => n.toString().padLeft(2, '0');
  final pendientes = pending == 1 ? 'PENDIENTE' : 'PENDIENTES';
  final completadas = done == 1 ? 'COMPLETADA' : 'COMPLETADAS';
  return '${dos(pending)} $pendientes   ·   ${dos(done)} $completadas';
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({
    super.key,
    required this.task,
    required this.onOpen,
    required this.onChanged,
  });

  final Task task;
  final VoidCallback onOpen;
  final ValueChanged<bool?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onOpen,
      hoverColor: Paleta.papel,
      leading: Checkbox(
        value: task.done,
        semanticLabel: 'Completada: ${task.title}',
        onChanged: onChanged,
      ),
      title: Text(
        task.title,
        style: task.done
            ? theme.textTheme.titleMedium?.copyWith(
                color: Paleta.grafito,
                decoration: TextDecoration.lineThrough,
                decorationColor: Paleta.sello,
                decorationThickness: 2,
              )
            : theme.textTheme.titleMedium,
      ),
      subtitle: task.notes.isEmpty
          ? null
          : Text(
              task.notes,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (task.done) ...[const Sello('HECHA'), const SizedBox(width: 14)],
          const Icon(Icons.arrow_forward, size: 18),
        ],
      ),
    );
  }
}
