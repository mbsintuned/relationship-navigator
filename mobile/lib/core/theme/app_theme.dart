import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

/// Application theme configuration
/// Provides consistent theming across the entire app
class AppTheme {
  AppTheme._();
  
  // Color scheme configuration
  static const FlexScheme _colorScheme = FlexScheme.blueM3;
  
  // Light theme configuration
  static ThemeData get lightTheme {
    return FlexThemeData.light(
      scheme: _colorScheme,
      surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
      blendLevel: 9,
      appBarOpacity: 0.95,
      subThemesData: _subThemesData,
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      fontFamily: 'Inter',
    ).copyWith(
      // Custom theme extensions
      extensions: [
        _customColors.light,
        _customTextStyles,
        _customSpacing,
      ],
    );
  }
  
  // Dark theme configuration
  static ThemeData get darkTheme {
    return FlexThemeData.dark(
      scheme: _colorScheme,
      surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
      blendLevel: 15,
      appBarOpacity: 0.90,
      subThemesData: _subThemesData,
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      fontFamily: 'Inter',
    ).copyWith(
      // Custom theme extensions
      extensions: [
        _customColors.dark,
        _customTextStyles,
        _customSpacing,
      ],
    );
  }
  
  // Sub-theme configurations for consistent component styling
  static const FlexSubThemesData _subThemesData = FlexSubThemesData(
    // Card theme
    cardRadius: 16.0,
    cardElevation: 2.0,
    
    // Button themes
    elevatedButtonRadius: 12.0,
    elevatedButtonElevation: 1.0,
    outlinedButtonRadius: 12.0,
    textButtonRadius: 12.0,
    
    // Input decoration theme
    inputDecoratorRadius: 12.0,
    inputDecoratorBorderType: FlexInputBorderType.outline,
    inputDecoratorFocusedHasBorder: true,
    
    // App bar theme
    appBarCenterTitle: false,
    appBarScrolledUnderElevation: 1.0,
    
    // Navigation themes
    navigationBarOpacity: 0.95,
    navigationBarHeight: 80.0,
    navigationBarLabelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    
    // Chip theme
    chipRadius: 8.0,
    chipBlendColors: true,
    
    // Dialog theme
    dialogRadius: 20.0,
    dialogElevation: 6.0,
    
    // Bottom sheet theme
    bottomSheetRadius: 20.0,
    
    // Drawer theme
    drawerRadius: 16.0,
    
    // Switch and checkbox themes
    switchAdaptiveCupertinoLike: true,
    checkboxAdaptiveCupertinoLike: true,
  );
  
  // Custom colors extension
  static const _CustomColorsExtension _customColors = _CustomColorsExtension(
    light: _CustomColors(
      success: Color(0xFF10B981),
      warning: Color(0xFFF59E0B),
      info: Color(0xFF3B82F6),
      relationshipHealthGood: Color(0xFF10B981),
      relationshipHealthNeutral: Color(0xFFF59E0B),
      relationshipHealthPoor: Color(0xFFEF4444),
      personalityPrimary: Color(0xFF8B5CF6),
      personalitySecondary: Color(0xFFEC4899),
      astrologyAccent: Color(0xFFF97316),
      insightHighlight: Color(0xFF06B6D4),
    ),
    dark: _CustomColors(
      success: Color(0xFF059669),
      warning: Color(0xFFD97706),
      info: Color(0xFF2563EB),
      relationshipHealthGood: Color(0xFF059669),
      relationshipHealthNeutral: Color(0xFFD97706),
      relationshipHealthPoor: Color(0xFFDC2626),
      personalityPrimary: Color(0xFF7C3AED),
      personalitySecondary: Color(0xFFDB2777),
      astrologyAccent: Color(0xFFEA580C),
      insightHighlight: Color(0xFF0891B2),
    ),
  );
  
  // Custom text styles extension
  static const CustomTextStyles _customTextStyles = CustomTextStyles();
  
  // Custom spacing extension
  static const CustomSpacing _customSpacing = CustomSpacing();
}

