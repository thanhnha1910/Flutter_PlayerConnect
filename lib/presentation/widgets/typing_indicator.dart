import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: AppTheme.spacingS,
        right: AppTheme.spacingXXL,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(),
          const SizedBox(width: AppTheme.spacingS),
          _buildTypingBubble(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryAccent, AppTheme.primaryAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryAccent.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.auto_awesome,
        color: Colors.white,
        size: 16,
      ),
    );
  }

  Widget _buildTypingBubble() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingS,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppTheme.radiusM),
          topRight: Radius.circular(AppTheme.radiusM),
          bottomRight: Radius.circular(AppTheme.radiusM),
          bottomLeft: Radius.circular(AppTheme.radiusS),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'AI is typing',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(width: AppTheme.spacingS),
          _buildDots(),
        ],
      ),
    );
  }

  Widget _buildDots() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final animationValue = (_animation.value - delay).clamp(0.0, 1.0);
            final opacity = (animationValue * 2).clamp(0.0, 1.0);
            
            return Container(
              margin: EdgeInsets.only(
                right: index < 2 ? AppTheme.spacingXS / 2 : 0,
              ),
              child: Opacity(
                opacity: opacity > 1.0 ? 2.0 - opacity : opacity,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textSecondary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}