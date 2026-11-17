import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';

import 'cuaderno.dart';
import 'theme.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key, required this.auth});

  final FirebaseAuth auth;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _registering = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || !_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final email = _email.text.trim();
      final password = _password.text;
      if (_registering) {
        await widget.auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        await widget.auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(() => _error = _message(error.code));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _message(String code) => switch (code) {
    'invalid-credential' ||
    'wrong-password' ||
    'user-not-found' => 'El correo o la contraseña son incorrectos.',
    'email-already-in-use' => 'Ya existe una cuenta con ese correo.',
    'weak-password' => 'Usa una contraseña con al menos 6 caracteres.',
    'invalid-email' => 'Revisa el formato del correo.',
    'network-request-failed' => 'Sin conexión. Vuelve a intentarlo.',
    'too-many-requests' => 'Demasiados intentos. Intenta más tarde.',
    _ => 'No se pudo continuar. Vuelve a intentarlo.',
  };

  void _toggleMode() => setState(() {
    _form.currentState!.reset();
    _password.clear();
    _registering = !_registering;
    _error = null;
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = _registering ? 'Crear cuenta' : 'Iniciar sesión';

    final presentacion = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(color: Paleta.sello),
          child: SizedBox.square(
            dimension: 52,
            child: Icon(Icons.checklist, color: Paleta.hoja, size: 28),
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'Pendientes\nde clase',
          style: theme.textTheme.displaySmall,
        ),
        const SizedBox(height: 14),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Text(
            'Anota cada tarea, márcala al terminarla y retómala desde '
            'cualquier navegador con tu cuenta.',
            style: theme.textTheme.bodyLarge?.copyWith(color: Paleta.grafito),
          ),
        ),
        const SizedBox(height: 18),
        Text(fechaDeAgenda(DateTime.now()), style: Letra.etiqueta),
      ],
    );

    final formulario = Hoja(
      padding: const EdgeInsets.fromLTRB(28, 26, 28, 18),
      child: AutofillGroup(
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _registering ? 'CUENTA NUEVA' : 'ACCESO',
                style: Letra.etiqueta,
              ),
              const SizedBox(height: 6),
              Text(title, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 6),
              Text(
                _registering
                    ? 'Crea una cuenta para guardar tus tareas.'
                    : 'Ingresa para consultar tus tareas.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Paleta.grafito,
                ),
              ),
              const SizedBox(height: 22),
              TextFormField(
                key: const ValueKey('auth-email'),
                controller: _email,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.mail_outline),
                ),
                enabled: !_busy,
                autofillHints: const [AutofillHints.email],
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  final email = value?.trim() ?? '';
                  if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                      .hasMatch(email)) {
                    return 'Escribe un correo válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('auth-password'),
                controller: _password,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                enabled: !_busy,
                obscureText: true,
                autofillHints: [
                  _registering
                      ? AutofillHints.newPassword
                      : AutofillHints.password,
                ],
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                validator: (value) => (value?.length ?? 0) >= 6
                    ? null
                    : 'Escribe al menos 6 caracteres.',
              ),
              if (_error case final error?) ...[
                const SizedBox(height: 14),
                Aviso(etiqueta: 'ERROR', mensaje: error),
              ],
              const SizedBox(height: 22),
              FilledButton(
                onPressed: _busy ? null : _submit,
                child: Text(_busy ? 'Procesando…' : title),
              ),
              const SizedBox(height: 6),
              const Divider(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      _registering ? '¿Ya te registraste?' : '¿Primera vez?',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  TextButton(
                    onPressed: _busy ? null : _toggleMode,
                    child: Text(
                      _registering ? 'Ya tengo cuenta' : 'Crear cuenta',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      body: PapelCuadriculado(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, layout) {
              final ancho = layout.maxWidth >= 860;
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 32, 30, 40),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: ancho ? 900 : 460),
                    child: ancho
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(child: presentacion),
                              const SizedBox(width: 56),
                              SizedBox(width: 430, child: formulario),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              presentacion,
                              const SizedBox(height: 28),
                              formulario,
                            ],
                          ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