// Custom colors that aren't part of Material Design
@immutable
class _CustomColors extends ThemeExtension<_CustomColors> {
  final Color success;
  final Color warning;
  final Color info;
  final Color relationshipHealthGood;
  final Color relationshipHealthNeutral;
  final Color relationshipHealthPoor;
  final Color personalityPrimary;
  final Color personalitySecondary;
  final Color astrologyAccent;
  final Color insightHighlight;
  
  const _CustomColors({
    required this.success,
    required this.warning,
    required this.info,
    required this.relationshipHealthGood,
    required this.relationshipHealthNeutral,
    required this.relationshipHealthPoor,
    required this.personalityPrimary,
    required this.personalitySecondary,
    required this.astrologyAccent,
    required this.insightHighlight,
  });
  
  @override
  _CustomColors copyWith({
    Color? success,
    Color? warning,
    Color? info,
    Color? relationshipHealthGood,
    Color? relationshipHealthNeutral,
    Color? relationshipHealthPoor,
    Color? personalityPrimary,
    Color? personalitySecondary,
    Color? astrologyAccent,
    Color? insightHighlight,
  }) {
    return _CustomColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      relationshipHealthGood: relationshipHealthGood ?? this.relationshipHealthGood,
      relationshipHealthNeutral: relationshipHealthNeutral ?? this.relationshipHealthNeutral,
      relationshipHealthPoor: relationshipHealthPoor ?? this.relationshipHealthPoor,
      personalityPrimary: personalityPrimary ?? this.personalityPrimary,
      personalitySecondary: personalitySecondary ?? this.personalitySecondary,
      astrologyAccent: astrologyAccent ?? this.astrologyAccent,
      insightHighlight: insightHighlight ?? this.insightHighlight,
    );
  }
  
  @override
  _CustomColors lerp(covariant ThemeExtension<_CustomColors>? other, double t) {
    if (other is! _CustomColors) return this;
    
    return _CustomColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      relationshipHealthGood: Color.lerp(relationshipHealthGood, other.relationshipHealthGood, t)!,
      relationshipHealthNeutral: Color.lerp(relationshipHealthNeutral, other.relationshipHealthNeutral, t)!,
      relationshipHealthPoor: Color.lerp(relationshipHealthPoor, other.relationshipHealthPoor, t)!,
      personalityPrimary: Color.lerp(personalityPrimary, other.personalityPrimary, t)!,
      personalitySecondary: Color.lerp(personalitySecondary, other.personalitySecondary, t)!,
      astrologyAccent: Color.lerp(astrologyAccent, other.astrologyAccent, t)!,
      insightHighlight: Color.lerp(insightHighlight, other.insightHighlight, t)!,
    );
  }
}

class _CustomColorsExtension {
  final _CustomColors light;
  final _CustomColors dark;
  
  const _CustomColorsExtension({
    required this.light,
    required this.dark,
  });
}

// Custom text styles for app-specific typography
@immutable
class CustomTextStyles extends ThemeExtension<CustomTextStyles> {
  final TextStyle insightTitle;
  final TextStyle insightDescription;
  final TextStyle scoreLabel;
  final TextStyle scoreValue;
  final TextStyle profileName;
  final TextStyle relationshipType;
  final TextStyle assessmentQuestion;
  final TextStyle taskTitle;
  final TextStyle taskDescription;
  
