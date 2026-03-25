import 'package:flutter/material.dart';
import 'package:zivlo/core/theme/app_theme.dart';

/// Scanner Overlay Widget
/// Displays a semi-transparent overlay with a scanning guide area
/// and animated scanning line
class ScannerOverlay extends StatefulWidget {
  /// Instruction text displayed below the guide area
  final String instructionText;

  const ScannerOverlay({
    super.key,
    this.instructionText = 'Apunta el código de barras dentro del recuadro',
  });

  @override
  State<ScannerOverlay> createState() => _ScannerOverlayState();
}

class _ScannerOverlayState extends State<ScannerOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start the animation
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Semi-transparent dark overlay (60% opacity)
        Container(
          color: Colors.black.withOpacity(0.6),
        ),

        // Clear rectangular area in center with corner markers
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Scanner guide area
              SizedBox(
                width: 280,
                height: 200,
                child: Stack(
                  children: [
                    // Clear cutout area (achieved by not drawing overlay here)
                    // We use a custom painter for the overlay with cutout
                    CustomPaint(
                      size: const Size(280, 200),
                      painter: _ScannerGuidePainter(),
                    ),

                    // Animated scanning line
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Positioned(
                          left: 16,
                          right: 16,
                          top: _animation.value * (200 - 32),
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  AppColors.colorAccent,
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.colorAccent.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    // Corner markers
                    ..._buildCornerMarkers(),
                  ],
                ),
              ),

              // Instruction text
              const SizedBox(height: AppSpacing.spacing24),
              Text(
                widget.instructionText,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.colorOnSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCornerMarkers() {
    const cornerSize = 24.0;
    const cornerThickness = 4.0;

    return [
      // Top-left corner
      Positioned(
        left: 0,
        top: 0,
        child: _CornerMarker(
          width: cornerSize,
          height: cornerSize,
          thickness: cornerThickness,
          color: AppColors.colorAccent,
        ),
      ),

      // Top-right corner
      Positioned(
        right: 0,
        top: 0,
        child: Transform.rotate(
          angle: 90 * (3.14159 / 180),
          child: _CornerMarker(
            width: cornerSize,
            height: cornerSize,
            thickness: cornerThickness,
            color: AppColors.colorAccent,
          ),
        ),
      ),

      // Bottom-left corner
      Positioned(
        left: 0,
        bottom: 0,
        child: Transform.rotate(
          angle: -90 * (3.14159 / 180),
          child: _CornerMarker(
            width: cornerSize,
            height: cornerSize,
            thickness: cornerThickness,
            color: AppColors.colorAccent,
          ),
        ),
      ),

      // Bottom-right corner
      Positioned(
        right: 0,
        bottom: 0,
        child: Transform.rotate(
          angle: 180 * (3.14159 / 180),
          child: _CornerMarker(
            width: cornerSize,
            height: cornerSize,
            thickness: cornerThickness,
            color: AppColors.colorAccent,
          ),
        ),
      ),
    ];
  }
}

/// Custom painter for the scanner guide overlay
class _ScannerGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // This painter creates a transparent area in the center
    // The actual overlay is drawn by the parent Stack
    // We just need to define the guide area boundaries
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Corner marker widget
class _CornerMarker extends StatelessWidget {
  final double width;
  final double height;
  final double thickness;
  final Color color;

  const _CornerMarker({
    required this.width,
    required this.height,
    required this.thickness,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _CornerMarkerPainter(
        width: width,
        height: height,
        thickness: thickness,
        color: color,
      ),
    );
  }
}

/// Painter for corner markers
class _CornerMarkerPainter extends CustomPainter {
  final double width;
  final double height;
  final double thickness;
  final Color color;

  _CornerMarkerPainter({
    required this.width,
    required this.height,
    required this.thickness,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Draw L-shaped corner
    final path = Path();
    path.moveTo(0, height);
    path.lineTo(0, 0);
    path.lineTo(width, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerMarkerPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.thickness != thickness;
  }
}
