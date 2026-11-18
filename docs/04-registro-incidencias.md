# Registro de incidencias

| ID | Síntoma | Severidad | Prioridad | Origen | Causa | Corrección y commit | Estado |
| --- | --- | --- | --- | --- | --- | --- | --- |
| INC-001 | El análisis inicial devolvió cuatro diagnósticos por el import de Material. | Baja | P3 | Análisis estático | Flutter 3.50 marca el import de Material del SDK como obsoleto. | Migración al paquete oficial `material_ui` en `5fea62d`. | Cerrada. Análisis posterior sin diagnósticos. |
| INC-002 | El control de regreso se identificaba como `Back` en la app en español. | Baja | P3 | Navegación y accesibilidad | La app utilizaba la localización por defecto del framework. | Configuración de `es` y de los delegados de localización en `0bc028f`. | Cerrada. La prueba de widget y CP-06 verifican `Atrás`. |
| INC-003 | Un evento Atrás sacaba al usuario del editor mientras el guardado seguía pendiente. | Media | P2 | Navegación y escritura asíncrona | El formulario bloqueaba sus controles con `_saving`. La ruta todavía aceptaba eventos de regreso. | La ruta usa `PopScope` durante la escritura y vuelve al recibir confirmación. Commit `0b4a012`. | Cerrada. La regresión pasó con una escritura diferida. |
| INC-004 | Un título corregido seguía marcado en rojo hasta pulsar Guardar otra vez. | Baja | P3 | Validación de la interfaz | El formulario validaba solamente al enviar. El estado del error seguía visible durante la corrección. | Revalidación al editar un campo con error. Commit `7859963`. | Cerrada. La prueba de widget verifica que se retira el aviso al corregir. |
| INC-005 | Después del rediseño visual, la prueba de widget «una tarea completada abre el detalle y permite volver» falló en GitHub Actions con `ListTile background color or ink splashes may be invisible`. | Baja | P2 | UI | La hoja blanca de la lista pintaba su fondo con un `DecoratedBox` entre cada `ListTile` y el `Material` del `Scaffold`, que tapaba el hover y el ripple de las filas. | La hoja envuelve su contenido en un `Material` transparente. Commit `5658eb8`. | Cerrada. La misma prueba pasó en la ejecución siguiente de GitHub Actions. |
| INC-006 | Después del rediseño, las pruebas funcionales fallaron en CP-12A: el mensaje «Todavía no tienes tareas.» no aparecía como elemento propio. | Baja | P2 | UI (accesibilidad) | Flutter Web unía la etiqueta «HOJA EN BLANCO», el mensaje y la ayuda de la hoja vacía en un solo elemento accesible. Un lector de pantalla leía todo junto y el caso no podía ubicar el mensaje. | Las etiquetas decorativas usan `ExcludeSemantics` y los mensajes y sellos tienen un nodo `Semantics(container: true)` propio. Commit `93e73cb`. | Cerrada. Las dos rondas de casos funcionales pasaron en GitHub Actions. |
| INC-007 | En la prueba manual contra Firebase en la nube, la fila de la lista con el puntero o el foco tapaba el borde de tinta de la hoja y la casilla mostraba un halo circular. | Baja | P3 | UI | El `Material` que agregó INC-005 ocupaba toda la hoja, incluido su borde de 1.5 px. La `ListTile` pinta el hover y el foco en todo su rectángulo, que empezaba sobre ese borde. La casilla usaba el halo por defecto de Material 3. | La hoja deja un margen del grosor del borde antes de su `Material`, la casilla marca el foco y el hover engrosando su borde violeta y la fila usa el mismo color sólido para hover y foco. Commit `94b92c4`. | Cerrada. La prueba de widget INC-007 y la captura de la lista actualizada lo verifican. |

## Depuración de INC-003

1. **Reproducir.** Abrir Nueva tarea, escribir «Prueba de demora», pulsar **Guardar tarea** y disparar Atrás mientras el repositorio de prueba mantiene la escritura pendiente.
2. **Leer.** La prueba mostraba cero widgets con el texto `Guardando…` después de Atrás. El repositorio ya había recibido una solicitud de creación.
3. **Formular la hipótesis.** El estado de guardado protege los campos y botones del formulario. El evento de navegación llega por la ruta.
4. **Comprobar.** El fake retrasa la confirmación con un `Completer`. Con la misma escritura pendiente se verificó que Atrás abandonaba el editor en la versión inicial.
5. **Corregir y proteger.** `PopScope` conserva el editor durante la operación. La regresión comprueba que, una vez completado el futuro, la app vuelve a **Mis tareas** con una sola solicitud de creación.

La regresión se ejecutó antes y después en el entorno de pruebas.

