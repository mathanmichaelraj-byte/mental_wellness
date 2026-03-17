import 'package:flutter/material.dart';
import 'onboarding_tooltip.dart';

class OnboardingOverlay extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final bool isLast;
  final int currentStep;
  final int totalSteps;

  const OnboardingOverlay({
    super.key,
    required this.title,
    required this.description,
    required this.onNext,
    required this.onSkip,
    this.isLast = false,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        CustomPaint(
          painter: SpotlightPainter(stepIndex: currentStep - 1, size: size),
          size: Size.infinite,
        ),
        Positioned(
          top: 20,
          left: 20,
          right: 20,
          child: OnboardingTooltip(
            title: title,
            description: description,
            onNext: onNext,
            onSkip: onSkip,
            isLast: isLast,
            currentStep: currentStep,
            totalSteps: totalSteps,
          ),
        ),
      ],
    );
  }
}

class SpotlightPainter extends CustomPainter {
  final int stepIndex;
  final Size size;

  SpotlightPainter({required this.stepIndex, required this.size});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final path = Path();
    path.addRect(Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height));

    Rect? highlightRect;

    switch (stepIndex) {
      case 1:
        highlightRect = Rect.fromLTWH(
          canvasSize.width - 170,
          canvasSize.height - 75,
          155,
          60,
        );
        break;
      case 2:
        highlightRect = Rect.fromLTWH(
          20,
          canvasSize.height - 75,
          canvasSize.width - 40,
          canvasSize.height * 0.35,
        );
        break;
      case 3:
        highlightRect = Rect.fromLTWH(
          20,
          canvasSize.height - 262,
          (canvasSize.width - 50) / 2 - 0.5,
          canvasSize.height * 0.20,
        );
        break;
      case 4:
        highlightRect = Rect.fromLTWH(
          (canvasSize.width - 50) / 2 + 30,
          canvasSize.height - 262,
          (canvasSize.width - 50) / 2 - 0.5,
          canvasSize.height * 0.20,
        );
        break;
    }

    if (highlightRect != null) {
      final rRect = RRect.fromRectAndRadius(highlightRect, const Radius.circular(16));
      path.addRRect(rRect);
      path.fillType = PathFillType.evenOdd;

      canvas.drawPath(path, Paint()..color = Colors.black.withOpacity(0.8));

      canvas.drawRRect(
        rRect,
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
    } else {
      canvas.drawPath(path, Paint()..color = Colors.black.withOpacity(0.8));
    }
  }

  @override
  bool shouldRepaint(SpotlightPainter oldDelegate) {
    return oldDelegate.stepIndex != stepIndex;
  }
}
