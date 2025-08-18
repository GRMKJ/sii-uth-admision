import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff006b5e),
      surfaceTint: Color(0xff006b5e),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff9ff2e1),
      onPrimaryContainer: Color(0xff005046),
      secondary: Color(0xff4a635e),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffcde8e1),
      onSecondaryContainer: Color(0xff334b46),
      tertiary: Color(0xff446279),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffcae6ff),
      onTertiaryContainer: Color(0xff2c4a60),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfff4fbf8),
      onSurface: Color(0xff171d1b),
      onSurfaceVariant: Color(0xff3f4946),
      outline: Color(0xff6f7976),
      outlineVariant: Color(0xffbec9c5),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2b3230),
      inversePrimary: Color(0xff83d5c5),
      primaryFixed: Color(0xff9ff2e1),
      onPrimaryFixed: Color(0xff00201b),
      primaryFixedDim: Color(0xff83d5c5),
      onPrimaryFixedVariant: Color(0xff005046),
      secondaryFixed: Color(0xffcde8e1),
      onSecondaryFixed: Color(0xff06201b),
      secondaryFixedDim: Color(0xffb1ccc5),
      onSecondaryFixedVariant: Color(0xff334b46),
      tertiaryFixed: Color(0xffcae6ff),
      onTertiaryFixed: Color(0xff001e30),
      tertiaryFixedDim: Color(0xffaccae5),
      onTertiaryFixedVariant: Color(0xff2c4a60),
      surfaceDim: Color(0xffd5dbd8),
      surfaceBright: Color(0xfff4fbf8),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffeff5f2),
      surfaceContainer: Color(0xffe9efec),
      surfaceContainerHigh: Color(0xffe3eae7),
      surfaceContainerHighest: Color(0xffdee4e1),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff003e36),
      surfaceTint: Color(0xff006b5e),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff207a6c),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff223b36),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff59726c),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff1a394e),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff537088),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff4fbf8),
      onSurface: Color(0xff0c1211),
      onSurfaceVariant: Color(0xff2f3836),
      outline: Color(0xff4b5452),
      outlineVariant: Color(0xff656f6c),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2b3230),
      inversePrimary: Color(0xff83d5c5),
      primaryFixed: Color(0xff207a6c),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff006054),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff59726c),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff415a54),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff537088),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff3a586f),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc1c8c5),
      surfaceBright: Color(0xfff4fbf8),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffeff5f2),
      surfaceContainer: Color(0xffe3eae7),
      surfaceContainerHigh: Color(0xffd8dedb),
      surfaceContainerHighest: Color(0xffcdd3d0),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff00332c),
      surfaceTint: Color(0xff006b5e),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff005349),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff18302c),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff354e49),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff0e2f44),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff2e4c62),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff4fbf8),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff252e2c),
      outlineVariant: Color(0xff414b49),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2b3230),
      inversePrimary: Color(0xff83d5c5),
      primaryFixed: Color(0xff005349),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff003a32),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff354e49),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff1f3732),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff2e4c62),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff16354b),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffb4bab7),
      surfaceBright: Color(0xfff4fbf8),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffecf2ef),
      surfaceContainer: Color(0xffdee4e1),
      surfaceContainerHigh: Color(0xffcfd6d3),
      surfaceContainerHighest: Color(0xffc1c8c5),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xff83d5c5),
      surfaceTint: Color(0xff83d5c5),
      onPrimary: Color(0xff003730),
      primaryContainer: Color(0xff005046),
      onPrimaryContainer: Color(0xff9ff2e1),
      secondary: Color(0xffb1ccc5),
      onSecondary: Color(0xff1c3530),
      secondaryContainer: Color(0xff334b46),
      onSecondaryContainer: Color(0xffcde8e1),
      tertiary: Color(0xffaccae5),
      onTertiary: Color(0xff133348),
      tertiaryContainer: Color(0xff2c4a60),
      onTertiaryContainer: Color(0xffcae6ff),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff0e1513),
      onSurface: Color(0xffdee4e1),
      onSurfaceVariant: Color(0xffbec9c5),
      outline: Color(0xff899390),
      outlineVariant: Color(0xff3f4946),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdee4e1),
      inversePrimary: Color(0xff006b5e),
      primaryFixed: Color(0xff9ff2e1),
      onPrimaryFixed: Color(0xff00201b),
      primaryFixedDim: Color(0xff83d5c5),
      onPrimaryFixedVariant: Color(0xff005046),
      secondaryFixed: Color(0xffcde8e1),
      onSecondaryFixed: Color(0xff06201b),
      secondaryFixedDim: Color(0xffb1ccc5),
      onSecondaryFixedVariant: Color(0xff334b46),
      tertiaryFixed: Color(0xffcae6ff),
      onTertiaryFixed: Color(0xff001e30),
      tertiaryFixedDim: Color(0xffaccae5),
      onTertiaryFixedVariant: Color(0xff2c4a60),
      surfaceDim: Color(0xff0e1513),
      surfaceBright: Color(0xff343b39),
      surfaceContainerLowest: Color(0xff090f0e),
      surfaceContainerLow: Color(0xff171d1b),
      surfaceContainer: Color(0xff1b211f),
      surfaceContainerHigh: Color(0xff252b2a),
      surfaceContainerHighest: Color(0xff303634),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xff99ecdb),
      surfaceTint: Color(0xff83d5c5),
      onPrimary: Color(0xff002b25),
      primaryContainer: Color(0xff4b9e90),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffc7e2db),
      onSecondary: Color(0xff112a25),
      secondaryContainer: Color(0xff7c9690),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffc1e0fb),
      onTertiary: Color(0xff05283d),
      tertiaryContainer: Color(0xff7694ad),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff0e1513),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffd4dfdb),
      outline: Color(0xffaab4b1),
      outlineVariant: Color(0xff88928f),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdee4e1),
      inversePrimary: Color(0xff005247),
      primaryFixed: Color(0xff9ff2e1),
      onPrimaryFixed: Color(0xff001511),
      primaryFixedDim: Color(0xff83d5c5),
      onPrimaryFixedVariant: Color(0xff003e36),
      secondaryFixed: Color(0xffcde8e1),
      onSecondaryFixed: Color(0xff001511),
      secondaryFixedDim: Color(0xffb1ccc5),
      onSecondaryFixedVariant: Color(0xff223b36),
      tertiaryFixed: Color(0xffcae6ff),
      onTertiaryFixed: Color(0xff001320),
      tertiaryFixedDim: Color(0xffaccae5),
      onTertiaryFixedVariant: Color(0xff1a394e),
      surfaceDim: Color(0xff0e1513),
      surfaceBright: Color(0xff3f4644),
      surfaceContainerLowest: Color(0xff040807),
      surfaceContainerLow: Color(0xff191f1d),
      surfaceContainer: Color(0xff232927),
      surfaceContainerHigh: Color(0xff2d3432),
      surfaceContainerHighest: Color(0xff383f3d),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffb0ffef),
      surfaceTint: Color(0xff83d5c5),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xff7fd1c1),
      onPrimaryContainer: Color(0xff000e0b),
      secondary: Color(0xffdaf6ee),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffadc8c1),
      onSecondaryContainer: Color(0xff000e0b),
      tertiary: Color(0xffe5f1ff),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffa8c6e1),
      onTertiaryContainer: Color(0xff000d17),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff0e1513),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffe8f2ee),
      outlineVariant: Color(0xffbbc5c1),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdee4e1),
      inversePrimary: Color(0xff005247),
      primaryFixed: Color(0xff9ff2e1),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xff83d5c5),
      onPrimaryFixedVariant: Color(0xff001511),
      secondaryFixed: Color(0xffcde8e1),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffb1ccc5),
      onSecondaryFixedVariant: Color(0xff001511),
      tertiaryFixed: Color(0xffcae6ff),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffaccae5),
      onTertiaryFixedVariant: Color(0xff001320),
      surfaceDim: Color(0xff0e1513),
      surfaceBright: Color(0xff4b514f),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff1b211f),
      surfaceContainer: Color(0xff2b3230),
      surfaceContainerHigh: Color(0xff363d3b),
      surfaceContainerHighest: Color(0xff424846),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }


  ThemeData theme(ColorScheme colorScheme) => ThemeData(
     useMaterial3: true,
     brightness: colorScheme.brightness,
     colorScheme: colorScheme,
     textTheme: textTheme.apply(
       bodyColor: colorScheme.onSurface,
       displayColor: colorScheme.onSurface,
     ),
     scaffoldBackgroundColor: colorScheme.background,
     canvasColor: colorScheme.surface,
  );


  List<ExtendedColor> get extendedColors => [
  ];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
