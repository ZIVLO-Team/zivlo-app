import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'injection_container.dart' as di;
import 'core/theme/app_theme.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependencies
  await di.initializeDependencies();
  
  // Run app
  runApp(const ZivloApp());
}

/// Main Application Widget
class ZivloApp extends StatelessWidget {
  const ZivloApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: di.getBlocProviders(),
      child: MaterialApp(
        title: 'Zivlo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          primaryColor: AppColors.colorPrimary,
          scaffoldBackgroundColor: AppColors.colorBackground,
          colorScheme: const ColorScheme.dark(
            primary: AppColors.colorPrimary,
            secondary: AppColors.colorAccent,
            surface: AppColors.colorSurface,
            error: AppColors.colorError,
            onPrimary: AppColors.colorOnSurface,
            onSecondary: AppColors.colorOnSurface,
            onSurface: AppColors.colorOnSurface,
            onError: AppColors.colorOnSurface,
          ),
          textTheme: AppTypography.textTheme,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.colorPrimary,
            foregroundColor: AppColors.colorOnSurface,
            elevation: 0,
            centerTitle: false,
          ),
          cardTheme: CardTheme(
            color: AppColors.colorSurface,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.colorAccent,
              foregroundColor: AppColors.colorOnSurface,
              elevation: 2,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spacing24,
                vertical: AppSpacing.spacing16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.radiusXL),
              ),
              textStyle: AppTypography.textTheme.labelLarge,
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: AppColors.colorAccent,
            foregroundColor: AppColors.colorOnSurface,
            elevation: 6,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.colorSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
              borderSide: BorderSide(color: AppColors.colorOnSurfaceMuted, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
              borderSide: const BorderSide(color: AppColors.colorAccent, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
              borderSide: const BorderSide(color: AppColors.colorError, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spacing16,
              vertical: AppSpacing.spacing12,
            ),
          ),
        ),
        home: const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.point_of_sale,
                  size: 80,
                  color: AppColors.colorAccent,
                ),
                SizedBox(height: AppSpacing.spacing24),
                Text(
                  'Zivlo',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.colorOnSurface,
                  ),
                ),
                SizedBox(height: AppSpacing.spacing8),
                Text(
                  'Cobra en segundos. Sin internet. Sin complicaciones.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.colorOnSurfaceMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
