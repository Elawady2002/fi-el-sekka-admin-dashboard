import 'package:flutter/material.dart';
import 'package:dashboard_fi_el_sekka/core/theme/app_theme.dart';

/// PendingActionItem - عنصر قائمة للإجراءات المعلقة
class PendingActionItem extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final String? timeAgo;
  final Widget? trailing;
  final VoidCallback? onTap;
  final List<QuickAction>? quickActions;

  const PendingActionItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.timeAgo,
    this.trailing,
    this.onTap,
    this.quickActions,
  });

  @override
  State<PendingActionItem> createState() => _PendingActionItemState();
}

class _PendingActionItemState extends State<PendingActionItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: _isHovered
                ? widget.iconColor.withValues(alpha: 0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              // Icon Container
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: widget.iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(widget.icon, color: widget.iconColor, size: 22),
              ),
              const SizedBox(width: 14),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.title,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (widget.timeAgo != null)
                          Text(
                            widget.timeAgo!,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: AppTheme.textSecondary),
                          ),
                      ],
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Quick Actions
              if (widget.quickActions != null &&
                  widget.quickActions!.isNotEmpty) ...[
                const SizedBox(width: 12),
                ...widget.quickActions!.map((action) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: _QuickActionButton(action: action),
                  );
                }),
              ] else if (widget.trailing != null) ...[
                const SizedBox(width: 12),
                widget.trailing!,
              ] else if (_isHovered) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppTheme.textSecondary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// QuickAction Data Class
class QuickAction {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;

  const QuickAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.color,
  });
}

class _QuickActionButton extends StatefulWidget {
  final QuickAction action;

  const _QuickActionButton({required this.action});

  @override
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Tooltip(
        message: widget.action.label,
        child: GestureDetector(
          onTap: widget.action.onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _isHovered
                  ? widget.action.color
                  : widget.action.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              widget.action.icon,
              size: 18,
              color: _isHovered ? Colors.white : widget.action.color,
            ),
          ),
        ),
      ),
    );
  }
}
