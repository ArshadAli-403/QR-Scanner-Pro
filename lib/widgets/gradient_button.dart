// lib/widgets/gradient_button.dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class GradientButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final List<Color> gradientColors;
  final double width;
  final double height;
  final double fontSize;
  final bool isOutlined;

  const GradientButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.gradientColors = const [AppColors.primary, AppColors.primaryDark],
    this.width = double.infinity,
    this.height = 62,
    this.fontSize = 17,
    this.isOutlined = false,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
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
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: widget.isOutlined
                ? null
                : LinearGradient(
                    colors: widget.gradientColors,
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
            border: widget.isOutlined
                ? Border.all(
                    color: widget.gradientColors.first,
                    width: 1.5,
                  )
                : null,
            borderRadius: BorderRadius.circular(16),
            boxShadow: widget.isOutlined
                ? null
                : [
                    BoxShadow(
                      color: widget.gradientColors.first.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                color: widget.isOutlined
                    ? widget.gradientColors.first
                    : Colors.white,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.isOutlined
                      ? widget.gradientColors.first
                      : Colors.white,
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
