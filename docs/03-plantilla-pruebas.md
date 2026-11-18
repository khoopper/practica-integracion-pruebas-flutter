# Plantilla de pruebas

La cobertura se verifica en Flutter Web con Authentication y Firestore de Firebase Local Emulator Suite. Las cuentas y tareas son ficticias. Cada ronda inicia un contexto de navegador nuevo. CP-19 cierra y vuelve a abrir la aplicación dentro de la misma sesión del navegador y CP-18 recarga después de salir. Las rondas se ejecutan automáticamente en GitHub Actions (Linux, Flutter 3.50.0, Chrome Headless Shell) con el flujo [Integración y pruebas](https://github.com/khoopper/practica-integracion-pruebas-flutter/actions/workflows/integracion-y-pruebas.yml). CP-07 y CP-09 se repitieron además contra Firebase en la nube (proyecto de prueba `practica-flutter-pruebas`) con la app compilada por el flujo `web-nube`.

Un resultado aprobado requiere que coincida con lo esperado, que no ocurra ninguna excepción no controlada en el navegador y que pueda repetirse. El registro funcional identifica cada ejecución por ronda y por ID. La evidencia visual complementa el resultado de la aplicación y las operaciones en Firestore.

Los mismos casos e incidencias están trasladados a la **plantilla oficial del archivo 08**, columna por columna: [08-plantilla-pruebas-e-incidencias.md](08-plantilla-pruebas-e-incidencias.md) y [08_Plantilla_pruebas_e_incidencias.csv](08_Plantilla_pruebas_e_incidencias.csv).

## Integración incremental (Fase 3)

Se verificó en el orden indicado por la práctica. Ninguna incidencia fue Crítica o Alta; cada una se registró al detectarse y se corrigió antes de cerrar el paso correspondiente.

| Paso | Verificación | Casos | Resultado |
| --- | --- | --- | --- |
| 1 | Arranque e inicialización de Firebase | CP-01 | Aprobado |
| 2 | Autenticación | CP-21, CP-02, CP-03 | Aprobado |
| 3 | Navegación entre todas las pantallas | CP-05, CP-06 | Aprobado tras corregir INC-002 |
| 4 | Lectura de datos | CP-08, CP-12A, CP-12B, CP-19 | Aprobado; tras el rediseño visual se corrigieron INC-005 (lista) e INC-006 (lista vacía) |
| 5 | Escritura y actualización de datos | CP-04, CP-07, CP-09, CP-10, CP-11 | Aprobado tras corregir INC-003 e INC-004; la repetición en la nube detectó INC-007 (borde de la lista) |
| 6 | Notificaciones push en tres estados | CP-14 a CP-17 | No ejecutado: FCM fuera del alcance |
| 7 | Flujo completo de extremo a extremo | CP-20 | Aprobado |

## Casos ejecutados

| ID | Módulo | Datos de entrada y acción | Resultado esperado | Resultado obtenido | Estado | Evidencia |
| --- | --- | --- | --- | --- | --- | --- |
| CP-01 | Arranque | Abrir la app en una sesión de navegador nueva. | Firebase inicia y se muestra el formulario de acceso. | Apareció **Iniciar sesión** y el navegador no reportó excepciones no controladas. | Aprobado | [Acceso](evidencias/capturas-aplicacion/01-acceso.png) |
| CP-02 | Autenticación | Correo de A y su contraseña generada para la prueba. | Se abre la lista de la cuenta A. | Auth devolvió HTTP 200 y apareció **Nueva tarea** en la lista de A. | Aprobado | [Registro funcional](evidencias/pruebas-y-analisis/07-pruebas-funcionales.txt) |
| CP-03 | Autenticación | Correo de A y una contraseña incorrecta de seis o más caracteres. | La app muestra un error y sigue en la pantalla de acceso. | Auth devolvió HTTP 400. Se mostró «El correo o la contraseña son incorrectos» y la lista no apareció. | Aprobado | [Contraseña incorrecta](evidencias/capturas-aplicacion/02-clave-incorrecta.png) |
| CP-04 | Validación | Abrir Nueva tarea y pulsar Guardar sin escribir título. | Se solicita un título válido y no se guarda un documento. | Apareció «Escribe al menos 3 caracteres». Firestore devolvió cero documentos. Al corregir el título el aviso desapareció. | Aprobado | [Validación](evidencias/capturas-aplicacion/04-validacion.png), [formulario corregido](evidencias/capturas-aplicacion/05-formulario.png) |
| CP-05 | Navegación | Abrir registro, acceder a Mis tareas, pulsar Nueva tarea y seleccionar una tarea guardada. | Cada acción abre la vista correspondiente. | Se vieron los controles de acceso, registro, lista, alta y detalle. | Aprobado | [Detalle](evidencias/capturas-aplicacion/08-detalle.png), [registro funcional](evidencias/pruebas-y-analisis/07-pruebas-funcionales.txt) |
| CP-06 | Navegación | Pulsar Atrás desde el detalle de «Preparar ensayo». | Vuelve a la lista y conserva las tareas. | Atrás regresó a la lista de dos registros. La etiqueta estaba en español. | Aprobado | [Registro funcional](evidencias/pruebas-y-analisis/07-pruebas-funcionales.txt) |
| CP-07 | Datos | Guardar «Preparar ensayo» con la nota «Capítulo 8». | El registro aparece pendiente en UI y Firebase. | Apareció una tarea pendiente con el título y la nota esperados en ambas vistas. En la nube, el documento `ZOCZceCcVfiNfta0F3iY` quedó con `done: false`. | Aprobado | [App](evidencias/capturas-aplicacion/06-creada.png), [Firestore](evidencias/firebase/01-firestore-creacion.png), [Firestore en la nube](evidencias/firebase/04-firestore-nube-tarea-creada.png) |
| CP-08 | Datos | Crear «Leer apuntes» después de «Preparar ensayo». | Se muestran los dos registros, con el más reciente primero. | «Leer apuntes» apareció encima de «Preparar ensayo» y Firestore devolvió dos documentos. | Aprobado | [Lista ordenada](evidencias/capturas-aplicacion/07-lista-ordenada.png) |
| CP-09 | Datos | Completar «Preparar ensayo». Cambiar el título a «Entregar ensayo revisado» y la nota a «Versión final». | Los cambios se reflejan en UI y Firestore. Se conserva el estado y el documento. | Firestore devolvió el mismo ID con nuevo título y nota, y `done: true`. La UI mantuvo la casilla marcada. En la nube, el mismo documento pasó a «Entregar ensayo revisado» con `done: true`. | Aprobado | [App](evidencias/capturas-aplicacion/09-actualizada.png), [Firestore](evidencias/firebase/02-firestore-actualizacion.png), [Firestore en la nube](evidencias/firebase/05-firestore-nube-tarea-modificada.png) |
| CP-10 | Datos | Eliminar «Leer apuntes» desde su detalle y confirmar. | Desaparece de UI y de Firestore. | La app mostró solo la tarea revisada. Firestore devolvió un documento. | Aprobado | [Después del borrado](evidencias/capturas-aplicacion/11-eliminada.png) |
| CP-11 | Reglas de datos | En el emulador, consultar con B el documento de A creado por la prueba. | Firestore rechaza la lectura. | La lista propia de B estaba vacía. La lectura del documento de A devolvió HTTP 403 `PERMISSION_DENIED`. | Aprobado | [Registro funcional](evidencias/pruebas-y-analisis/07-pruebas-funcionales.txt) |
| CP-12A | Estados | Iniciar sesión con la cuenta nueva A. | La lista muestra el estado vacío. | Apareció «Todavía no tienes tareas» y Firestore devolvió cero documentos. | Aprobado | [Lista vacía](evidencias/capturas-aplicacion/03-lista-vacia.png) |
| CP-12B | Estados | Desconectar temporalmente la red luego de cargar dos tareas. | Se conservan los datos cargados y se informa su origen local. | Ambas tareas siguieron visibles junto con «Mostrando datos locales. Verificando conexión». | Aprobado | [Sin conexión](evidencias/capturas-aplicacion/10-sin-conexion.png) |
| CP-13 | Storage | Subir un archivo. | — | No se ejecutó: el proyecto solo guarda campos de texto y Storage está fuera del alcance. | No ejecutado | [Alcance](01-declaracion-alcance.md) |
| CP-14 a CP-17 | FCM | Token y recepción de mensajes en tres estados. | — | No se ejecutaron: la aplicación no usa notificaciones push y FCM está fuera del alcance. | No ejecutado | [Alcance](01-declaracion-alcance.md) |
| CP-18 | Sesión | Pulsar Salir y recargar la aplicación. | Vuelve al acceso y la lista queda oculta después de recargar. | El formulario apareció antes y después de recargar. **Nueva tarea** no estuvo disponible. | Aprobado | [Registro funcional](evidencias/pruebas-y-analisis/07-pruebas-funcionales.txt) |
| CP-19 | Persistencia | Cerrar la pestaña y abrir otra en el mismo navegador. | Se recuperan la sesión y los registros de A. | Se restauraron ambas tareas y se conservó el título de la tarea actualizada. | Aprobado | [Registro funcional](evidencias/pruebas-y-analisis/07-pruebas-funcionales.txt) |
| CP-20 | Flujo completo | Registrar, ingresar, crear, completar, editar, reabrir, eliminar y salir. | Se completa el recorrido con cambios persistentes. | Todos los pasos de la secuencia finalizaron y el cierre volvió al acceso. | Aprobado | [Capturas del recorrido](evidencias/capturas-aplicacion/), [registro funcional](evidencias/pruebas-y-analisis/07-pruebas-funcionales.txt) |
| CP-21 | Registro | Correo ficticio nuevo de A y contraseña generada para la prueba. | Se crea la cuenta en Auth y se abre la lista. | Auth devolvió HTTP 200. El usuario figura en Auth y en la app se abrió la lista de A. | Aprobado | [Firebase Auth local](evidencias/firebase/03-auth-cuentas-de-prueba.png) |

## Resultados

Los **17 casos aplicables** se aprobaron en **dos rondas**, con **34 comprobaciones aprobadas**. La ejecución vigente es la del 17/11/2026 18:28 h, UTC-6 (00:28 UTC del 18/11/2026), sobre el diseño final con INC-007 corregida (commit `2f37347`, [ejecución 44207747012](https://github.com/khoopper/practica-integracion-pruebas-flutter/actions/runs/44207747012)); la primera ejecución del 15/11/2026 obtuvo el mismo resultado con el diseño anterior. Se cubrieron los cuatro flujos críticos y los casos negativos de contraseña, título y permisos. [Registro funcional completo](evidencias/pruebas-y-analisis/07-pruebas-funcionales.txt)

- El análisis inicial mostró 0 errores, 0 advertencias y 4 diagnósticos informativos. El análisis final quedó sin diagnósticos. [Análisis inicial](evidencias/pruebas-y-analisis/01-flutter-analyze-inicial.txt) · [Análisis final](evidencias/pruebas-y-analisis/04-flutter-analyze-final.txt)
- Pasaron 3 pruebas unitarias y 6 de widget, incluida la regresión de INC-007. [Salida de flutter test](evidencias/pruebas-y-analisis/05-flutter-test-final.txt) · [Salida en GitHub Actions con el diseño final](evidencias/pruebas-y-analisis/10-flutter-test-ci.txt) · [Análisis en GitHub Actions](evidencias/pruebas-y-analisis/11-flutter-analyze-ci.txt)
- El arranque se realizó con `flutter run`. El registro contiene la compilación y la dirección servida. [Ejecución](evidencias/pruebas-y-analisis/06-flutter-run.txt) · [Compilación web en GitHub Actions](evidencias/pruebas-y-analisis/15-flutter-build-web-ci.txt)
- Se registraron y corrigieron 7 incidencias; el detalle está en [04-registro-incidencias.md](04-registro-incidencias.md).
