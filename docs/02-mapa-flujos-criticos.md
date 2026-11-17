# Mapa de flujos críticos

| ID | Flujo | Recorrido | Casos |
| --- | --- | --- | --- |
| F1 | El usuario puede registrarse, iniciar sesión y salir. | Acceso → Crear cuenta → Mis tareas → Salir → Acceso. | CP-01, CP-02, CP-03, CP-18, CP-21 |
| F2 | El usuario puede crear y consultar sus tareas. | Mis tareas → Nueva tarea → Guardar tarea → Lista ordenada → Detalle → Atrás. | CP-04, CP-05, CP-06, CP-07, CP-08, CP-12A |
| F3 | El usuario puede completar, editar y eliminar una tarea. | Lista → Casilla de estado → Detalle → Guardar. Para borrar, Detalle → Eliminar tarea → Confirmar. | CP-09, CP-10 |
| F4 | El usuario puede reabrir la app y recuperar sus propios datos. | Cerrar pestaña → Abrir app → Recuperar sesión y tareas. Firestore aplica la regla por propietario. | CP-11, CP-12B, CP-19 |

**Recorrido de extremo a extremo** CP-20 verifica registro, acceso, creación, cambio de estado, edición, reapertura, eliminación y cierre.
