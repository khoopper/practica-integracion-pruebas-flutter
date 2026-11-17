import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practica_integracion_pruebas_flutter/data/task_repository.dart';
import 'package:practica_integracion_pruebas_flutter/domain/task.dart';
import 'package:practica_integracion_pruebas_flutter/main.dart';
import 'package:practica_integracion_pruebas_flutter/ui/task_list_page.dart';

class FakeTaskRepository implements TaskRepository {
  FakeTaskRepository({
    this.tasks = const [],
    this.failFirstRead = false,
    this.createResult,
  });

  final List<Task> tasks;
  final bool failFirstRead;
  final Completer<void>? createResult;
  final created = <TaskDraft>[];
  int reads = 0;

  @override
  Stream<TaskFeed> watch() {
    reads++;
    if (failFirstRead && reads == 1) {
      return Stream.error(StateError('Lectura fallida de prueba'));
    }
    return Stream.value(TaskFeed(tasks));
  }

  @override
  Future<void> create(TaskDraft draft) async {
    created.add(draft);
    await createResult?.future;
  }

  @override
  Future<void> edit(String id, TaskDraft draft) async =>
      throw UnsupportedError('La prueba no edita el repositorio.');

  @override
  Future<void> setDone(String id, bool done) async =>
      throw UnsupportedError('La prueba no cambia el estado.');

  @override
  Future<void> delete(String id) async =>
      throw UnsupportedError('La prueba no borra tareas.');
}

Future<void> showList(WidgetTester tester, TaskRepository repository) async {
  await tester.pumpWidget(
    ClassroomTasksApp(
      home: TaskListPage(repository: repository, signOut: () async {}),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('la lista vacía acepta una tarea tras validar el formulario', (
    tester,
  ) async {
    final repository = FakeTaskRepository();
    await showList(tester, repository);
    expect(find.text('Todavía no tienes tareas.'), findsOneWidget);

    await tester.tap(find.text('Nueva tarea'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar tarea'));
    await tester.pumpAndSettle();

    expect(find.text('Escribe al menos 3 caracteres.'), findsOneWidget);
    expect(repository.created, isEmpty);

    await tester.enterText(find.byType(TextFormField).first, '  Ensayo  ');
    await tester.pumpAndSettle();
    expect(find.text('Escribe al menos 3 caracteres.'), findsNothing);
    await tester.tap(find.text('Guardar tarea'));
    await tester.pumpAndSettle();
    expect(repository.created.single.title, 'Ensayo');
    expect(find.text('Mis tareas'), findsOneWidget);
  });

  testWidgets('una tarea completada abre el detalle y permite volver', (
    tester,
  ) async {
    final repository = FakeTaskRepository(
      tasks: const [
        Task(id: '1', title: 'Entregar ensayo', notes: 'Semana 16', done: true),
      ],
    );
    await showList(tester, repository);
    expect(find.widgetWithText(ListTile, 'Entregar ensayo'), findsOneWidget);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);

    await tester.tap(find.text('Entregar ensayo'));
    await tester.pumpAndSettle();
    expect(find.text('Detalle de tarea'), findsOneWidget);
    expect(find.text('Completada'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Mis tareas'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el error de lectura informa y permite reintentar', (
    tester,
  ) async {
    final repository = FakeTaskRepository(failFirstRead: true);
    await showList(tester, repository);
    expect(find.text('No se pudieron cargar las tareas.'), findsOneWidget);
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.text('Todavía no tienes tareas.'), findsOneWidget);
    expect(repository.reads, 2);
    expect(tester.takeException(), isNull);
  });
  testWidgets('INC-002 el botón de navegación está localizado', (tester) async {
    await showList(tester, FakeTaskRepository());
    await tester.tap(find.text('Nueva tarea'));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(BackButton));
    expect(MaterialLocalizations.of(context).backButtonTooltip, 'Atrás');
  });

  testWidgets('INC-003 volver espera a que termine el guardado', (
    tester,
  ) async {
    final write = Completer<void>();
    final repository = FakeTaskRepository(createResult: write);
    await showList(tester, repository);
    await tester.tap(find.text('Nueva tarea'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).first,
      'Prueba de demora',
    );
    await tester.tap(find.text('Guardar tarea'));
    await tester.pump();
    expect(find.text('Guardando…'), findsOneWidget);
    expect(repository.created, hasLength(1));

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Guardando…'), findsOneWidget);

    write.complete();
    await tester.pumpAndSettle();
    expect(find.text('Mis tareas'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