  const CustomTextStyles({
    this.insightTitle = const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.3,
    ),
    this.insightDescription = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),
    this.scoreLabel = const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
    this.scoreValue = const TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      height: 1.0,
    ),
    this.profileName = const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 1.2,
    ),
    this.relationshipType = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.3,
    ),
    this.assessmentQuestion = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),
    this.taskTitle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.3,
    ),
    this.taskDescription = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),
  });
  
  @override
  CustomTextStyles copyWith({
    TextStyle? insightTitle,
    TextStyle? insightDescription,
    TextStyle? scoreLabel,
    TextStyle? scoreValue,
    TextStyle? profileName,
    TextStyle? relationshipType,
    TextStyle? assessmentQuestion,
    TextStyle? taskTitle,
    TextStyle? taskDescription,
  }) {
    return CustomTextStyles(
      insightTitle: insightTitle ?? this.insightTitle,
      insightDescription: insightDescription ?? this.insightDescription,
      scoreLabel: scoreLabel ?? this.scoreLabel,
      scoreValue: scoreValue ?? this.scoreValue,
      profileName: profileName ?? this.profileName,
      relationshipType: relationshipType ?? this.relationshipType,
      assessmentQuestion: assessmentQuestion ?? this.assessmentQuestion,
      taskTitle: taskTitle ?? this.taskTitle,
      taskDescription: taskDescription ?? this.taskDescription,
    );
  }
  
  @override
  CustomTextStyles lerp(covariant ThemeExtension<CustomTextStyles>? other, double t) {
    if (other is! CustomTextStyles) return this;
    
    return CustomTextStyles(
      insightTitle: TextStyle.lerp(insightTitle, other.insightTitle, t)!,
      insightDescription: TextStyle.lerp(insightDescription, other.insightDescription, t)!,
      scoreLabel: TextStyle.lerp(scoreLabel, other.scoreLabel, t)!,
      scoreValue: TextStyle.lerp(scoreValue, other.scoreValue, t)!,
      profileName: TextStyle.lerp(profileName, other.profileName, t)!,
      relationshipType: TextStyle.lerp(relationshipType, other.relationshipType, t)!,
      assessmentQuestion: TextStyle.lerp(assessmentQuestion, other.assessmentQuestion, t)!,
      taskTitle: TextStyle.lerp(taskTitle, other.taskTitle, t)!,
      taskDescription: TextStyle.lerp(taskDescription, other.taskDescription, t)!,
    );
  }
}

// Custom spacing values for consistent layout
@immutable
class CustomSpacing extends ThemeExtension<CustomSpacing> {
  final double xs; // 4.0
  final double sm; // 8.0
  final double md; // 16.0
  final double lg; // 24.0
  final double xl; // 32.0
  final double xxl; // 48.0
  
  const CustomSpacing({
    this.xs = 4.0,
    this.sm = 8.0,
    this.md = 16.0,
    this.lg = 24.0,
    this.xl = 32.0,
    this.xxl = 48.0,
  });
  
  @override
  CustomSpacing copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
  }) {
    return CustomSpacing(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
    );
  }
  
  @override
  CustomSpacing lerp(covariant ThemeExtension<CustomSpacing>? other, double t) {
    return this; // Spacing values don't interpolate
  }
}

// Extension methods for easy access to custom theme elements
extension ThemeExtensions on ThemeData {
  _CustomColors get customColors => extension<_CustomColors>()!;
  CustomTextStyles get customTextStyles => extension<CustomTextStyles>()!;
  CustomSpacing get customSpacing => extension<CustomSpacing>()!;
}

// Helper methods for dynamic theme-based styling
class ThemeHelpers {
  ThemeHelpers._();
  
  /// Returns appropriate color based on relationship health score
  static Color relationshipHealthColor(BuildContext context, int score) {
    final theme = Theme.of(context);
    final customColors = theme.customColors;
    
    if (score >= 70) {
      return customColors.relationshipHealthGood;
    } else if (score >= 40) {
      return customColors.relationshipHealthNeutral;
    } else {
      return customColors.relationshipHealthPoor;
    }
  }
  
  /// Returns appropriate icon based on relationship type
  static IconData relationshipTypeIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'family':
        return Icons.family_restroom;
      case 'friend':
        return Icons.group;
      case 'romantic':
        return Icons.favorite;
      case 'professional':
        return Icons.work;
      case 'self':
        return Icons.person;
      default:
        return Icons.person_outline;
    }
  }
  
  /// Returns assessment category color
  static Color assessmentCategoryColor(BuildContext context, String category) {
    final theme = Theme.of(context);
    final customColors = theme.customColors;
    
    switch (category.toLowerCase()) {
      case 'personality':
        return customColors.personalityPrimary;
      case 'relational':
        return customColors.personalitySecondary;
      case 'emotional':
        return customColors.info;
      case 'alternative':
        return customColors.astrologyAccent;
      default:
        return theme.colorScheme.primary;
    }
  }
}
