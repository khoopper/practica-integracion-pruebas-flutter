"""Pruebas de Pendientes de clase contra Auth y Firestore locales."""
import argparse
from datetime import datetime
import json
import os
from pathlib import Path
import re
from secrets import token_hex, token_urlsafe
from urllib.error import HTTPError
from urllib.request import Request, urlopen

from playwright.sync_api import expect, sync_playwright

APP = 'http://127.0.0.1:7357'
EMULATOR_UI = 'http://127.0.0.1:4000'
AUTH = 'http://127.0.0.1:9099/identitytoolkit.googleapis.com/v1'
FIRESTORE = (
    'http://127.0.0.1:8080/v1/projects/demo-practica-flutter'
    '/databases/(default)/documents'
)
EVIDENCE = Path('docs/evidencias')
VIEWPORT = {'width': 1100, 'height': 720}
TITLE = 'Preparar ensayo'
NEW_TITLE = 'Entregar ensayo revisado'
SECOND = 'Leer apuntes'


def button(page, name):
    return page.get_by_role('button', name=name, exact=True)


def press(page, name):
    control = button(page, name)
    expect(control).to_be_enabled()
    control.click(force=True)


def shown(page, text):
    locator = page.get_by_text(text, exact=True).or_(
        page.get_by_label(text, exact=True)
    ).last
    expect(locator).to_be_visible()


def fill(page, label, value):
    field = page.locator('input, textarea').and_(
        page.get_by_label(re.compile('^' + re.escape(label)))
    ).last
    for _ in range(3):
        field.click(force=True)
        page.keyboard.press('Control+a')
        page.keyboard.insert_text(value)
        if field.evaluate('(node, expected) => node.value === expected', value):
            return
    raise AssertionError(f'No se pudo confirmar la entrada del campo {label}.')


def login_fields(page, email, password):
    fill(page, 'Correo electrónico', email)
    fill(page, 'Contraseña', password)


def task_row(page, title):
    return page.get_by_label(re.compile('^' + re.escape(title) + r'(?:\n|$)')).or_(
        page.get_by_text(title, exact=True)
    ).last


def get_json(url, *, token=None, body=None):
    headers = {}
    if token:
        headers['Authorization'] = 'Bearer ' + token
    payload = None
    if body is not None:
        headers['Content-Type'] = 'application/json'
        payload = json.dumps(body).encode()
    request = Request(url, data=payload, headers=headers)
    try:
        with urlopen(request, timeout=10) as response:
            return response.status, json.load(response)
    except HTTPError as error:
        with error:
            return error.code, json.load(error)


def tasks(token, uid):
    status, result = get_json(f'{FIRESTORE}/users/{uid}/tasks', token=token)
    assert status == 200, f'Firestore devolvió HTTP {status} al propietario'
    return result.get('documents', [])


def check_task(token, uid, title, notes, done):
    matches = [
        doc for doc in tasks(token, uid)
        if doc['fields']['title']['stringValue'] == title
    ]
    assert len(matches) == 1, f'Se esperaba una sola tarea titulada {title}'
    doc = matches[0]
    assert doc['fields']['notes']['stringValue'] == notes
    assert doc['fields']['done']['booleanValue'] is done
    return doc['name'].split('/documents/', 1)[1]


def add_task(page, title, notes):
    press(page, 'Nueva tarea')
    fill(page, 'Título', title)
    fill(page, 'Notas (opcional)', notes)
    press(page, 'Guardar tarea')
    expect(task_row(page, title)).to_be_visible()


def screenshot(page, filename):
    target = EVIDENCE / filename
    target.parent.mkdir(parents=True, exist_ok=True)
    page.mouse.move(2, 2)
    page.screenshot(path=target, animations='disabled')


def open_emulator_console(context, suffix):
    console = context.new_page()
    console.goto(f'{EMULATOR_UI}/{suffix}', wait_until='domcontentloaded')
    return console


def firebase_screenshot(context, path, title, filename):
    console = open_emulator_console(context, f'firestore/default/data/{path}')
    try:
        expect(console.get_by_text(title, exact=False).last).to_be_visible(timeout=15000)
        screenshot(console, f'firebase/{filename}')
    finally:
        console.close()


