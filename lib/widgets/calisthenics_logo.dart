import 'package:flutter/material.dart';

class CalisthenicsLogo extends StatelessWidget {
  const CalisthenicsLogo({super.key, this.size = 160});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CalisthenicsLogoPainter(),
      ),
    );
  }
}

class _CalisthenicsLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final blue = const Color(0xFF0A4CFF);
    final white = Colors.white;

    // Fondo rectangular
    final bg = Paint()..color = blue;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      const Radius.circular(22),
    );
    canvas.drawRRect(rect, bg);

    // Área interior
    const pad = 20.0;
    final content = Rect.fromLTWH(pad, pad, w - pad * 2, h - pad * 2);

    // FIERROS MÁS LARGOS (postes)
    final postW = content.width * 0.12;
    final postH = content.height * 0.80;         // AUMENTADO (antes 0.65)
    final postY = content.top + content.height * 0.05; // Más arriba

    final postPaint = Paint()..color = white;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(content.left, postY, postW, postH),
        const Radius.circular(8),
      ),
      postPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(content.right - postW, postY, postW, postH),
        const Radius.circular(8),
      ),
      postPaint,
    );

    // Barra superior (rectangular)
    final barPaint = Paint()..color = white;
    final barH = content.height * 0.10;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          content.left + postW - 6,
          postY,
          content.width - postW * 2 + 12,
          barH,
        ),
        const Radius.circular(6),
      ),
      barPaint,
    );

    // Posición de referencia del atleta
    final headR = content.width * 0.10;
    final headCenter = Offset(
      content.center.dx,
      postY + barH + headR * 1.2,
    );

    final bodyColor = white;

    // Cabeza
    canvas.drawCircle(headCenter, headR, Paint()..color = bodyColor);

    // Brazos
    final gripY = postY + barH;
    final shoulderY = headCenter.dy + headR * 0.8;

    final armPaint = Paint()
      ..color = bodyColor
      ..strokeWidth = content.width * 0.06
      ..strokeCap = StrokeCap.round;

    final handOffsetX = content.width * 0.22;

    canvas.drawLine(
      Offset(headCenter.dx - headR * 0.6, shoulderY),
      Offset(headCenter.dx - handOffsetX, gripY),
      armPaint,
    );

    canvas.drawLine(
      Offset(headCenter.dx + headR * 0.6, shoulderY),
      Offset(headCenter.dx + handOffsetX, gripY),
      armPaint,
    );

    // Torso
    final torsoW = content.width * 0.22;
    final torsoH = content.height * 0.30;

    final torso = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(headCenter.dx, shoulderY + torsoH * 0.55),
        width: torsoW,
        height: torsoH,
      ),
      const Radius.circular(10),
    );
    canvas.drawRRect(torso, Paint()..color = bodyColor);

    // Piernas
    final hipY = torso.outerRect.bottom - torsoH * 0.10;

    final legPaint = Paint()
      ..color = bodyColor
      ..strokeWidth = content.width * 0.07
      ..strokeCap = StrokeCap.round;

    final hipLeft = Offset(headCenter.dx - torsoW * 0.30, hipY);
    final hipRight = Offset(headCenter.dx + torsoW * 0.30, hipY);

    final kneeOffset = content.height * 0.18; // más largo

    final kneeLeft = Offset(hipLeft.dx - content.width * 0.04, hipY + kneeOffset);
    final kneeRight = Offset(hipRight.dx + content.width * 0.04, hipY + kneeOffset);

    final footLeft = Offset(kneeLeft.dx, kneeLeft.dy + content.height * 0.12);
    final footRight = Offset(kneeRight.dx, kneeRight.dy + content.height * 0.12);

    canvas.drawLine(hipLeft, kneeLeft, legPaint);
    canvas.drawLine(kneeLeft, footLeft, legPaint);

    canvas.drawLine(hipRight, kneeRight, legPaint);
    canvas.drawLine(kneeRight, footRight, legPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
