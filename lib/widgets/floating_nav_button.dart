import 'package:flutter/cupertino.dart';

import '../styles/app_styles.dart';

/// A 56×56 circular nav button positioned by the caller (typically
/// `Positioned(left: 20, bottom: 28, ...)`). Three intent-named variants:
///
///  - `FloatingNavButton.menu` — primary-green disc, white bars glyph, soft
///    green-tinted shadow. Opens a menu/overlay.
///  - `FloatingNavButton.close` — plain ink ×, no disc. Closes a menu/overlay.
///  - `FloatingNavButton.back` — cream disc, deep-green outline, deep-green
///    back arrow. Navigates back to a parent screen.
class FloatingNavButton extends StatefulWidget {
  final _FloatingNavButtonStyle _style;
  final VoidCallback onPressed;
  final String semanticLabel;

  const FloatingNavButton._({
    required _FloatingNavButtonStyle style,
    required this.onPressed,
    required this.semanticLabel,
  }) : _style = style;

  factory FloatingNavButton.menu({required VoidCallback onPressed}) {
    return FloatingNavButton._(
      style: _FloatingNavButtonStyle.menu,
      onPressed: onPressed,
      semanticLabel: 'Open menu',
    );
  }

  factory FloatingNavButton.close({required VoidCallback onPressed}) {
    return FloatingNavButton._(
      style: _FloatingNavButtonStyle.close,
      onPressed: onPressed,
      semanticLabel: 'Close menu',
    );
  }

  factory FloatingNavButton.back({required VoidCallback onPressed}) {
    return FloatingNavButton._(
      style: _FloatingNavButtonStyle.back,
      onPressed: onPressed,
      semanticLabel: 'Back',
    );
  }

  @override
  State<FloatingNavButton> createState() => _FloatingNavButtonState();
}

enum _FloatingNavButtonStyle { menu, close, back }

class _FloatingNavButtonState extends State<FloatingNavButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final style = widget._style;
    final pressedOpacity = style == _FloatingNavButtonStyle.close ? 0.5 : 0.65;

    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onPressed,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 120),
          opacity: _pressed ? pressedOpacity : 1.0,
          child: SizedBox(
            width: 56,
            height: 56,
            child: _buildVisual(style),
          ),
        ),
      ),
    );
  }

  Widget _buildVisual(_FloatingNavButtonStyle style) {
    switch (style) {
      case _FloatingNavButtonStyle.menu:
        return Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryGreen,
            boxShadow: AppShadows.fab,
          ),
          alignment: Alignment.center,
          child: const _BarsIcon(
            color: AppColors.surfaceWhite,
            size: 24,
          ),
        );
      case _FloatingNavButtonStyle.close:
        // Plain ink × — no disc, no shadow.
        return const Center(
          child: _CloseIcon(
            color: AppColors.ink,
            size: 26,
            strokeWidth: 2.2,
          ),
        );
      case _FloatingNavButtonStyle.back:
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.cream,
            border: Border.all(
              color: AppColors.deepGreen,
              width: 2,
            ),
          ),
          alignment: Alignment.center,
          child: const _BackChevron(
            color: AppColors.deepGreen,
            size: 22,
            strokeWidth: 2.4,
          ),
        );
    }
  }
}

class _BarsIcon extends StatelessWidget {
  final Color color;
  final double size;

  const _BarsIcon({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _BarsPainter(color: color),
    );
  }
}

class _BarsPainter extends CustomPainter {
  final Color color;

  _BarsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Three horizontal lines at y = 7, 12, 17 of a 24-grid.
    final scale = size.width / 24.0;
    void line(double yUnits) {
      final y = yUnits * scale;
      canvas.drawLine(
        Offset(4 * scale, y),
        Offset(20 * scale, y),
        paint,
      );
    }

    line(7);
    line(12);
    line(17);
  }

  @override
  bool shouldRepaint(_BarsPainter oldDelegate) => oldDelegate.color != color;
}

class _CloseIcon extends StatelessWidget {
  final Color color;
  final double size;
  final double strokeWidth;

  const _CloseIcon({
    required this.color,
    required this.size,
    required this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _ClosePainter(color: color, strokeWidth: strokeWidth),
    );
  }
}

class _ClosePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _ClosePainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // Two diagonal lines, 6→18 in a 24-grid.
    final scale = size.width / 24.0;
    canvas.drawLine(
      Offset(6 * scale, 6 * scale),
      Offset(18 * scale, 18 * scale),
      paint,
    );
    canvas.drawLine(
      Offset(18 * scale, 6 * scale),
      Offset(6 * scale, 18 * scale),
      paint,
    );
  }

  @override
  bool shouldRepaint(_ClosePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

class _BackChevron extends StatelessWidget {
  final Color color;
  final double size;
  final double strokeWidth;

  const _BackChevron({
    required this.color,
    required this.size,
    required this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _BackChevronPainter(color: color, strokeWidth: strokeWidth),
    );
  }
}

class _BackChevronPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _BackChevronPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // < shape with vertices (15,6) → (9,12) → (15,18) on a 24-grid.
    final scale = size.width / 24.0;
    final path = Path()
      ..moveTo(15 * scale, 6 * scale)
      ..lineTo(9 * scale, 12 * scale)
      ..lineTo(15 * scale, 18 * scale);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BackChevronPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}
