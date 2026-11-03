import 'package:flutter/material.dart';
import '../../main.dart';

/// High-fidelity animated Splash / Launch Screen for Shiftly.
/// Features Cyber Neon ambient breathing glow, interlocking geometric "S" logo,
/// typographic reveal with glowing accent, and seamless transition to AppRootView.
class SplashScreen extends StatefulWidget {
  /// If [isDemoMode] is true, it stays on screen with a "Replay Animation"
  /// and "Enter App" button for client review and presentation.
  final bool isDemoMode;

  const SplashScreen({
    super.key,
    this.isDemoMode = false,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Staggered animation curves
  late final Animation<double> _glowAnimation;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoRotation;
  late final Animation<double> _logoGleam;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _taglineFade;
  late final Animation<double> _lineWidth;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    // 1. Ambient background glow breathing in (0% -> 40%)
    _glowAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
    );

    // 2. Logo scale & pop (15% -> 55%)
    _logoScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.15, 0.60, curve: Curves.easeOutBack),
    );

    // 3. Subtle logo alignment twist (-12 deg -> 0 deg)
    _logoRotation = Tween<double>(begin: -0.15, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    // 4. Logo gleam shimmer passing through (50% -> 75%)
    _logoGleam = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 0.75, curve: Curves.easeInOut),
    );

    // 5. Title 'Shiftly' slide & fade (45% -> 80%)
    _titleFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 0.75, curve: Curves.easeOut),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 0.78, curve: Curves.easeOutCubic),
      ),
    );

    // 6. Tagline reveal (65% -> 90%)
    _taglineFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.65, 0.90, curve: Curves.easeOut),
    );

    // 7. Neon pulse accent line expansion (55% -> 95%)
    _lineWidth = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.55, 0.95, curve: Curves.easeOutExpo),
    );

    _controller.forward();

    // Auto-navigate to main app if not running in standalone demo mode
    if (!widget.isDemoMode) {
      _controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Future.delayed(const Duration(milliseconds: 350), _proceedToApp);
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _replay() {
    _controller.reset();
    _controller.forward();
  }

  void _proceedToApp() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AppRootView(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Canvas background: Jet black in dark mode (#0A0A0A), deep slate in light mode
    final canvasBg = isDark ? const Color(0xFF0A0A0A) : const Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: canvasBg,
      body: Stack(
        children: [
          // ─── 1. Ambient Background Neon Aurora Orbs ────────────────────────
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, _) {
              final glow = _glowAnimation.value;
              return Stack(
                children: [
                  // Primary Cerulean Glow (Top Left)
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.28,
                    left: MediaQuery.of(context).size.width * 0.5 - 180,
                    child: Container(
                      width: 240 * glow,
                      height: 240 * glow,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF007BA7).withAlpha((120 * glow).toInt()),
                            const Color(0xFF007BA7).withAlpha(0),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Cyber Rose Glow (Bottom Right)
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.36,
                    left: MediaQuery.of(context).size.width * 0.5 - 40,
                    child: Container(
                      width: 220 * glow,
                      height: 220 * glow,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFFF2D95).withAlpha((100 * glow).toInt()),
                            const Color(0xFFFF2D95).withAlpha(0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // ─── 2. Subtle Cyber Mesh Grid Background ──────────────────────────
          Positioned.fill(
            child: CustomPaint(
              painter: _CyberGridPainter(
                lineColor: Colors.white.withAlpha(8),
              ),
            ),
          ),

          // ─── 3. Center Hero Brand Stage ────────────────────────────────────
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Shiftly Logo Emblem
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    return Transform.rotate(
                      angle: _logoRotation.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: Container(
                          width: 104,
                          height: 104,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF141418), Color(0xFF0D0D10)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: const Color(0xFF2E2E38),
                              width: 1.5,
                            ),
                            boxShadow: [
                              // Neon Cyan outer halo
                              BoxShadow(
                                color: const Color(0xFF007BA7).withAlpha(110),
                                blurRadius: 28,
                                spreadRadius: 2,
                                offset: const Offset(-4, -4),
                              ),
                              // Cyber Rose outer halo
                              BoxShadow(
                                color: const Color(0xFFFF2D95).withAlpha(100),
                                blurRadius: 28,
                                spreadRadius: 1,
                                offset: const Offset(4, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Shiftly Interlocking "S" Chevron Custom Paint
                              CustomPaint(
                                size: const Size(64, 64),
                                painter: _ShiftlyLogoPainter(
                                  gleamProgress: _logoGleam.value,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 28),

                // Animated Brand Title: "Shiftly"
                SlideTransition(
                  position: _titleSlide,
                  child: FadeTransition(
                    opacity: _titleFade,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const Text(
                          'Shift',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.8,
                          ),
                        ),
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFF007BA7), Color(0xFFFF2D95)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: const Text(
                            'ly',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Animated Neon Accent Line
                AnimatedBuilder(
                  animation: _lineWidth,
                  builder: (context, _) {
                    return Container(
                      width: 140 * _lineWidth.value,
                      height: 2.5,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0x00007BA7),
                            Color(0xFF007BA7),
                            Color(0xFFFF2D95),
                            Color(0x00FF2D95),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF2D95).withAlpha(120),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 14),

                // Animated Tagline
                FadeTransition(
                  opacity: _taglineFade,
                  child: Text(
                    'WORKFORCE & OPERATIONS REIMAGINED',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFB4B4BB).withAlpha(200),
                      letterSpacing: 3.2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── 4. Demo Review Controls (Interactive replay / skip) ───────────
          Positioned(
            top: 20,
            right: 20,
            child: SafeArea(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Replay Button
                  IconButton(
                    tooltip: 'Replay Animation',
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(16),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withAlpha(30)),
                      ),
                      child: const Icon(
                        Icons.refresh_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    onPressed: _replay,
                  ),
                  const SizedBox(width: 8),
                  // Enter App Button
                  TextButton(
                    onPressed: _proceedToApp,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      backgroundColor: const Color(0xFF007BA7).withAlpha(45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                          color: Color(0xFF007BA7),
                          width: 1,
                        ),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Enter App',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for the Shiftly geometric interlocking "S" logo.
/// Combines a sharp Cerulean shift chevron and Cyber Rose shift chevron
/// with an animated light gleam effect.
class _ShiftlyLogoPainter extends CustomPainter {
  final double gleamProgress;

  _ShiftlyLogoPainter({required this.gleamProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Top Chevron (Cerulean Blue gradient)
    final topPath = Path()
      ..moveTo(w * 0.72, h * 0.18)
      ..lineTo(w * 0.28, h * 0.18)
      ..cubicTo(w * 0.18, h * 0.18, w * 0.16, h * 0.30, w * 0.24, h * 0.38)
      ..lineTo(w * 0.68, h * 0.52)
      ..cubicTo(w * 0.78, h * 0.56, w * 0.82, h * 0.68, w * 0.74, h * 0.78)
      ..lineTo(w * 0.62, h * 0.88)
      ..lineTo(w * 0.74, h * 0.88)
      ..lineTo(w * 0.86, h * 0.72)
      ..cubicTo(w * 0.94, h * 0.60, w * 0.88, h * 0.44, w * 0.76, h * 0.40)
      ..lineTo(w * 0.36, h * 0.28)
      ..cubicTo(w * 0.30, h * 0.26, w * 0.32, h * 0.24, w * 0.38, h * 0.24)
      ..lineTo(w * 0.72, h * 0.24)
      ..close();

    // Bottom Chevron (Cyber Rose gradient)
    final bottomPath = Path()
      ..moveTo(w * 0.28, h * 0.82)
      ..lineTo(w * 0.72, h * 0.82)
      ..cubicTo(w * 0.82, h * 0.82, w * 0.84, h * 0.70, w * 0.76, h * 0.62)
      ..lineTo(w * 0.32, h * 0.48)
      ..cubicTo(w * 0.22, h * 0.44, w * 0.18, h * 0.32, w * 0.26, h * 0.22)
      ..lineTo(w * 0.38, h * 0.12)
      ..lineTo(w * 0.26, h * 0.12)
      ..lineTo(w * 0.14, h * 0.28)
      ..cubicTo(w * 0.06, h * 0.40, w * 0.12, h * 0.56, w * 0.24, h * 0.60)
      ..lineTo(w * 0.64, h * 0.72)
      ..cubicTo(w * 0.70, h * 0.74, w * 0.68, h * 0.76, w * 0.62, h * 0.76)
      ..lineTo(w * 0.28, h * 0.76)
      ..close();

    // Paint Top Chevron with Cerulean Gradient
    final topPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00A3E0), Color(0xFF007BA7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;
    canvas.drawPath(topPath, topPaint);

    // Paint Bottom Chevron with Cyber Rose Gradient
    final bottomPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF2D95), Color(0xFFD81B60)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;
    canvas.drawPath(bottomPath, bottomPaint);

    // Dynamic Gleam Shimmer Band
    if (gleamProgress > 0.0 && gleamProgress < 1.0) {
      final gleamX = -w * 0.5 + (w * 2.0 * gleamProgress);
      final gleamPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withAlpha(0),
            Colors.white.withAlpha(160),
            Colors.white.withAlpha(0),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromLTWH(gleamX, 0, w * 0.4, h))
        ..blendMode = BlendMode.screen;

      canvas.save();
      final fullPath = Path()
        ..addPath(topPath, Offset.zero)
        ..addPath(bottomPath, Offset.zero);
      canvas.clipPath(fullPath);
      canvas.drawRect(Rect.fromLTWH(gleamX, 0, w * 0.4, h), gleamPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ShiftlyLogoPainter oldDelegate) {
    return oldDelegate.gleamProgress != gleamProgress;
  }
}

/// Subtle cyber grid pattern for high-tech depth
class _CyberGridPainter extends CustomPainter {
  final Color lineColor;

  _CyberGridPainter({required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 0.8;

    const step = 44.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CyberGridPainter oldDelegate) => false;
}
