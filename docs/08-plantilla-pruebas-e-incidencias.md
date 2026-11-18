# 08 · Plantilla de registro de pruebas e incidencias

**Proyecto:** Pendientes de clase (`practica-integracion-pruebas-flutter`) **Equipo/Estudiante:** Brandon Ramirez (individual) **Fecha:** 15/11/2026 (primera ejecución) · 16/11/2026 (repetición manual de CP-07 y CP-09 en Firebase en la nube) · 17/11/2026 18:28 h, UTC-6 (00:28 UTC del 18/11/2026) (re-ejecución completa con el diseño final e INC-007 corregida) **Versión de la app / commit:** 1.0.0+1 · rama `semana16-integracion` · commit probado `2f37347` ([ejecución de GitHub Actions 44207747012](https://github.com/khoopper/practica-integracion-pruebas-flutter/actions/runs/44207747012)) **Entorno de pruebas:** dispositivo/emulador: Chromium (Chrome Headless Shell de Playwright) con Firebase Local Emulator Suite (Auth y Firestore, proyecto `demo-practica-flutter`); CP-07 y CP-09 también se repitieron contra Firebase en la nube (proyecto `practica-flutter-pruebas`) con la app compilada por el flujo `web-nube` · SO: Linux (GitHub Actions `ubuntu-latest`; la primera ejecución también fue en Linux) · Flutter: 3.50.0 · Dart 3.14.0 ([`flutter --version`](evidencias/pruebas-y-analisis/12-flutter-version-ci.txt))

Este archivo se acompaña de [08_Plantilla_pruebas_e_incidencias.csv](08_Plantilla_pruebas_e_incidencias.csv), que puede abrirse en Excel u hojas de cálculo con las mismas columnas de la sección 2.

## 0. Declaración de alcance

| Módulo / servicio | ¿Aplica? (Sí/No) | Observación |
| --- | --- | --- |
| Autenticación | Sí | Firebase Authentication con correo y contraseña: registro, acceso, recuperación de sesión y cierre. |
| Base de datos | Sí | Cloud Firestore en `users/{uid}/tasks`: crear, leer, editar, completar y eliminar tareas. Reglas por propietario en `firestore.rules`. |
| Almacenamiento | No | La app guarda solo texto (título, nota y estado). CP-13 queda **No ejecutado** por estar fuera del alcance. |
| Notificaciones push (FCM) | No | La app no envía ni recibe notificaciones. CP-14 a CP-17 quedan **No ejecutado** por estar fuera del alcance. |
| API REST | No | La app usa los SDK de Firebase. El verificador funcional solo consulta las API locales de los emuladores para comprobar datos. |
| Otros: | No | Sin Analytics, Crashlytics ni Remote Config. |

## 1. Instrucciones de llenado

Se siguieron las instrucciones del archivo 08: identificadores CP-XX e INC-XXX, datos de entrada concretos sin credenciales reales (cuentas ficticias generadas por la prueba), resultado obtenido descrito, estados de la escala oficial y evidencia enlazada. Una incidencia aparece en una fila propia con su estado **Fallido** y en una fila de regresión con estado **Corregido-Aprobado**.

## 2. Registro de pruebas e incidencias

Las rutas de evidencia son relativas a la carpeta `docs/`. «Registro funcional» es [evidencias/pruebas-y-analisis/07-pruebas-funcionales.txt](evidencias/pruebas-y-analisis/07-pruebas-funcionales.txt), con dos rondas (R1 y R2) en sesiones de navegador nuevas. Las capturas de la app, las de la consola local y el registro funcional corresponden a la re-ejecución del 17/11/2026 con el diseño final. Las capturas `04-firestore-nube-*` y `05-firestore-nube-*` son de Firebase Console en la nube.

| Identificador | Módulo o funcionalidad | Descripción de la prueba | Datos de entrada | Resultado esperado | Resultado obtenido | Estado | Error identificado | Corrección aplicada | Evidencia |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| CP-01 | Arranque | La app inicia sin excepciones en una sesión de navegador nueva. | Abrir `http://127.0.0.1:7357` en un contexto de navegador nuevo. | Firebase inicia y se muestra el formulario de acceso sin excepciones en consola. | Apareció «Iniciar sesión» y el navegador no reportó excepciones no controladas (R1 y R2). | Aprobado | — | — | [01-acceso.png](evidencias/capturas-aplicacion/01-acceso.png) · Registro funcional |
| CP-21 | Autenticación (registro) | Crear una cuenta nueva desde la pantalla de registro. | Correo ficticio nuevo de la cuenta A generado por la prueba y contraseña de prueba de 6 o más caracteres. | La cuenta se crea en Auth y se abre «Mis tareas». | Auth devolvió HTTP 200; el usuario figura en Auth y se abrió la lista de A (R1 y R2). | Aprobado | — | — | [03-auth-cuentas-de-prueba.png](evidencias/firebase/03-auth-cuentas-de-prueba.png) · Registro funcional |
| CP-02 | Autenticación | Inicio de sesión válido. | Correo de la cuenta A y su contraseña de prueba. | Se abre la pantalla principal «Mis tareas» de A. | Auth devolvió HTTP 200 y apareció «Nueva tarea» en la lista de A (R1 y R2). | Aprobado | — | — | Registro funcional |
| CP-03 | Autenticación (caso negativo) | Inicio de sesión con contraseña incorrecta. | Correo de la cuenta A y una contraseña incorrecta de 6 o más caracteres. | Mensaje claro de error y la app sigue en la pantalla de acceso. | Auth devolvió HTTP 400; se mostró «El correo o la contraseña son incorrectos» y la lista no apareció (R1 y R2). | Aprobado | — | — | [02-clave-incorrecta.png](evidencias/capturas-aplicacion/02-clave-incorrecta.png) |
| CP-04 | Validación (caso negativo) | Guardar el formulario de tarea vacío. | Abrir «Nueva tarea» y pulsar «Guardar tarea» con el título vacío. | Mensaje de validación y no se llama al servicio (cero documentos). | Apareció «Escribe al menos 3 caracteres»; Firestore devolvió 0 documentos. Al escribir un título válido el aviso desapareció (ver INC-004). | Aprobado | — | — | [04-validacion.png](evidencias/capturas-aplicacion/04-validacion.png) · [05-formulario.png](evidencias/capturas-aplicacion/05-formulario.png) |
| CP-05 | Navegación | Acceder a cada pantalla. | Acceso → Crear cuenta → Mis tareas → Nueva tarea → Detalle de una tarea guardada. | Cada acción abre la pantalla correcta. | Se mostraron los controles de acceso, registro, lista, alta y detalle en cada paso (R1 y R2). | Aprobado | — | — | [08-detalle.png](evidencias/capturas-aplicacion/08-detalle.png) · Registro funcional |
| CP-06 | Navegación | Botón «Atrás» desde una pantalla secundaria. | Pulsar «Atrás» en el detalle de «Preparar ensayo». | Regresa a la lista sin cierre inesperado. | Volvió a la lista con los dos registros; el botón se identificó como «Atrás» (R1 y R2). | Aprobado | — (ver INC-002) | — | Registro funcional |
| CP-07 | Datos | Crear una tarea. | Título «Preparar ensayo», nota «Capítulo 8». | Aparece pendiente en la UI y en Firestore `users/{uid}/tasks`. | La tarea apareció pendiente con el título y la nota en la app y el documento existe en Firestore. En la nube, el documento `ZOCZceCcVfiNfta0F3iY` quedó con `done: false`, `notes: "Capítulo 8"` y `title: "Preparar ensayo"`. | Aprobado | — | — | [06-creada.png](evidencias/capturas-aplicacion/06-creada.png) · [01-firestore-creacion.png](evidencias/firebase/01-firestore-creacion.png) · [04-firestore-nube-tarea-creada.png](evidencias/firebase/04-firestore-nube-tarea-creada.png) |
| CP-08 | Datos | Leer la lista ordenada. | Crear «Leer apuntes» después de «Preparar ensayo». | Lista completa con la tarea más reciente primero. | «Leer apuntes» apareció encima de «Preparar ensayo»; Firestore devolvió 2 documentos. | Aprobado | — (ver INC-005) | — | [07-lista-ordenada.png](evidencias/capturas-aplicacion/07-lista-ordenada.png) |
| CP-09 | Datos | Actualizar una tarea. | Marcar «Preparar ensayo» como completada; cambiar el título a «Entregar ensayo revisado» y la nota a «Versión final». | El cambio se refleja en la UI y en Firestore sobre el mismo documento. | Firestore conservó el mismo ID con el nuevo título, la nueva nota y `done: true`; la UI mantuvo la casilla marcada. En la nube, el mismo documento `ZOCZceCcVfiNfta0F3iY` pasó a `done: true`, `notes: "Versión final"` y `title: "Entregar ensayo revisado"`. | Aprobado | — (ver INC-007) | — | [09-actualizada.png](evidencias/capturas-aplicacion/09-actualizada.png) · [02-firestore-actualizacion.png](evidencias/firebase/02-firestore-actualizacion.png) · [05-firestore-nube-tarea-modificada.png](evidencias/firebase/05-firestore-nube-tarea-modificada.png) |
| CP-10 | Datos | Eliminar una tarea. | Eliminar «Leer apuntes» desde su detalle y confirmar. | Desaparece de la UI y de Firestore. | La app mostró solo la tarea revisada; Firestore devolvió 1 documento. | Aprobado | — | — | [11-eliminada.png](evidencias/capturas-aplicacion/11-eliminada.png) |
| CP-11 | Seguridad (caso negativo) | Acceso a datos de otro usuario. | Con la cuenta ficticia B, leer el documento de la tarea de A. | Rechazado por las reglas de Firestore. | La lista de B estaba vacía y la lectura del documento de A devolvió HTTP 403 `PERMISSION_DENIED` (R1 y R2). | Aprobado | — | — | Registro funcional |
| CP-12A | Estados | Lista vacía. | Cuenta nueva A sin tareas. | Mensaje de estado vacío, sin cierre. | Apareció «Todavía no tienes tareas» y Firestore devolvió 0 documentos. | Aprobado | — (ver INC-006) | — | [03-lista-vacia.png](evidencias/capturas-aplicacion/03-lista-vacia.png) |
| CP-12B | Estados (caso negativo) | Error de red con datos cargados. | Desconectar la red del navegador después de cargar dos tareas. | Mensaje de error o de datos locales, sin cierre. | Las dos tareas siguieron visibles con «Mostrando datos locales. Verificando conexión». | Aprobado | — | — | [10-sin-conexion.png](evidencias/capturas-aplicacion/10-sin-conexion.png) |
| CP-13 | Almacenamiento | Subir y mostrar un archivo. | — | — | No se ejecutó: Storage no forma parte del alcance declarado. | No ejecutado | — | — | [01-declaracion-alcance.md](01-declaracion-alcance.md) |
| CP-14 | FCM | Token generado y guardado. | — | — | No se ejecutó: FCM no forma parte del alcance declarado. | No ejecutado | — | — | [notificaciones-fcm/README.md](evidencias/notificaciones-fcm/README.md) |
| CP-15 | FCM | Notificación en primer plano. | — | — | No se ejecutó: FCM no forma parte del alcance declarado. | No ejecutado | — | — | [notificaciones-fcm/README.md](evidencias/notificaciones-fcm/README.md) |
| CP-16 | FCM | Notificación en segundo plano. | — | — | No se ejecutó: FCM no forma parte del alcance declarado. | No ejecutado | — | — | [notificaciones-fcm/README.md](evidencias/notificaciones-fcm/README.md) |
| CP-17 | FCM | Notificación con la app cerrada. | — | — | No se ejecutó: FCM no forma parte del alcance declarado. | No ejecutado | — | — | [notificaciones-fcm/README.md](evidencias/notificaciones-fcm/README.md) |
| CP-18 | Sesión | Cerrar sesión. | Pulsar «Salir» y recargar la app. | Vuelve al acceso y los datos privados no son visibles. | El formulario de acceso apareció antes y después de recargar; «Nueva tarea» no estuvo disponible (R1 y R2). | Aprobado | — | — | Registro funcional |
| CP-19 | Persistencia | Reabrir la app. | Cerrar la pestaña y abrir otra en el mismo navegador. | Se recuperan la sesión y las tareas de A. | Se restauraron la sesión, las dos tareas y el título actualizado (R1 y R2). | Aprobado | — | — | Registro funcional |
| CP-20 | Flujo completo | Recorrido de extremo a extremo (F1 a F4). | Registrar, ingresar, crear, completar, editar, reabrir, eliminar y salir. | Todos los pasos aprobados con cambios persistentes. | Todos los pasos finalizaron y el cierre volvió al acceso (R1 y R2). | Aprobado | — | — | [capturas-aplicacion/](evidencias/capturas-aplicacion/) · Registro funcional |
| INC-001 | Análisis estático | `flutter analyze` inicial sobre el commit `5a36bf9`. | `flutter analyze` | 0 errores, 0 advertencias y 0 diagnósticos. | 4 diagnósticos `info • deprecated_member_use`: «'package:flutter/material.dart' is deprecated» en `main.dart`, `auth_page.dart`, `task_editor_page.dart` y `task_list_page.dart`. | Fallido | **INC-001** · Baja · P3 · Configuración: Flutter 3.50 marca como obsoleto el import de Material del SDK. | Se añadió `material_ui: ^1.11.0` a `pubspec.yaml` y se cambiaron los imports a `package:material_ui/material_ui.dart` en `lib/` y `test/`. Commit `5fea62d` «fix: INC-001 adoptar el paquete Material de Flutter 3.50». Se repitió `flutter analyze`. | [01-flutter-analyze-inicial.txt](evidencias/pruebas-y-analisis/01-flutter-analyze-inicial.txt) |
| INC-001 (regresión) | Análisis estático | Repetición de `flutter analyze` tras la corrección. | Igual que INC-001. | Igual que INC-001. | «No issues found!» | Corregido-Aprobado | — | Ver INC-001 | [02-contexto-inc-001.txt](evidencias/pruebas-y-analisis/02-contexto-inc-001.txt) · [04-flutter-analyze-final.txt](evidencias/pruebas-y-analisis/04-flutter-analyze-final.txt) |
| INC-002 | Navegación (asociado a CP-06) | Prueba de widget «INC-002 el botón de navegación está localizado» sobre el commit `2654ecf`. | Abrir «Nueva tarea» y leer `backButtonTooltip` del botón de regreso. | El botón se identifica como «Atrás». | `Expected: 'Atrás'  Actual: 'Back'`: la prueba falló. | Fallido | **INC-002** · Baja · P3 · Navegación: la app usaba la localización por defecto (inglés). | Se configuró `locale: Locale('es')`, `supportedLocales` y `GlobalMaterialLocalizations.delegates` en `lib/main.dart`. Commit `0bc028f` «fix: INC-002 localizar la navegación y los controles en español». Se repitió la prueba y CP-06. | [03-regresiones-antes.txt](evidencias/pruebas-y-analisis/03-regresiones-antes.txt) |
| INC-002 (regresión) | Navegación | Repetición de la prueba de widget y de CP-06 tras la corrección. | Igual que INC-002. | Igual que INC-002. | La prueba pasó y CP-06 mostró «Atrás» en R1 y R2. | Corregido-Aprobado | — | Ver INC-002 | [05-flutter-test-final.txt](evidencias/pruebas-y-analisis/05-flutter-test-final.txt) · Registro funcional |
| INC-003 | Editor de tareas (asociado a CP-07) | Prueba de widget «INC-003 volver espera a que termine el guardado» con una escritura diferida por `Completer`, sobre el commit `2654ecf`. | Título «Prueba de demora» → «Guardar tarea» → evento Atrás mientras la escritura sigue pendiente. | El editor permanece mostrando «Guardando…» y, al confirmar la escritura, vuelve a «Mis tareas» una sola vez. | `Found 0 widgets with text "Guardando…"`: Atrás sacó al usuario del editor con el guardado pendiente. | Fallido | **INC-003** · Media · P2 · Estado: `_saving` bloqueaba los campos y botones, pero la ruta seguía aceptando Atrás. | `PopScope(canPop: !_saving)` y `automaticallyImplyLeading: !_saving` en `lib/ui/task_editor_page.dart`. Commit `0b4a012` «fix: INC-003 conservar el editor hasta confirmar el guardado». Se repitió la prueba (método de 5 pasos en `04-registro-incidencias.md`). | [03-regresiones-antes.txt](evidencias/pruebas-y-analisis/03-regresiones-antes.txt) |
| INC-003 (regresión) | Editor de tareas | Repetición de la prueba de widget tras la corrección. | Igual que INC-003. | Igual que INC-003. | La prueba pasó: «Guardando…» siguió visible tras Atrás y al completar la escritura se volvió a «Mis tareas» con una sola solicitud de creación. | Corregido-Aprobado | — | Ver INC-003 | [05-flutter-test-final.txt](evidencias/pruebas-y-analisis/05-flutter-test-final.txt) |
| INC-004 | Validación (asociado a CP-04) | Corregir el título después del error de validación. | Pulsar «Guardar tarea» con el título vacío y luego escribir «Preparar ensayo». | El aviso desaparece al escribir un título válido. | El campo siguió en rojo con «Escribe al menos 3 caracteres» hasta pulsar «Guardar tarea» otra vez. | Fallido | **INC-004** · Baja · P3 · UI: el formulario validaba solo al enviar. | `autovalidateMode: AutovalidateMode.onUserInteractionIfError` en el `Form` de `lib/ui/task_editor_page.dart` y aserción nueva en `test/widget/task_list_test.dart`. Commit `7859963` «fix: INC-004 actualizar la validación al corregir el título». Se repitieron la prueba de widget y CP-04. | [00-inc-004-antes.png](evidencias/capturas-aplicacion/00-inc-004-antes.png) |
| INC-004 (regresión) | Validación | Repetición de la prueba de widget y de CP-04 tras la corrección. | Igual que INC-004. | Igual que INC-004. | El aviso desapareció al escribir el título y la tarea se guardó. | Corregido-Aprobado | — | Ver INC-004 | [05-formulario.png](evidencias/capturas-aplicacion/05-formulario.png) · [05-flutter-test-final.txt](evidencias/pruebas-y-analisis/05-flutter-test-final.txt) |
| INC-005 | Lista de tareas (asociado a CP-08) | Prueba de widget «una tarea completada abre el detalle y permite volver» en GitHub Actions, sobre el commit del rediseño visual `7b720ed`. | Repositorio falso con la tarea completada «Entregar ensayo» y nota «Semana 16». | La lista muestra la tarea, abre el detalle y vuelve sin excepciones. | `FlutterError: ListTile background color or ink splashes may be invisible`: la hoja opaca tapaba el hover y el ripple de las filas. | Fallido | **INC-005** · Baja · P2 · UI: el `DecoratedBox` de la hoja quedaba entre la `ListTile` y el `Material` del `Scaffold`. | `Hoja` envuelve su contenido en `Material(type: MaterialType.transparency)` en `lib/ui/cuaderno.dart`. Commit `5658eb8` «fix: INC-005 dar Material propio a la hoja para el hover de las filas». Se repitió `flutter test` en GitHub Actions. | [09-inc-005-flutter-test-antes.txt](evidencias/pruebas-y-analisis/09-inc-005-flutter-test-antes.txt) |
| INC-005 (regresión) | Lista de tareas | Repetición de `flutter test` en GitHub Actions tras la corrección. | Igual que INC-005. | Igual que INC-005. | Las 8 pruebas de esa ejecución pasaron, incluida la que había fallado. La salida enlazada es la vigente, con 9 pruebas por la regresión de INC-007. | Corregido-Aprobado | — | Ver INC-005 | [10-flutter-test-ci.txt](evidencias/pruebas-y-analisis/10-flutter-test-ci.txt) |
| INC-006 | Estados (asociado a CP-12A) | Ronda 1 de casos funcionales en GitHub Actions sobre el commit `5658eb8`, posterior al rediseño. | Cuenta ficticia nueva sin tareas. | El mensaje «Todavía no tienes tareas.» se encuentra como elemento accesible propio. | Playwright no lo encontró: la instantánea de accesibilidad tenía un solo texto «HOJA EN BLANCO Todavía no tienes tareas. Pulsa «Nueva tarea» para anotar la primera.». | Fallido | **INC-006** · Baja · P2 · UI (accesibilidad): Flutter Web fusionaba la etiqueta, el mensaje y la ayuda en un único nodo semántico. | Etiquetas decorativas con `ExcludeSemantics` y mensajes y sellos con `Semantics(container: true)` en `lib/ui/cuaderno.dart`, `task_list_page.dart`, `task_editor_page.dart` y `auth_page.dart`. Commit `93e73cb` «fix: INC-006 separar la semántica de mensajes y sellos en Flutter Web». Se repitieron las dos rondas. | [13-inc-006-pruebas-funcionales-antes.txt](evidencias/pruebas-y-analisis/13-inc-006-pruebas-funcionales-antes.txt) |
| INC-006 (regresión) | Estados | Repetición de las dos rondas de casos funcionales tras la corrección. | Igual que INC-006. | Igual que INC-006. | CP-12A y el resto de los casos aprobaron en R1 y R2. | Corregido-Aprobado | — | Ver INC-006 | Registro funcional |
| INC-007 | Lista de tareas (asociado a CP-09) | Prueba manual de la app compilada contra Firebase en la nube, sobre el commit `35539d7`. | Tareas «Leer apuntes» y «Entregar ensayo revisado» (completada); pasar el puntero o el foco del teclado por la fila completada. | La fila resaltada respeta el borde de tinta de la hoja y la casilla no muestra halo. | El relleno de la fila tapó el borde izquierdo de la hoja y la casilla mostró un halo circular. El corte del borde también aparecía en la captura `09-actualizada.png` del CI, porque el foco vuelve a la fila al salir del editor. | Fallido | **INC-007** · Baja · P3 · UI: el `Material` de la hoja (INC-005) ocupaba también su borde de 1.5 px y la casilla usaba la superposición circular de Material 3. | `Hoja` deja un margen de 1.5 px antes de su `Material` en `lib/ui/cuaderno.dart`; la casilla usa superposición transparente y un borde de 2.4 px en hover y foco en `lib/ui/theme.dart`; la fila usa `focusColor` igual a su hover en `lib/ui/task_list_page.dart`. Commit `94b92c4` «fix: INC-007 mantener visible el borde de la hoja y quitar el halo circular». Se agregó la prueba de widget INC-007 (commit `d2822e8`) y se repitieron las dos rondas. | [00-inc-007-antes.png](evidencias/capturas-aplicacion/00-inc-007-antes.png) |
| INC-007 (regresión) | Lista de tareas | Prueba de widget «INC-007 las filas no tapan el borde de la hoja» y repetición de las dos rondas en GitHub Actions. | Igual que INC-007. | Igual que INC-007. | La prueba de widget pasó: cada fila empieza dentro del borde de 1.5 px y la casilla resuelve una superposición transparente. En la captura de CP-09 el borde de la hoja se ve completo. | Corregido-Aprobado | — | Ver INC-007 | [09-actualizada.png](evidencias/capturas-aplicacion/09-actualizada.png) · [10-flutter-test-ci.txt](evidencias/pruebas-y-analisis/10-flutter-test-ci.txt) |

## 3. Resumen de resultados

| Indicador | Valor |
| --- | --- |
| Casos planificados | 22 (CP-01 a CP-21, con CP-12 dividido en 12A y 12B) |
| Casos ejecutados | 17, en dos rondas (34 comprobaciones) |
| Aprobados | 17 casos + 7 regresiones de incidencias en Corregido-Aprobado |
| Fallidos | 0 en la ejecución final. Hubo 7 fallos iniciales (INC-001 a INC-007), todos corregidos y re-probados. |
| Bloqueados / No ejecutados (con justificación) | 0 bloqueados · 5 no ejecutados: CP-13 (Storage) y CP-14 a CP-17 (FCM), fuera del alcance declarado |
| Incidencias abiertas | 0 |
| Incidencias cerradas | 7 (INC-001 a INC-007) |
| % de aprobación de flujos críticos (aprobados ÷ ejecutados de flujos críticos) | 100 % (17 ÷ 17; flujos F1 a F4 y CP-20) |

Pruebas automatizadas: `flutter test` con 9 pruebas en verde (3 unitarias y 6 de widget con un repositorio falso), [salida](evidencias/pruebas-y-analisis/10-flutter-test-ci.txt). `flutter analyze`: 4 diagnósticos informativos al inicio y «No issues found!» al final, [salida](evidencias/pruebas-y-analisis/11-flutter-analyze-ci.txt). Las tres verificaciones se ejecutan en cada push con el flujo [Integración y pruebas](https://github.com/khoopper/practica-integracion-pruebas-flutter/actions/workflows/integracion-y-pruebas.yml).

## 4. Registro específico de incidencias

### INC-001 — Import de Material obsoleto en Flutter 3.50

| Campo | Detalle |
| --- | --- |
| Fecha / responsable | 15/11/2026 · Brandon Ramirez |
| Caso de prueba asociado | Fase 1 (`flutter analyze` inicial); no depende de un CP funcional |
| Severidad / Prioridad / Origen | Baja / P3 / Configuración |
| Pasos para reproducir | 1. Cambiar al commit `5a36bf9`. 2. Ejecutar `flutter pub get`. 3. Ejecutar `flutter analyze`. |
| Resultado esperado vs. obtenido | Esperado: sin diagnósticos. Obtenido: 4 diagnósticos `info`. |
| Mensaje de error o log (primeras líneas relevantes) | `info • 'package:flutter/material.dart' is deprecated and shouldn't be used. Use package:material_ui/material_ui.dart instead. • lib/main.dart:3:1 • deprecated_member_use` |
| Hipótesis y comprobaciones | Hipótesis: el SDK 3.50 movió Material a un paquete aparte. Comprobación: los 4 avisos apuntan a la línea del import y proponen `material_ui`. |
| Causa raíz | Flutter 3.50 marca como obsoleto `package:flutter/material.dart`. |
| Corrección (archivos, commit) | `pubspec.yaml`, `pubspec.lock`, `lib/main.dart`, `lib/ui/auth_page.dart`, `lib/ui/task_editor_page.dart`, `lib/ui/task_list_page.dart`, `test/widget/task_list_test.dart` · commit `5fea62d` |
| Prueba de regresión | `flutter analyze` → «No issues found!» |
| Estado (Abierta / En corrección / Cerrada / Diferida) y justificación | Cerrada: el análisis posterior quedó sin diagnósticos. |
| Evidencia | [01-flutter-analyze-inicial.txt](evidencias/pruebas-y-analisis/01-flutter-analyze-inicial.txt) · [02-contexto-inc-001.txt](evidencias/pruebas-y-analisis/02-contexto-inc-001.txt) · [04-flutter-analyze-final.txt](evidencias/pruebas-y-analisis/04-flutter-analyze-final.txt) |

### INC-002 — Botón de regreso identificado como «Back»

| Campo | Detalle |
| --- | --- |
| Fecha / responsable | 15/11/2026 · Brandon Ramirez |
| Caso de prueba asociado | CP-06 y prueba de widget «INC-002 el botón de navegación está localizado» |
| Severidad / Prioridad / Origen | Baja / P3 / Navegación |
| Pasos para reproducir | 1. Cambiar al commit `2654ecf`. 2. Ejecutar `flutter test test/widget/task_list_test.dart`. 3. Ver el resultado de la prueba INC-002. |
| Resultado esperado vs. obtenido | Esperado: «Atrás». Obtenido: «Back». |
| Mensaje de error o log (primeras líneas relevantes) | `Expected: 'Atrás'  Actual: 'Back'  Which: is different.` |
| Hipótesis y comprobaciones | Hipótesis: sin `locale` ni delegados, Material usa inglés. Comprobación: `MaterialLocalizations.of(context).backButtonTooltip` devolvía «Back». |
| Causa raíz | La app usaba la localización por defecto del framework. |
| Corrección (archivos, commit) | `lib/main.dart` (locale `es`, `supportedLocales`, `GlobalMaterialLocalizations.delegates`) · commit `0bc028f` |
| Prueba de regresión | La prueba de widget INC-002 pasó y CP-06 mostró «Atrás» en las dos rondas. |
| Estado (Abierta / En corrección / Cerrada / Diferida) y justificación | Cerrada: prueba automatizada y caso funcional aprobados. |
| Evidencia | [03-regresiones-antes.txt](evidencias/pruebas-y-analisis/03-regresiones-antes.txt) · [05-flutter-test-final.txt](evidencias/pruebas-y-analisis/05-flutter-test-final.txt) |

### INC-003 — Salida del editor mientras el guardado seguía pendiente

| Campo | Detalle |
| --- | --- |
| Fecha / responsable | 15/11/2026 · Brandon Ramirez |
| Caso de prueba asociado | CP-07 (crear tarea) y prueba de widget «INC-003 volver espera a que termine el guardado» |
| Severidad / Prioridad / Origen | Media / P2 / Estado |
| Pasos para reproducir | 1. Cambiar al commit `2654ecf`. 2. Ejecutar `flutter test test/widget/task_list_test.dart`. 3. La prueba abre «Nueva tarea», escribe «Prueba de demora», pulsa «Guardar tarea» y dispara Atrás mientras un `Completer` mantiene la escritura pendiente. |
| Resultado esperado vs. obtenido | Esperado: el editor sigue visible con «Guardando…». Obtenido: el editor se cerró (0 widgets «Guardando…»). |
| Mensaje de error o log (primeras líneas relevantes) | `Expected: exactly one matching candidate  Actual: _TextWidgetFinder:<Found 0 widgets with text "Guardando…": []>` |
| Hipótesis y comprobaciones | Hipótesis: `_saving` protege los controles del formulario, pero el evento Atrás llega por la ruta. Comprobación: con la escritura pendiente, Atrás abandonaba el editor y el repositorio ya tenía 1 solicitud de creación. |
| Causa raíz | La ruta del editor aceptaba eventos de regreso durante la escritura asíncrona. |
| Corrección (archivos, commit) | `lib/ui/task_editor_page.dart` (`PopScope(canPop: !_saving)` y `automaticallyImplyLeading: !_saving`) · commit `0b4a012` |
| Prueba de regresión | La prueba INC-003 pasó: el editor esperó y volvió a «Mis tareas» una sola vez al completar la escritura. La repetición en clase se registra en `04-registro-incidencias.md`. |
| Estado (Abierta / En corrección / Cerrada / Diferida) y justificación | Cerrada: la regresión automatizada pasa después de la corrección. |
| Evidencia | [03-regresiones-antes.txt](evidencias/pruebas-y-analisis/03-regresiones-antes.txt) · [05-flutter-test-final.txt](evidencias/pruebas-y-analisis/05-flutter-test-final.txt) |

### INC-004 — Título corregido seguía marcado en rojo

| Campo | Detalle |
| --- | --- |
| Fecha / responsable | 15/11/2026 · Brandon Ramirez |
| Caso de prueba asociado | CP-04 (formulario vacío) |
| Severidad / Prioridad / Origen | Baja / P3 / UI |
| Pasos para reproducir | 1. Abrir «Nueva tarea». 2. Pulsar «Guardar tarea» con el título vacío. 3. Escribir «Preparar ensayo» sin volver a pulsar «Guardar tarea». |
| Resultado esperado vs. obtenido | Esperado: el aviso desaparece al escribir un título válido. Obtenido: el aviso «Escribe al menos 3 caracteres» seguía visible. |
| Mensaje de error o log (primeras líneas relevantes) | Sin excepción en consola; defecto visual registrado en la captura previa a la corrección. |
| Hipótesis y comprobaciones | Hipótesis: el `Form` solo valida al enviar. Comprobación: el aviso se retiraba únicamente al pulsar «Guardar tarea» de nuevo. |
| Causa raíz | El formulario no revalidaba los campos con error mientras el usuario los corregía. |
| Corrección (archivos, commit) | `lib/ui/task_editor_page.dart` (`autovalidateMode: AutovalidateMode.onUserInteractionIfError`) y `test/widget/task_list_test.dart` · commit `7859963` |
| Prueba de regresión | La prueba de widget verifica que el aviso desaparece al corregir el título; CP-04 aprobado en R1 y R2. |
| Estado (Abierta / En corrección / Cerrada / Diferida) y justificación | Cerrada: prueba automatizada y caso funcional aprobados. |
| Evidencia | [00-inc-004-antes.png](evidencias/capturas-aplicacion/00-inc-004-antes.png) · [05-formulario.png](evidencias/capturas-aplicacion/05-formulario.png) · [05-flutter-test-final.txt](evidencias/pruebas-y-analisis/05-flutter-test-final.txt) |

### INC-005 — La hoja del rediseño tapaba el hover de las filas

| Campo | Detalle |
| --- | --- |
| Fecha / responsable | 16/11/2026 · Brandon Ramirez |
| Caso de prueba asociado | CP-08 (lista) y prueba de widget «una tarea completada abre el detalle y permite volver» |
| Severidad / Prioridad / Origen | Baja / P2 / UI |
| Pasos para reproducir | 1. Cambiar al commit `7b720ed`. 2. Ejecutar `flutter test`. 3. Ver el resultado de la prueba «una tarea completada abre el detalle y permite volver». |
| Resultado esperado vs. obtenido | Esperado: sin excepciones. Obtenido: `tester.takeException()` devolvió un `FlutterError`. |
| Mensaje de error o log (primeras líneas relevantes) | `ListTile background color or ink splashes may be invisible. The ListTile is wrapped in a DecoratedBox that has a background color.` |
| Hipótesis y comprobaciones | Hipótesis: la nueva `Hoja` pinta un fondo opaco encima del `Material` donde la `ListTile` dibuja sus efectos. Comprobación: solo falla la lista con datos; la lista vacía y el error de lectura, que no tienen `ListTile`, pasaron. |
| Causa raíz | El rediseño introdujo un `DecoratedBox` con color entre la `ListTile` y su `Material` ancestro. |
| Corrección (archivos, commit) | `lib/ui/cuaderno.dart` (`Material(type: MaterialType.transparency)` dentro de `Hoja`) · commit `5658eb8` |
| Prueba de regresión | `flutter test` en GitHub Actions: 8 pruebas en verde (9 desde que se agregó la prueba de INC-007). |
| Estado (Abierta / En corrección / Cerrada / Diferida) y justificación | Cerrada: la prueba que detectó el defecto pasa después de la corrección. |
| Evidencia | [09-inc-005-flutter-test-antes.txt](evidencias/pruebas-y-analisis/09-inc-005-flutter-test-antes.txt) · [10-flutter-test-ci.txt](evidencias/pruebas-y-analisis/10-flutter-test-ci.txt) · [ejecución con la falla](https://github.com/khoopper/practica-integracion-pruebas-flutter/actions/runs/44008946115) |

### INC-006 — Mensaje de lista vacía fusionado con su etiqueta en Flutter Web

| Campo | Detalle |
| --- | --- |
| Fecha / responsable | 16/11/2026 · Brandon Ramirez |
| Caso de prueba asociado | CP-12A (lista vacía) |
| Severidad / Prioridad / Origen | Baja / P2 / UI (accesibilidad) |
| Pasos para reproducir | 1. Compilar el commit `5658eb8` con `--dart-define=ENABLE_TEST_SEMANTICS=true`. 2. Crear una cuenta ficticia nueva. 3. Buscar en el árbol de accesibilidad el texto «Todavía no tienes tareas.». |
| Resultado esperado vs. obtenido | Esperado: un elemento con ese texto exacto. Obtenido: un único texto que incluía la etiqueta y la ayuda. |
| Mensaje de error o log (primeras líneas relevantes) | `AssertionError: Locator expected to be visible · Error: element(s) not found · text: HOJA EN BLANCO Todavía no tienes tareas. Pulsa «Nueva tarea» para anotar la primera.` |
| Hipótesis y comprobaciones | Hipótesis: Flutter Web fusiona textos hermanos sin límite semántico. Comprobación: el mismo patrón aparece en el detalle y en el error de lectura; CP-03 pasó porque `Aviso` ya excluía su etiqueta. |
| Causa raíz | El rediseño agrupó etiqueta, mensaje y ayuda en la misma columna sin separar sus nodos semánticos. |
| Corrección (archivos, commit) | `lib/ui/cuaderno.dart` (`Etiqueta`, `Mensaje`, `Sello`), `lib/ui/task_list_page.dart`, `lib/ui/task_editor_page.dart`, `lib/ui/auth_page.dart` · commit `93e73cb` |
| Prueba de regresión | Dos rondas de casos funcionales en GitHub Actions: todos los casos aprobados. |
| Estado (Abierta / En corrección / Cerrada / Diferida) y justificación | Cerrada: el caso que detectó el defecto aprueba en las dos rondas. |
| Evidencia | [13-inc-006-pruebas-funcionales-antes.txt](evidencias/pruebas-y-analisis/13-inc-006-pruebas-funcionales-antes.txt) · [07-pruebas-funcionales.txt](evidencias/pruebas-y-analisis/07-pruebas-funcionales.txt) · [ejecución con la falla](https://github.com/khoopper/practica-integracion-pruebas-flutter/actions/runs/44009225289) |

### INC-007 — La fila resaltada tapaba el borde de la hoja

| Campo | Detalle |
| --- | --- |
| Fecha / responsable | 16/11/2026 · Brandon Ramirez |
| Caso de prueba asociado | CP-09 (actualizar una tarea) en la prueba manual contra Firebase en la nube |
| Severidad / Prioridad / Origen | Baja / P3 / UI |
| Pasos para reproducir | 1. Compilar el commit `35539d7` con el flujo `web-nube`. 2. Crear «Leer apuntes» y «Entregar ensayo revisado» y completar la segunda. 3. Pasar el puntero o el foco del teclado por la fila completada. |
| Resultado esperado vs. obtenido | Esperado: el borde de tinta de la hoja se ve completo y la casilla no muestra halo. Obtenido: el relleno de la fila tapaba el borde izquierdo y la casilla mostraba un círculo de color. |
| Mensaje de error o log (primeras líneas relevantes) | Sin excepción en consola; defecto visual registrado en la captura previa a la corrección. |
| Hipótesis y comprobaciones | Hipótesis: el `Material` de la hoja empieza en el mismo píxel que su borde y la `ListTile` pinta el hover y el foco en todo su rectángulo. Comprobación: solo la hoja de la lista tiene relleno interno cero; las hojas con relleno no presentan el corte. El halo es la superposición por defecto del `Checkbox` de Material 3. |
| Causa raíz | La corrección de INC-005 colocó el `Material` dentro del `DecoratedBox` sin dejar el grosor del borde, y el tema no definía la superposición de la casilla. |
| Corrección (archivos, commit) | `lib/ui/cuaderno.dart` (margen de 1.5 px antes del `Material`), `lib/ui/theme.dart` (superposición transparente y borde de 2.4 px en hover y foco), `lib/ui/task_list_page.dart` (`focusColor`) · commit `94b92c4` |
| Prueba de regresión | Prueba de widget «INC-007 las filas no tapan el borde de la hoja» (commit `d2822e8`) en verde y dos rondas funcionales aprobadas en GitHub Actions. |
| Estado (Abierta / En corrección / Cerrada / Diferida) y justificación | Cerrada: la prueba de widget protege la geometría y la captura posterior muestra el borde completo. |
| Evidencia | [00-inc-007-antes.png](evidencias/capturas-aplicacion/00-inc-007-antes.png) · [09-actualizada.png](evidencias/capturas-aplicacion/09-actualizada.png) · [10-flutter-test-ci.txt](evidencias/pruebas-y-analisis/10-flutter-test-ci.txt) |

## 5. Escalas de referencia

**Severidad:** Crítica (cierre o flujo principal imposible) · Alta (funcionalidad importante falla sin alternativa) · Media (falla con alternativa) · Baja (cosmético).
**Prioridad:** P1 (inmediata) · P2 (antes de la entrega) · P3 (si hay tiempo) · P4 (diferida/mejora).
**Estados de caso:** Aprobado · Fallido · Bloqueado · No ejecutado · Corregido-Aprobado.
