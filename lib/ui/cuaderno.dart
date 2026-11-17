import 'package:material_ui/material_ui.dart';

import 'theme.dart';

/// Fondo de papel cuadriculado de 24 px, como una hoja de cuaderno.
class PapelCuadriculado extends StatelessWidget {
  const PapelCuadriculado({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _Cuadricula(),
      isComplex: true,
      child: child,
    );
  }
}

class _Cuadricula extends CustomPainter {
  const _Cuadricula();

  static const _paso = 24.0;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Paleta.papel);
    final linea = Paint()
      ..color = Paleta.cuadricula
      ..strokeWidth = 1;
    for (var x = _paso; x < size.width; x += _paso) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linea);
    }
    for (var y = _paso; y < size.height; y += _paso) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linea);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Hoja blanca con borde de tinta y sombra sólida de sello desplazada.
class Hoja extends StatelessWidget {
  const Hoja({super.key, required this.child, this.padding = EdgeInsets.zero});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Paleta.hoja,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: Paleta.tinta, width: 1.5),
        boxShadow: const [BoxShadow(color: Paleta.sello, offset: Offset(6, 6))],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

/// Marca rectangular tipo sello para estados de una tarea.
class Sello extends StatelessWidget {
  const Sello(this.texto, {super.key, this.activo = true});

  final String texto;
  final bool activo;

  @override
  Widget build(BuildContext context) {
    final color = activo ? Paleta.sello : Paleta.grafito;
    return DecoratedBox(
      decoration: BoxDecoration(border: Border.all(color: color, width: 1.5)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(7, 3, 7, 2),
        child: Text(texto, style: Letra.etiqueta.copyWith(color: color)),
      ),
    );
  }
}

/// Aviso con etiqueta de ficha: errores y estados de conexión.
class Aviso extends StatelessWidget {
  const Aviso({super.key, required this.etiqueta, required this.mensaje});

  final String etiqueta;
  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Paleta.hoja,
          border: Border.all(color: Paleta.tinta, width: 1.5),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ColoredBox(
                color: Paleta.tinta,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Center(
                    child: ExcludeSemantics(
                      child: Text(
                        etiqueta,
                        style: Letra.etiqueta.copyWith(color: Paleta.papel),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Text(
                    mensaje,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Paleta.tinta,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _dias = ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];

/// Fecha de agenda: «LUN 16.11.2026».
String fechaDeAgenda(DateTime fecha) {
  String dos(int n) => n.toString().padLeft(2, '0');
  return '${_dias[fecha.weekday - 1]} ${dos(fecha.day)}.${dos(fecha.month)}.${fecha.year}';
}
