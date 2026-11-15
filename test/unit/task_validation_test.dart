import 'package:flutter_test/flutter_test.dart';
import 'package:practica_integracion_pruebas_flutter/domain/task.dart';

void main() {
  test('rechaza el título vacío o de menos de tres caracteres', () {
    for (final value in [null, '', '   ', '  AB ']) {
      expect(validateTitle(value), 'Escribe al menos 3 caracteres.');
    }
  });

  test('respeta los límites de título y notas', () {
    expect(validateTitle(' ABC '), isNull);
    expect(validateTitle('a' * 80), isNull);
    expect(validateTitle('a' * 81), isNotNull);
    expect(validateNotes('  '), isNull);
    expect(validateNotes('a' * 260), isNull);
    expect(validateNotes('a' * 261), isNotNull);
  });

  test('normaliza los espacios y solo incluye los campos editables', () {
    final draft = TaskDraft('  Revisar guía  ', '\n Capítulo 8 ');
    expect(draft.toFields(), {'title': 'Revisar guía', 'notes': 'Capítulo 8'});
  });
}
