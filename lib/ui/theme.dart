import 'package:material_ui/material_ui.dart';

/// Identidad visual: cuaderno de cuadrícula. Hojas blancas con borde de
/// tinta sobre papel cuadriculado, acciones rectangulares en tinta y estados
/// marcados como sellos violeta. Sin formas de cápsula ni rellenos tonales.
abstract final class Paleta {
  /// Tinta casi negra con sesgo violeta: texto, bordes y botones principales.
  static const tinta = Color(0xff1f1a26);

  /// Grafito: texto secundario y metadatos.
  static const grafito = Color(0xff5e576a);

  /// Regla: líneas finas entre filas y bordes inactivos.
  static const regla = Color(0xffcfc9d8);

  /// Cuadrícula: líneas del papel de fondo.
  static const cuadricula = Color(0xffe3dfe9);

  /// Papel: fondo de todas las pantallas.
  static const papel = Color(0xfff3f1f5);

  /// Hoja: superficie donde se escribe.
  static const hoja = Color(0xffffffff);

  /// Sello: tinta violeta de sello escolar, único color de acento.
  static const sello = Color(0xff4a2c7f);
}

abstract final class Letra {
  static const titular = 'Bricolage';
  static const texto = 'Instrument';
  static const ficha = 'PlexMono';

  /// Etiquetas de ficha: mayúsculas monoespaciadas con espaciado amplio.
  static const etiqueta = TextStyle(
    fontFamily: ficha,
    fontWeight: FontWeight.w500,
    fontSize: 11.5,
    letterSpacing: 1.2,
    height: 1.3,
    color: Paleta.grafito,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}

const _esquina = BorderRadius.all(Radius.circular(2));
const _rectangulo = RoundedRectangleBorder(borderRadius: _esquina);

ThemeData temaCuaderno() {
  const colores = ColorScheme(
    brightness: Brightness.light,
    primary: Paleta.sello,
    onPrimary: Paleta.hoja,
    primaryContainer: Paleta.papel,
    onPrimaryContainer: Paleta.tinta,
    secondary: Paleta.tinta,
    onSecondary: Paleta.hoja,
    error: Paleta.tinta,
    onError: Paleta.hoja,
    surface: Paleta.hoja,
    onSurface: Paleta.tinta,
    onSurfaceVariant: Paleta.grafito,
    surfaceContainerLowest: Paleta.hoja,
    surfaceContainerLow: Paleta.hoja,
    surfaceContainer: Paleta.hoja,
    surfaceContainerHigh: Paleta.hoja,
    surfaceContainerHighest: Paleta.papel,
    outline: Paleta.tinta,
    outlineVariant: Paleta.regla,
    surfaceTint: Colors.transparent,
    inverseSurface: Paleta.tinta,
    onInverseSurface: Paleta.papel,
  );

  const base = TextStyle(fontFamily: Letra.texto, color: Paleta.tinta);
  const titular = TextStyle(
    fontFamily: Letra.titular,
    fontWeight: FontWeight.w700,
    color: Paleta.tinta,
    letterSpacing: -0.4,
    height: 1.05,
  );

  final botonPrincipal = ButtonStyle(
    shape: const WidgetStatePropertyAll(_rectangulo),
    minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
    padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: 22, vertical: 14),
    ),
    elevation: const WidgetStatePropertyAll(0),
    textStyle: const WidgetStatePropertyAll(
      TextStyle(
        fontFamily: Letra.texto,
        fontWeight: FontWeight.w600,
        fontSize: 15,
        letterSpacing: 0.2,
      ),
    ),
    backgroundColor: WidgetStateProperty.resolveWith(
      (estados) =>
          estados.contains(WidgetState.disabled) ? Paleta.regla : Paleta.tinta,
    ),
    foregroundColor: WidgetStateProperty.resolveWith(
      (estados) =>
          estados.contains(WidgetState.disabled) ? Paleta.grafito : Paleta.hoja,
    ),
    overlayColor: WidgetStateProperty.resolveWith(
      (estados) => estados.contains(WidgetState.pressed)
          ? Paleta.sello
          : estados.contains(WidgetState.hovered) ||
                estados.contains(WidgetState.focused)
          ? const Color(0xff3a3342)
          : null,
    ),
  );

  final botonTexto = ButtonStyle(
    shape: const WidgetStatePropertyAll(_rectangulo),
    minimumSize: const WidgetStatePropertyAll(Size(0, 44)),
    padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    ),
    textStyle: const WidgetStatePropertyAll(
      TextStyle(
        fontFamily: Letra.texto,
        fontWeight: FontWeight.w600,
        fontSize: 14.5,
      ),
    ),
    foregroundColor: WidgetStateProperty.resolveWith(
      (estados) =>
          estados.contains(WidgetState.disabled) ? Paleta.regla : Paleta.sello,
    ),
  );

  const borde = OutlineInputBorder(
    borderRadius: _esquina,
    borderSide: BorderSide(color: Paleta.regla, width: 1.2),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colores,
    fontFamily: Letra.texto,
    scaffoldBackgroundColor: Paleta.papel,
    splashFactory: InkRipple.splashFactory,
    textTheme: TextTheme(
      displaySmall: titular.copyWith(fontSize: 40),
      headlineMedium: titular.copyWith(fontSize: 34),
      headlineSmall: titular.copyWith(fontSize: 28),
      titleLarge: titular.copyWith(fontSize: 20, letterSpacing: -0.2),
      titleMedium: base.copyWith(fontWeight: FontWeight.w500, fontSize: 16),
      bodyLarge: base.copyWith(fontSize: 16, height: 1.45),
      bodyMedium: base.copyWith(fontSize: 14.5, height: 1.45),
      bodySmall: base.copyWith(fontSize: 13, color: Paleta.grafito),
      labelLarge: base.copyWith(fontWeight: FontWeight.w600, fontSize: 15),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Paleta.tinta,
      foregroundColor: Paleta.papel,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      toolbarHeight: 60,
      titleTextStyle: TextStyle(
        fontFamily: Letra.titular,
        fontWeight: FontWeight.w700,
        fontSize: 20,
        color: Paleta.papel,
        letterSpacing: -0.2,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(style: botonPrincipal),
    textButtonTheme: TextButtonThemeData(style: botonTexto),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: botonTexto.copyWith(
        foregroundColor: const WidgetStatePropertyAll(Paleta.tinta),
        side: const WidgetStatePropertyAll(
          BorderSide(color: Paleta.tinta, width: 1.5),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Paleta.hoja,
      border: borde,
      enabledBorder: borde,
      disabledBorder: borde,
      focusedBorder: borde.copyWith(
        borderSide: const BorderSide(color: Paleta.sello, width: 2),
      ),
      errorBorder: borde.copyWith(
        borderSide: const BorderSide(color: Paleta.tinta, width: 2),
      ),
      focusedErrorBorder: borde.copyWith(
        borderSide: const BorderSide(color: Paleta.tinta, width: 2.4),
      ),
      labelStyle: const TextStyle(color: Paleta.grafito),
      floatingLabelStyle: const TextStyle(
        color: Paleta.tinta,
        fontWeight: FontWeight.w600,
      ),
      errorStyle: const TextStyle(
        color: Paleta.tinta,
        fontWeight: FontWeight.w600,
        fontSize: 12.5,
      ),
      prefixIconColor: Paleta.grafito,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(1)),
      ),
      // Sin halo circular: el foco y el hover engrosan el borde (INC-007).
      side: WidgetStateBorderSide.resolveWith(
        (estados) =>
            estados.contains(WidgetState.focused) ||
                estados.contains(WidgetState.hovered)
            ? const BorderSide(color: Paleta.sello, width: 2.4)
            : const BorderSide(color: Paleta.tinta, width: 1.6),
      ),
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      fillColor: WidgetStateProperty.resolveWith(
        (estados) => estados.contains(WidgetState.selected)
            ? Paleta.sello
            : Colors.transparent,
      ),
      checkColor: const WidgetStatePropertyAll(Paleta.hoja),
    ),
    listTileTheme: const ListTileThemeData(
      shape: RoundedRectangleBorder(),
      contentPadding: EdgeInsets.fromLTRB(10, 6, 16, 6),
      minVerticalPadding: 10,
      iconColor: Paleta.grafito,
      textColor: Paleta.tinta,
    ),
    dividerTheme: const DividerThemeData(
      color: Paleta.regla,
      thickness: 1,
      space: 1,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: Paleta.hoja,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: _esquina,
        side: BorderSide(color: Paleta.tinta, width: 1.5),
      ),
      titleTextStyle: TextStyle(
        fontFamily: Letra.titular,
        fontWeight: FontWeight.w700,
        fontSize: 22,
        color: Paleta.tinta,
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Paleta.tinta,
      contentTextStyle: TextStyle(fontFamily: Letra.texto, color: Paleta.papel),
      shape: RoundedRectangleBorder(borderRadius: _esquina),
      behavior: SnackBarBehavior.floating,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Paleta.sello,
    ),
    scrollbarTheme: const ScrollbarThemeData(
      radius: Radius.zero,
      thickness: WidgetStatePropertyAll(6),
      thumbColor: WidgetStatePropertyAll(Paleta.grafito),
    ),
    tooltipTheme: const TooltipThemeData(
      decoration: BoxDecoration(color: Paleta.tinta, borderRadius: _esquina),
      textStyle: TextStyle(fontFamily: Letra.texto, color: Paleta.papel),
    ),
  );
}
