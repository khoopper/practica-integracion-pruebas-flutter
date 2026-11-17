# Reflexión final

La prueba que habría evitado el error de mayor impacto simula un guardado lento y ejecuta Atrás antes de recibir la confirmación.

En la primera versión, el usuario podía dejar el editor con la operación pendiente y perder la señal de que seguía en curso.

Probé el caso con un repositorio falso para controlar exactamente cuándo termina la escritura.

La regresión verifica que se mantiene el editor mientras espera y que se vuelve a la lista una sola vez al confirmar.

En Firestore verifiqué que editar una tarea mantiene su identificador y su estado de completada.

En la próxima integración incluiría una prueba de demora en cada flujo que combina una escritura con un cambio de pantalla.