**Repetición en clase (17/11/2026, 18:40 h, UTC-6).** Se repitió la regresión de INC-003 frente al docente con el flujo «Regresión INC-003» de GitHub Actions: en `2654ecf` la prueba falló (`Found 0 widgets with text "Guardando…"`) y en la versión corregida `de8bd0d` pasó (`All tests passed!`). Estado: Corregido-Aprobado. [Ejecución 44209724571](https://github.com/khoopper/practica-integracion-pruebas-flutter/actions/runs/44209724571) · [registro](evidencias/pruebas-y-analisis/14-inc-003-repeticion-en-clase.txt)

- [Análisis inicial](evidencias/pruebas-y-analisis/01-flutter-analyze-inicial.txt) y [verificación de INC-001](evidencias/pruebas-y-analisis/02-contexto-inc-001.txt).
- [Regresiones antes de las correcciones](evidencias/pruebas-y-analisis/03-regresiones-antes.txt).
- [Pruebas unitarias y de widget después de corregir](evidencias/pruebas-y-analisis/05-flutter-test-final.txt).
- [Validación anterior de INC-004](evidencias/capturas-aplicacion/00-inc-004-antes.png) y [validación corregida](evidencias/capturas-aplicacion/05-formulario.png). La captura previa conserva el diseño anterior al rediseño visual porque documenta el estado antes de la corrección.

## Depuración de INC-005

1. **Reproducir.** Ejecutar `flutter test` sobre el commit del rediseño (`7b720ed`). En GitHub Actions falló la prueba «una tarea completada abre el detalle y permite volver» ([ejecución 44008946115](https://github.com/khoopper/practica-integracion-pruebas-flutter/actions/runs/44008946115)).
2. **Leer.** `tester.takeException()` devolvió el `FlutterError` «ListTile background color or ink splashes may be invisible. The ListTile is wrapped in a DecoratedBox that has a background color».
3. **Formular la hipótesis.** La nueva hoja de la lista (`Hoja` en `lib/ui/cuaderno.dart`) pinta un fondo opaco con `DecoratedBox`; la `ListTile` dibuja sus efectos en el `Material` más cercano, que es el del `Scaffold` y queda debajo de la hoja.
4. **Comprobar.** El error solo aparece en la lista con datos, que es la única pantalla con `ListTile` dentro de una `Hoja`. Las pruebas de lista vacía y de error de lectura pasaron en la misma ejecución.
5. **Corregir y proteger.** `Hoja` envuelve su contenido en `Material(type: MaterialType.transparency)`. La prueba de widget existente protege el caso: falla si vuelve a aparecer la excepción.

- [Salida de `flutter test` con la falla](evidencias/pruebas-y-analisis/09-inc-005-flutter-test-antes.txt) y [salida después de la corrección](evidencias/pruebas-y-analisis/10-flutter-test-ci.txt).

## Depuración de INC-006

1. **Reproducir.** Ejecutar las dos rondas de casos funcionales sobre el commit `5658eb8`. En GitHub Actions la ronda 1 se detuvo en CP-12A ([ejecución 44009225289](https://github.com/khoopper/practica-integracion-pruebas-flutter/actions/runs/44009225289)).
2. **Leer.** Playwright no encontró «Todavía no tienes tareas.». La instantánea de accesibilidad mostraba un solo texto: «HOJA EN BLANCO Todavía no tienes tareas. Pulsa «Nueva tarea» para anotar la primera.».
3. **Formular la hipótesis.** Antes del rediseño el mensaje estaba solo dentro de su tarjeta. Ahora comparte columna con una etiqueta y una ayuda, y Flutter Web fusiona textos hermanos sin límite semántico en un único nodo.
4. **Comprobar.** El mismo patrón aparece en el detalle («FICHA DE TAREA» junto al sello «Pendiente») y en el error de lectura. CP-03 pasó porque en `Aviso` la etiqueta «ERROR» ya estaba excluida de la semántica y el mensaje quedaba solo.
5. **Corregir y proteger.** Las etiquetas decorativas (`Etiqueta`) se excluyen de la semántica y los mensajes (`Mensaje`) y sellos (`Sello`) son contenedores semánticos. Las pruebas funcionales buscan cada mensaje por su texto exacto y fallan si vuelve a fusionarse.

- [Registro de la ronda con la falla](evidencias/pruebas-y-analisis/13-inc-006-pruebas-funcionales-antes.txt) y [registro funcional después de la corrección](evidencias/pruebas-y-analisis/07-pruebas-funcionales.txt).

## Depuración de INC-007

1. **Reproducir.** Compilar la app con el flujo [App web contra Firebase en la nube](https://github.com/khoopper/practica-integracion-pruebas-flutter/actions/workflows/web-nube.yml), crear «Leer apuntes» y «Entregar ensayo revisado», completar la segunda y pasar el puntero o el foco del teclado por su fila (commit `35539d7`).
2. **Leer.** El relleno de la fila cubría el borde izquierdo de tinta de la hoja y la casilla mostraba un círculo de color alrededor. El mismo corte del borde aparecía en la captura `09-actualizada.png` de GitHub Actions, porque al volver del editor el foco regresa a la fila editada.
3. **Formular la hipótesis.** Desde INC-005, la hoja de la lista coloca su `Material` dentro del `DecoratedBox` sin margen. La `ListTile` dibuja el hover y el foco en todo su rectángulo, que empieza en el mismo píxel que el borde de 1.5 px. El halo es la superposición circular por defecto del `Checkbox` de Material 3.
4. **Comprobar.** Solo la hoja de la lista de tareas tiene relleno interno cero; las demás hojas (acceso, editor, lista vacía y error de lectura) tienen entre 10 y 28 px de relleno y su borde no se tapa. Sin hover ni foco, la fila no pinta relleno y el borde se ve completo.
5. **Corregir y proteger.** `Hoja` deja un margen de 1.5 px antes de su `Material` y el tema de la casilla usa una superposición transparente con un borde violeta de 2.4 px en hover y foco. La prueba de widget «INC-007 las filas no tapan el borde de la hoja» comprueba que cada fila empieza dentro del borde y que la casilla no tiene halo.

- [Lista antes de la corrección](evidencias/capturas-aplicacion/00-inc-007-antes.png) y [lista después de la corrección](evidencias/capturas-aplicacion/09-actualizada.png).
- [Salida de `flutter test` con la prueba INC-007](evidencias/pruebas-y-analisis/10-flutter-test-ci.txt).
