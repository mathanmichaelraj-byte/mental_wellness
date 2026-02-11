import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class IconContainer extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final bool useGradient;

  const IconContainer({
    super.key,
    required this.icon,
    required this.color,
    this.size = 28,
    this.useGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space16),
      decoration: BoxDecoration(
        gradient: useGradient ? LinearGradient(colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.1)]) : null,
        color: useGradient ? null : color,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: useGradient ? null : [AppTheme.glowShadow(color)],
      ),
      child: Icon(icon, color: useGradient ? color : Colors.white, size: size),
    );
  }
}

class ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isFullWidth;

  const ActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final button = icon != null
        ? ElevatedButton.icon(onPressed: onPressed, icon: Icon(icon), label: Text(label), style: _buttonStyle)
        : ElevatedButton(onPressed: onPressed, style: _buttonStyle, child: Text(label));

    return isFullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }

  ButtonStyle get _buttonStyle => ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppTheme.primary,
        foregroundColor: foregroundColor ?? Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.space20, vertical: AppTheme.space16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
      );
}

class SuggestionItem extends StatelessWidget {
  final String text;

  const SuggestionItem({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.space16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 3),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: AppTheme.successGradient,
              shape: BoxShape.circle,
              boxShadow: [AppTheme.glowShadow(AppTheme.success)],
            ),
            child: const Icon(Icons.check, size: 14, color: Colors.white),
          ),
          const SizedBox(width: AppTheme.space16),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15, height: 1.6))),
        ],
      ),
    );
  }
}

class BreathingStep extends StatelessWidget {
  final String action;
  final String duration;
  final IconData icon;

  const BreathingStep({super.key, required this.action, required this.duration, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.space8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.space12),
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Icon(icon, color: AppTheme.success, size: 20),
          ),
          const SizedBox(width: AppTheme.space16),
          Expanded(child: Text(action, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
          Text(duration, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class FadeScaleTransition extends StatelessWidget {
  final Widget child;
  final int index;

  const FadeScaleTransition({super.key, required this.child, this.index = 0});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeOut,
      builder: (context, value, child) => Transform.scale(scale: 0.95 + (value * 0.05), child: Opacity(opacity: value, child: child)),
      child: child,
    );
  }
}

// Home Screen Components
class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mental Wellness', style: Theme.of(context).textTheme.displayLarge),
        const SizedBox(height: AppTheme.space8),
        Text('Your companion for emotional well-being',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary)),
      ],
    );
  }
}

class MedicalGuidanceCard extends StatelessWidget {
  final AnimationController fadeController;
  final VoidCallback onDismiss;

  const MedicalGuidanceCard({super.key, required this.fadeController, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeController,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.space20),
        padding: const EdgeInsets.all(AppTheme.space24),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [AppTheme.warning.withValues(alpha: 0.15), AppTheme.warning.withValues(alpha: 0.05)]),
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(color: AppTheme.warning.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconContainer(icon: Icons.favorite_outline, color: AppTheme.warning, size: 26),
                const SizedBox(width: AppTheme.space16),
                const Expanded(child: Text('We\'re Here for You', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700))),
                IconButton(icon: const Icon(Icons.close, size: 22), onPressed: onDismiss),
              ],
            ),
            const SizedBox(height: AppTheme.space16),
            const Text('We\'ve noticed patterns that suggest you might benefit from additional support.',
                style: TextStyle(fontSize: 15, height: 1.6)),
            const SizedBox(height: AppTheme.space20),
            ActionButton(
              label: 'Explore Support Options',
              icon: Icons.location_on,
              backgroundColor: AppTheme.warning,
              foregroundColor: AppTheme.textPrimary,
              isFullWidth: true,
              onPressed: () => Navigator.pushNamed(context, '/location'),
            ),
          ],
        ),
      ),
    );
  }
}

class EmotionalStateCard extends StatelessWidget {
  final dynamic state;
  final dynamic confidence;
  final AnimationController fadeController;
  final AnimationController pulseController;

  const EmotionalStateCard({
    super.key,
    required this.state,
    required this.confidence,
    required this.fadeController,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getStateColor(state.toString());

    return FadeTransition(
      opacity: fadeController,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.space32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 2),
          boxShadow: [AppTheme.softShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconContainer(icon: _getIcon(), color: color, useGradient: true),
                const SizedBox(width: AppTheme.space16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_getDescription(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text('State: ${state.toString().split('.').last}',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                if (confidence != null) _buildBadge(),
              ],
            ),
            const SizedBox(height: AppTheme.space24),
            const Divider(height: 1),
            const SizedBox(height: AppTheme.space20),
            ..._getSuggestions().map((s) => SuggestionItem(text: s)),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge() {
    final levelName = confidence.level.toString().split('.').last;
    return FadeTransition(
      opacity: Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: pulseController, curve: Curves.easeInOut)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.space16, vertical: AppTheme.space8),
        decoration: BoxDecoration(
          color: AppTheme.getConfidenceColor(levelName),
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        child: Text(levelName.toUpperCase(),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    );
  }

  IconData _getIcon() {
    final stateStr = state.toString().split('.').last;
    switch (stateStr) {
      case 'calm': return Icons.self_improvement;
      case 'restless': return Icons.trending_up;
      case 'stressed': return Icons.warning_amber_rounded;
      case 'lowEnergy': return Icons.battery_2_bar;
      case 'distressed': return Icons.emergency;
      default: return Icons.sentiment_neutral;
    }
  }

  String _getDescription() {
    final stateStr = state.toString().split('.').last;
    switch (stateStr) {
      case 'calm': return 'You seem calm and balanced';
      case 'restless': return 'You might be feeling restless';
      case 'stressed': return 'You may be experiencing stress';
      case 'lowEnergy': return 'Your energy seems low';
      case 'distressed': return 'Patterns suggest distress';
      default: return 'Your state is neutral';
    }
  }

  List<String> _getSuggestions() {
    return ['Take a moment to breathe', 'Stay hydrated', 'Consider a short walk'];
  }
}

class WellnessToolsGrid extends StatelessWidget {
  final dynamic responsive;

  const WellnessToolsGrid({super.key, required this.responsive});

  @override
  Widget build(BuildContext context) {
    final features = [
      {'title': 'Emotional Analysis', 'icon': Icons.insights, 'gradient': AppTheme.primaryGradient, 'route': '/mood'},
      {'title': 'Emotional Release', 'icon': Icons.edit_note, 'gradient': AppTheme.successGradient, 'route': '/release'},
      {'title': 'Calm Audio', 'icon': Icons.music_note, 'gradient': AppTheme.audioGradient, 'route': '/audio'},
      {'title': 'Find Places', 'icon': Icons.location_on, 'gradient': AppTheme.locationGradient, 'route': '/location'},
      {'title': 'Breathing', 'icon': Icons.air, 'gradient': AppTheme.breathingGradient, 'route': '/breathing'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: responsive.gridColumns,
        mainAxisSpacing: AppTheme.space16,
        crossAxisSpacing: AppTheme.space16,
        childAspectRatio: 1.0,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final f = features[index];
        return FadeScaleTransition(
          index: index,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.pushNamed(context, f['route'] as String),
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              child: Container(
                decoration: BoxDecoration(
                  gradient: f['gradient'] as Gradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  boxShadow: [AppTheme.softShadow],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(f['icon'] as IconData, size: 56, color: Colors.white),
                    const SizedBox(height: AppTheme.space16),
                    Text(f['title'] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
