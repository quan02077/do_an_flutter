import 'package:flutter/material.dart';
import '../../../core/theme/linear_theme.dart';

class LinearEmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;

  const LinearEmptyState({
    super.key,
    this.title = 'No issues assigned to you',
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomPaint(
              size: const Size(120, 100),
              painter: _LinearWireframePainter(),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: LinearTheme.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.2,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: LinearTheme.textMuted,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LinearWireframePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 - 5;

    final brightPaint = Paint()
      ..color = const Color(0xFFD6D9E0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final dimPaint = Paint()
      ..color = const Color(0xFF484B55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    final faintPaint = Paint()
      ..color = const Color(0xFF2E313A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    final centerOval = Rect.fromCenter(center: Offset(cx, cy), width: 36, height: 18);
    canvas.drawOval(centerOval, brightPaint);

    final lowerOval = Rect.fromCenter(center: Offset(cx, cy + 14), width: 44, height: 16);
    canvas.drawOval(lowerOval, dimPaint);

    final bottomOval = Rect.fromCenter(center: Offset(cx, cy + 22), width: 34, height: 12);
    canvas.drawOval(bottomOval, faintPaint);

    final topArchPath = Path()
      ..moveTo(cx - 20, cy - 14)
      ..quadraticBezierTo(cx, cy - 24, cx + 20, cy - 14);
    canvas.drawPath(topArchPath, dimPaint);

    final leftPath = Path()
      ..moveTo(cx - 36, cy - 10)
      ..lineTo(cx - 46, cy)
      ..lineTo(cx - 36, cy + 10);
    canvas.drawPath(leftPath, brightPaint);

    final leftShadow = Path()
      ..moveTo(cx - 36, cy + 14)
      ..lineTo(cx - 46, cy + 22)
      ..lineTo(cx - 36, cy + 28);
    canvas.drawPath(leftShadow, faintPaint);

    final rightPath = Path()
      ..moveTo(cx + 36, cy - 10)
      ..lineTo(cx + 46, cy)
      ..lineTo(cx + 36, cy + 10);
    canvas.drawPath(rightPath, brightPaint);

    final rightShadow = Path()
      ..moveTo(cx + 36, cy + 14)
      ..lineTo(cx + 46, cy + 22)
      ..lineTo(cx + 36, cy + 28);
    canvas.drawPath(rightShadow, faintPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
