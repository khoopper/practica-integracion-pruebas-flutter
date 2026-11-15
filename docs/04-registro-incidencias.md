# Registro de incidencias

| ID | Síntoma | Severidad | Prioridad | Origen | Causa | Corrección y commit | Estado |
| --- | --- | --- | --- | --- | --- | --- | --- |
| INC-001 | El análisis inicial devolvió cuatro diagnósticos por el import de Material. | Baja | P3 | Análisis estático | Flutter 3.50 marca el import de Material del SDK como obsoleto. | Migración al paquete oficial `material_ui` en `5fea62d`. | Cerrada. Análisis posterior sin diagnósticos. |
| INC-002 | El control de regreso se identificaba como `Back` en la app en español. | Baja | P3 | Navegación y accesibilidad | La app utilizaba la localización por defecto del framework. | Configuración de `es` y de los delegados de localización en `0bc028f`. | Cerrada. La prueba de widget y CP-06 verifican `Atrás`. |
| INC-003 | Un evento Atrás sacaba al usuario del editor mientras el guardado seguía pendiente. | Media | P2 | Navegación y escritura asíncrona | El formulario bloqueaba sus controles con `_saving`. La ruta todavía aceptaba eventos de regreso. | La ruta usa `PopScope` durante la escritura y vuelve al recibir confirmación. Commit `0b4a012`. | Cerrada. La regresión pasó con una escritura diferida. |
| INC-004 | Un título corregido seguía marcado en rojo hasta pulsar Guardar otra vez. | Baja | P3 | Validación de la interfaz | El formulario validaba solamente al enviar. El estado del error seguía visible durante la corrección. | Revalidación al editar un campo con error. Commit `7859963`. | Cerrada. La prueba de widget verifica que se retira el aviso al corregir. |

## Depuración de INC-003

1. **Reproducir.** Abrir Nueva tarea, escribir «Prueba de demora», pulsar **Guardar tarea** y disparar Atrás mientras el repositorio de prueba mantiene la escritura pendiente.
2. **Leer.** La prueba mostraba cero widgets con el texto `Guardando…` después de Atrás. El repositorio ya había recibido una solicitud de creación.
3. **Formular la hipótesis.** El estado de guardado protege los campos y botones del formulario. El evento de navegación llega por la ruta.
4. **Comprobar.** El fake retrasa la confirmación con un `Completer`. Con la misma escritura pendiente se verificó que Atrás abandonaba el editor en la versión inicial.
5. **Corregir y proteger.** `PopScope` conserva el editor durante la operación. La regresión comprueba que, una vez completado el futuro, la app vuelve a **Mis tareas** con una sola solicitud de creación.

La regresión se ejecutó antes y después en el entorno de pruebas. La repetición supervisada en clase se registra cuando se realice.

- [Análisis inicial](evidencias/pruebas-y-analisis/01-flutter-analyze-inicial.txt) y [verificación de INC-001](evidencias/pruebas-y-analisis/02-contexto-inc-001.txt).
- [Regresiones antes de las correcciones](evidencias/pruebas-y-analisis/03-regresiones-antes.txt).
- [Pruebas unitarias y de widget después de corregir](evidencias/pruebas-y-analisis/05-flutter-test-final.txt).
- [Validación anterior de INC-004](evidencias/capturas-aplicacion/00-inc-004-antes.png) y [validación corregida](evidencias/capturas-aplicacion/05-formulario.png).
