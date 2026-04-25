import 'package:flutter/material.dart';

class SettledUpIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: CustomPaint(
        painter: MountainsPainter(),
        size: Size(double.infinity, 200),
      ),
    );
  }
}

class MountainsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()..color = Color(0xFF4ECDC4);
    final paint2 = Paint()..color = Color(0xFF44A08D);
    final paint3 = Paint()..color = Color(0xFF8A2BE2);
    final paint4 = Paint()..color = Color(0xFF6B73FF);
    final paint5 = Paint()..color = Color(0xFF5D5D5D);

    final path1 = Path();
    path1.moveTo(0, size.height);
    path1.lineTo(size.width * 0.3, size.height * 0.4);
    path1.lineTo(size.width * 0.6, size.height);
    path1.close();
    canvas.drawPath(path1, paint1);

    final path2 = Path();
    path2.moveTo(size.width * 0.2, size.height);
    path2.lineTo(size.width * 0.5, size.height * 0.3);
    path2.lineTo(size.width * 0.8, size.height);
    path2.close();
    canvas.drawPath(path2, paint2);

    final path3 = Path();
    path3.moveTo(size.width * 0.4, size.height);
    path3.lineTo(size.width * 0.7, size.height * 0.35);
    path3.lineTo(size.width, size.height);
    path3.close();
    canvas.drawPath(path3, paint3);

    final path4 = Path();
    path4.moveTo(size.width * 0.6, size.height);
    path4.lineTo(size.width * 0.85, size.height * 0.45);
    path4.lineTo(size.width, size.height * 0.8);
    path4.close();
    canvas.drawPath(path4, paint4);

    final path5 = Path();
    path5.moveTo(size.width * 0.1, size.height);
    path5.lineTo(size.width * 0.4, size.height * 0.5);
    path5.lineTo(size.width * 0.7, size.height);
    path5.close();
    canvas.drawPath(path5, paint5);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