def round_trip(context, number, photos):
    errors = []
    seen = []

    def attach():
        page = context.new_page()
        page.on('pageerror', lambda error: errors.append(str(error).splitlines()[0]))
        page.goto(APP, wait_until='domcontentloaded')
        return page

    def passed(case, observed, photo=None):
        assert not errors, f'Excepción no controlada: {errors[0]}'
        if photos and photo:
            screenshot(page, 'capturas-aplicacion/' + photo)
        seen.append(case)
        print(f'R{number} | {case} | Aprobado | {observed}', flush=True)

    email = f'alumno-a-{number}-{token_hex(3)}@example.test'
    password = token_urlsafe(24)
    page = attach()
    expect(button(page, 'Iniciar sesión')).to_be_visible(timeout=30000)
    passed('CP-01', 'Firebase inició y se mostró el formulario de acceso.', '01-acceso.png')

    press(page, 'Crear cuenta')
    login_fields(page, email, password)
    with page.expect_response(lambda res: '/accounts:signUp' in res.url) as hit:
        press(page, 'Crear cuenta')
    assert hit.value.status == 200
    expect(button(page, 'Nueva tarea')).to_be_visible()
    passed('CP-21', 'Auth devolvió HTTP 200, creó al usuario A y abrió Mis tareas.')

    press(page, 'Salir')
    expect(button(page, 'Iniciar sesión')).to_be_visible()
    page.reload(wait_until='domcontentloaded')
    expect(button(page, 'Iniciar sesión')).to_be_visible(timeout=20000)
    login_fields(page, email, password + 'incorrecta')
    with page.expect_response(lambda res: '/accounts:signInWithPassword' in res.url) as hit:
        press(page, 'Iniciar sesión')
    assert hit.value.status == 400
    shown(page, 'El correo o la contraseña son incorrectos.')
    expect(button(page, 'Nueva tarea')).to_have_count(0)
    passed('CP-03', 'Auth devolvió HTTP 400 con mensaje entendible y conservó el acceso.', '02-clave-incorrecta.png')

    fill(page, 'Contraseña', password)
    with page.expect_response(lambda res: '/accounts:signInWithPassword' in res.url) as hit:
        press(page, 'Iniciar sesión')
    assert hit.value.status == 200
    user = hit.value.json()
    token, uid = user['idToken'], user['localId']
    expect(button(page, 'Nueva tarea')).to_be_visible()
    passed('CP-02', 'Auth devolvió HTTP 200 y abrió Mis tareas con el usuario A.')
    shown(page, 'Todavía no tienes tareas.')
    assert not tasks(token, uid)
    passed('CP-12A', 'Cuenta nueva con cero documentos y mensaje de lista vacía.', '03-lista-vacia.png')

    press(page, 'Nueva tarea')
    expect(button(page, 'Guardar tarea')).to_be_visible()
    press(page, 'Guardar tarea')
    shown(page, 'Escribe al menos 3 caracteres.')
    assert not tasks(token, uid)
    passed('CP-04', 'Título vacío validado en pantalla y cero documentos creados.', '04-validacion.png')

    fill(page, 'Título', TITLE)
    fill(page, 'Notas (opcional)', 'Capítulo 8')
    expect(page.get_by_text('Escribe al menos 3 caracteres.', exact=True)).to_have_count(0)
    if photos:
        screenshot(page, 'capturas-aplicacion/05-formulario.png')
    press(page, 'Guardar tarea')
    expect(task_row(page, TITLE)).to_be_visible()
    path = check_task(token, uid, TITLE, 'Capítulo 8', False)
    passed('CP-07', 'La tarea apareció en UI y Firestore con nota Capítulo 8 y estado pendiente.', '06-creada.png')
    if photos:
        firebase_screenshot(context, path, TITLE, '01-firestore-creacion.png')

    add_task(page, SECOND, '')
    first = task_row(page, SECOND).bounding_box()
    second = task_row(page, TITLE).bounding_box()
    assert first is not None and second is not None and first['y'] < second['y']
    assert len(tasks(token, uid)) == 2
    passed('CP-08', 'Se vieron dos tareas. Leer apuntes quedó arriba por ser más reciente.', '07-lista-ordenada.png')

    task_row(page, TITLE).click(force=True)
    expect(button(page, 'Eliminar tarea')).to_be_visible()
    shown(page, 'Pendiente')
    passed('CP-05', 'Acceso, Mis tareas, Nueva tarea y Detalle abrieron en sus pasos.', '08-detalle.png')
    press(page, 'Atrás')
    expect(task_row(page, TITLE)).to_be_visible()
    passed('CP-06', 'El botón Atrás regresó del detalle a la lista y conservó las dos tareas.')

    checkbox = page.get_by_role('checkbox', name=f'Completada: {TITLE}', exact=True)
    checkbox.click(force=True)
    expect(checkbox).to_be_checked()
    task_row(page, TITLE).click(force=True)
    shown(page, 'Completada')
    fill(page, 'Título', NEW_TITLE)
    fill(page, 'Notas (opcional)', 'Versión final')
    press(page, 'Guardar tarea')
    expect(task_row(page, NEW_TITLE)).to_be_visible()
    assert check_task(token, uid, NEW_TITLE, 'Versión final', True) == path
    expect(page.get_by_role('checkbox', name=f'Completada: {NEW_TITLE}', exact=True)).to_be_checked()
    passed('CP-09', 'El mismo documento conservó su ID y estado completado tras editar título y nota.', '09-actualizada.png')
    if photos:
        firebase_screenshot(context, path, NEW_TITLE, '02-firestore-actualizacion.png')

    status, user_b = get_json(f'{AUTH}/accounts:signUp?key=demo-web-api-key', body={
        'email': f'alumno-b-{number}-{token_hex(3)}@example.test',
        'password': token_urlsafe(24),
        'returnSecureToken': True,
    })
    assert status == 200
    assert not tasks(user_b['idToken'], user_b['localId'])
    status, denied = get_json(f'{FIRESTORE}/{path}', token=user_b['idToken'])
    assert status == 403 and denied['error']['status'] == 'PERMISSION_DENIED'
    passed('CP-11', 'El usuario B de prueba obtuvo 403 PERMISSION_DENIED para una tarea de A.')

    context.set_offline(True)
    try:
        shown(page, 'Mostrando datos locales. Verificando conexión.')
        expect(task_row(page, NEW_TITLE)).to_be_visible()
        expect(task_row(page, SECOND)).to_be_visible()
        passed('CP-12B', 'Al desconectar la red se conservó la lista cargada con aviso de datos locales.', '10-sin-conexion.png')
    finally:
        context.set_offline(False)

    page.close()
    page = attach()
    expect(task_row(page, NEW_TITLE)).to_be_visible(timeout=20000)
    expect(task_row(page, SECOND)).to_be_visible()
    passed('CP-19', 'Al cerrar y volver a abrir la app se restauraron sesión, tareas y cambios.')

    task_row(page, SECOND).click(force=True)
    press(page, 'Eliminar tarea')
    press(page, 'Eliminar definitivamente')
    expect(task_row(page, NEW_TITLE)).to_be_visible()
    expect(task_row(page, SECOND)).to_have_count(0)
    assert len(tasks(token, uid)) == 1
    passed('CP-10', 'Leer apuntes desapareció de la lista y solo quedó un documento en Firestore.', '11-eliminada.png')

    press(page, 'Salir')
    expect(button(page, 'Iniciar sesión')).to_be_visible()
    page.reload(wait_until='domcontentloaded')
    expect(button(page, 'Iniciar sesión')).to_be_visible(timeout=20000)
    expect(button(page, 'Nueva tarea')).to_have_count(0)
    passed('CP-18', 'Salir llevó al acceso. Se mantuvo cerrado al recargar y no se mostró la lista.')
    passed('CP-20', 'Registro, acceso, creación, edición, persistencia, borrado y salida completados.')

    if photos:
        console = open_emulator_console(context, 'auth')
        expect(console.get_by_text(email, exact=True)).to_be_visible(timeout=15000)
        screenshot(console, 'firebase/03-auth-cuentas-de-prueba.png')
    return len(seen)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--chrome', type=Path)
    parser.add_argument('--evidencias', action='store_true')
    parser.add_argument('--proxy-de-pruebas', action='store_true')
    args = parser.parse_args()
    print(f'Fecha local: {datetime.now().astimezone().isoformat(timespec="seconds")}')
    print('Entorno: Flutter Web + Firebase Local Emulator Suite, proyecto demo-practica-flutter.')
    print('Cada ronda arranca una sesión de navegador nueva con cuentas ficticias.')
    with sync_playwright() as p:
        config = {'executable_path': args.chrome} if args.chrome else {}
        if args.proxy_de_pruebas:
            config['proxy'] = {
                'server': os.environ['HTTPS_PROXY'], 'bypass': '127.0.0.1,localhost',
            }
        browser = p.chromium.launch(**config)
        total = 0
        for number in (1, 2):
            context = browser.new_context(
                viewport=VIEWPORT,
                ignore_https_errors=args.proxy_de_pruebas,
            )
            try:
                total += round_trip(context, number, args.evidencias and number == 1)
            finally:
                context.close()
        browser.close()
    print(f'Resultado: {total} comprobaciones aprobadas en dos rondas.')


if __name__ == '__main__':
    main()
