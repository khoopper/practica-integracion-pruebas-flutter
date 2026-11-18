# Declaración de alcance

- **Proyecto** Pendientes de clase
- **Rama** `semana16-integracion`
- **Plataforma verificada** Flutter Web en Chromium

| Módulo o servicio | ¿Aplica? | Observación |
| --- | --- | --- |
| Autenticación | Sí | Registro, acceso por correo y contraseña, recuperación de sesión y cierre. Firebase Auth Emulator. |
| Base de datos | Sí | Altas, lectura, edición, cambio de estado y borrado de tareas. Cloud Firestore Emulator con reglas por propietario. |
| Almacenamiento | No | La aplicación usa campos de texto y estados para las tareas. |
| Notificaciones push (FCM) | No | El flujo de tareas se gestiona desde la app. |
| API REST externa | No | La app usa los SDK de Firebase. El verificador consulta las interfaces locales de los emuladores. |
| Otros servicios | No | El alcance de Firebase se limita a Auth y Firestore. |

Las vistas verificadas son acceso, registro, lista, formulario de creación y detalle editable. La ejecución usa el proyecto `demo-practica-flutter` y cuentas ficticias. El modo con Firebase en la nube se verificó con el proyecto de prueba `practica-flutter-pruebas` (Authentication con correo y contraseña, Firestore con las reglas de `firestore.rules`). Las capturas `04` y `05` de `docs/evidencias/firebase/` muestran en Firebase Console la tarea creada y modificada; el resto de las capturas corresponde a Firebase Local Emulator Suite.

Los casos de Storage (CP-13) y FCM (CP-14 a CP-17) tienen estado **No ejecutado** con el motivo «fuera del alcance declarado». La declaración también está en la [plantilla oficial 08](08-plantilla-pruebas-e-incidencias.md#0-declaración-de-alcance). La regresión de INC-003 se repitió en clase frente al docente el 17/11/2026 ([registro](evidencias/pruebas-y-analisis/14-inc-003-repeticion-en-clase.txt)).
