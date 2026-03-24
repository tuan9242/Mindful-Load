import 'dart:math' as math;
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnim;
  late Animation<double> _glowAnim;
  final int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _glowAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final secondaryColor = theme.colorScheme.secondary;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final secondaryTextColor = theme.textTheme.bodySmall?.color ?? Colors.grey;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top logo row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.self_improvement,
                      color: secondaryColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'TÂM AN',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),

            // Glowing head illustration
            Expanded(
              flex: 5,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Center(
                    child: ScaleTransition(
                      scale: _pulseAnim,
                      child: SizedBox(
                        width: 240,
                        height: 240,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer glow ring
                            Container(
                              width: 230,
                              height: 230,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: secondaryColor
                                        .withValues(alpha: 0.15 * _glowAnim.value),
                                    blurRadius: 60,
                                    spreadRadius: 20,
                                  ),
                                  BoxShadow(
                                    color: primaryColor
                                        .withValues(alpha: 0.2 * _glowAnim.value),
                                    blurRadius: 40,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                            // Middle circle
                            Container(
                              width: 190,
                              height: 190,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    secondaryColor
                                        .withValues(alpha: 0.12 * _glowAnim.value),
                                    primaryColor.withValues(alpha: 0.08),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            // Inner circle with head illustration
                            Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    primaryColor.withValues(alpha: 0.3),
                                    secondaryColor.withValues(alpha: 0.1),
                                  ],
                                ),
                                border: Border.all(
                                  color:
                                      secondaryColor.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: CustomPaint(
                                painter: _HeadPainter(
                                  glowOpacity: _glowAnim.value,
                                  primaryColor: primaryColor,
                                  secondaryColor: secondaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Text content
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          height: 1.3,
                        ),
                        children: [
                          const TextSpan(text: 'Chào mừng bạn\nđến tới '),
                          TextSpan(
                            text: 'Tâm An',
                            style: TextStyle(
                              color: secondaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Khám phá nguyên nhân gốc rễ của sự căng thẳng và tìm lại sự cân bằng qua nhật ký cảm xúc thông minh.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // CTA button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/mood-check-in',
                            arguments: {'isOnboarding': true},
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 8,
                          shadowColor: primaryColor.withValues(alpha: 0.4),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Khám phá ngay',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _HeadPainter extends CustomPainter {
  final double glowOpacity;
  final Color primaryColor;
  final Color secondaryColor;

  _HeadPainter({
    required this.glowOpacity,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = secondaryColor.withValues(alpha: 0.7 * glowOpacity);

    // Head outline
    final headPath = Path();
    headPath.moveTo(cx, cy - 52);
    headPath.cubicTo(cx + 34, cy - 52, cx + 40, cy - 20, cx + 38, cy + 10);
    headPath.cubicTo(cx + 36, cy + 30, cx + 22, cy + 48, cx, cy + 52);
    headPath.cubicTo(cx - 22, cy + 48, cx - 36, cy + 30, cx - 38, cy + 10);
    headPath.cubicTo(cx - 40, cy - 20, cx - 34, cy - 52, cx, cy - 52);

    canvas.drawPath(headPath, paint);

    // Neural lines inside head
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = primaryColor.withValues(alpha: 0.6 * glowOpacity);

    // Draw random neural connections
    final random = math.Random(42);
    final points = <Offset>[];
    for (int i = 0; i < 10; i++) {
      final angle = random.nextDouble() * 2 * math.pi;
      final r = random.nextDouble() * 28 + 8;
      points.add(Offset(cx + r * math.cos(angle), cy - 10 + r * math.sin(angle)));
    }

    for (int i = 0; i < points.length; i++) {
      for (int j = i + 1; j < points.length; j++) {
        if (random.nextDouble() > 0.5) {
          canvas.drawLine(points[i], points[j], linePaint);
        }
      }
    }

    // Draw small dots at nodes
    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = secondaryColor.withValues(alpha: glowOpacity);

    for (final pt in points) {
      canvas.drawCircle(pt, 2, dotPaint);
    }

    // Eyes
    final eyePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = secondaryColor.withValues(alpha: 0.9 * glowOpacity);
    canvas.drawCircle(Offset(cx - 12, cy + 2), 3.5, eyePaint);
    canvas.drawCircle(Offset(cx + 12, cy + 2), 3.5, eyePaint);

    // Neck
    final neckPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = secondaryColor.withValues(alpha: 0.5 * glowOpacity);
    canvas.drawLine(Offset(cx - 10, cy + 50), Offset(cx - 14, cy + 65), neckPaint);
    canvas.drawLine(Offset(cx + 10, cy + 50), Offset(cx + 14, cy + 65), neckPaint);
    canvas.drawLine(Offset(cx - 14, cy + 65), Offset(cx + 14, cy + 65), neckPaint);
  }

  @override
  bool shouldRepaint(_HeadPainter old) => old.glowOpacity != glowOpacity;
}
