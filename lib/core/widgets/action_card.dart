import 'package:flutter/material.dart';
import 'package:dashboard_fi_el_sekka/core/theme/app_theme.dart';

/// ActionCard - كارت مع أزرار للإجراءات السريعة
class ActionCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<ActionButton> actions;
  final VoidCallback? onTap;
  final Color? accentColor;

  const ActionCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions = const [],
    this.onTap,
    this.accentColor,
  });

  @override
  State<ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<ActionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _isHovered
                ? AppTheme.surfaceDarkLighter
                : AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered
                  ? (widget.accentColor ?? AppTheme.primaryGreen).withValues(
                      alpha: 0.4,
                    )
                  : AppTheme.borderDark.withValues(alpha: 0.5),
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: (widget.accentColor ?? AppTheme.primaryGreen)
                          .withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (widget.leading != null) ...[
                    widget.leading!,
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.subtitle!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppTheme.textSecondary),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (widget.actions.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.actions.map((action) {
                    return _ActionButtonWidget(action: action);
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// ActionButton Data Class
class ActionButton {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final Color? color;
  final bool isPrimary;

  const ActionButton({
    required this.label,
    this.icon,
    required this.onPressed,
    this.color,
    this.isPrimary = false,
  });
}

class _ActionButtonWidget extends StatefulWidget {
  final ActionButton action;

  const _ActionButtonWidget({required this.action});

  @override
  State<_ActionButtonWidget> createState() => _ActionButtonWidgetState();
}

class _ActionButtonWidgetState extends State<_ActionButtonWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.action.color ?? AppTheme.primaryPurple;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.action.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: widget.action.isPrimary
                ? color
                : _isHovered
                ? color.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.action.isPrimary
                  ? color
                  : color.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.action.icon != null) ...[
                Icon(
                  widget.action.icon,
                  size: 16,
                  color: widget.action.isPrimary ? Colors.white : color,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                widget.action.label,
                style: TextStyle(
                  color: widget.action.isPrimary ? Colors.white : color,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
