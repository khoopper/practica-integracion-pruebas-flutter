# Pendientes de clase

Práctica de integración y pruebas de **Flutter Web**. La aplicación permite crear una cuenta, iniciar sesión y gestionar tareas privadas guardadas en Firebase. La rama de la práctica es `semana16-integracion`.

## Ejecutar la aplicación

Se verificó con Flutter 3.50.0, Dart 3.14.0, Firebase CLI 15.36.0, Node.js 24, Java 21 y Chrome Headless Shell. Para abrirla manualmente se puede usar Chrome. Firebase usa por defecto el proyecto local `demo-practica-flutter`.

Desde la raíz del proyecto, instala dependencias y deja ejecutándose esta primera terminal.

```bash
flutter pub get
firebase emulators:start --project demo-practica-flutter --only auth,firestore
```

En otra terminal, inicia la app.

```bash
flutter run -d chrome --web-hostname=127.0.0.1 --web-port=7357 --no-web-resources-cdn
```

Crea una cuenta de prueba con un correo de ejemplo y una contraseña de seis o más caracteres. Abre **Nueva tarea**, guarda un título y selecciona la tarea para editarla. La casilla de la lista cambia su estado a completada. La consola de emuladores abre en [127.0.0.1:4000](http://127.0.0.1:4000).

## Ejecutar las pruebas

```bash
flutter analyze
flutter test --reporter expanded
```

La validación funcional usa Python 3 y Playwright. Mantén los emuladores abiertos e inicia Flutter con estas opciones para habilitar los controles accesibles desde el arranque.

```bash
flutter run -d web-server --release --web-hostname=127.0.0.1 --web-port=7357 --no-web-resources-cdn --dart-define=ENABLE_TEST_SEMANTICS=true
```

En una tercera terminal instala el navegador de pruebas y ejecuta dos rondas con cuentas ficticias nuevas.

```bash
python -m pip install playwright
python -m playwright install chromium
python integration_test/validar_web.py
```

Puedes pasar `--chrome RUTA_DEL_EJECUTABLE` para usar otro Chromium. `--evidencias` vuelve a capturar las imágenes en `docs/evidencias/`. Durante el caso sin conexión Playwright desactiva temporalmente la red del navegador de prueba.

## Atestados

| Archivo | Contenido |
| --- | --- |
| [Declaración de alcance](docs/01-declaracion-alcance.md) | Módulos, plataforma y entorno |
| [Mapa de flujos críticos](docs/02-mapa-flujos-criticos.md) | Recorridos y casos asociados |
| [Plantilla de pruebas](docs/03-plantilla-pruebas.md) | Entradas, expectativas, resultados y evidencia |
| [Registro de incidencias](docs/04-registro-incidencias.md) | Causas, correcciones, commits y regresiones |
| [Reflexión final](docs/05-reflexion-final.md) | Aprendizaje de la incidencia de guardado |
| [Capturas de la aplicación](docs/evidencias/capturas-aplicacion/) | Evidencia del flujo principal |
| [Capturas de Firebase Local Emulator Suite](docs/evidencias/firebase/) | Cuentas ficticias y datos creados y actualizados |
| [Pruebas y análisis](docs/evidencias/pruebas-y-analisis/) | Salidas de ejecución reproducibles |

## Ejecutar con Firebase en la nube

Para tomar las capturas solicitadas en Firebase Console, crea un proyecto de prueba y registra una app web. Habilita **Correo electrónico/contraseña** en Authentication e inicializa Firestore. Copia `firebase.local.example.json` a `firebase.local.json` y completa las opciones web del proyecto. El archivo local está excluido de Git.

Aplica `firestore.rules` en el proyecto de prueba y arranca Flutter con su configuración.

```bash
firebase login
firebase deploy --project ID_DEL_PROYECTO_DE_PRUEBA --only firestore:rules
flutter run -d chrome --dart-define-from-file=firebase.local.json
```

Usa cuentas ficticias. Crea y modifica una tarea, y captura los datos en Firestore de Firebase Console. Guarda esas capturas en `docs/evidencias/firebase/` con nombres que indiquen la operación. Las capturas incluidas en esta entrega proceden de la consola local de Firebase.

## Publicar en GitHub

El archivo `.bundle` del paquete trae el historial con `main` y `semana16-integracion`. Desde la carpeta donde descomprimiste el paquete, restaura el repositorio e inicia sesión en GitHub CLI.

```bash
git clone --branch semana16-integracion practica-integracion-pruebas-flutter.bundle entrega-flutter
cd entrega-flutter
git remote remove origin
gh auth login
gh repo create practica-integracion-pruebas-flutter --public --source=. --remote=origin
git push origin semana16-integracion:main
git push -u origin semana16-integracion
```

Verifica el enlace público antes de compartirlo con el docente. Si el trabajo se realiza en pareja, agrega a la otra persona como colaboradora y conserva sus commits. Vuelve a ejecutar en clase la regresión de INC-003 y registra la evidencia de esa repetición.

## Referencias

- Configuración de Firebase para Flutter. [Documentación de Firebase](https://firebase.google.com/docs/flutter/setup)
- Conexión de Firestore al emulador. [Documentación de Firebase](https://firebase.google.com/docs/emulator-suite/connect_firestore)
- Migración a `material_ui`. [Documentación de Flutter](https://docs.flutter.dev/release/breaking-changes/material-ui-and-cupertino-ui)
- Creación de repositorios desde la terminal. [Manual de GitHub CLI](https://cli.github.com/manual/gh_repo_create)
