import 'package:flutter/material.dart';
import 'package:dashboard_fi_el_sekka/core/theme/app_theme.dart';

/// StatusTabs - تابات مع badges للأرقام
class StatusTabs extends StatelessWidget {
  final List<StatusTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const StatusTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderDark.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = index == selectedIndex;

          return _StatusTabItem(
            tab: tab,
            isSelected: isSelected,
            onTap: () => onTabSelected(index),
          );
        }).toList(),
      ),
    );
  }
}

/// StatusTab Data Class
class StatusTab {
  final String label;
  final IconData? icon;
  final int? count;
  final Color? color;

  const StatusTab({required this.label, this.icon, this.count, this.color});
}

class _StatusTabItem extends StatefulWidget {
  final StatusTab tab;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusTabItem({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_StatusTabItem> createState() => _StatusTabItemState();
}

class _StatusTabItemState extends State<_StatusTabItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.tab.color ?? AppTheme.primaryPurple;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? color
                : _isHovered
                ? color.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.tab.icon != null) ...[
                Icon(
                  widget.tab.icon,
                  size: 18,
                  color: widget.isSelected
                      ? Colors.white
                      : _isHovered
                      ? color
                      : AppTheme.textSecondary,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                widget.tab.label,
                style: TextStyle(
                  color: widget.isSelected
                      ? Colors.white
                      : _isHovered
                      ? color
                      : AppTheme.textPrimary,
                  fontWeight: widget.isSelected
                      ? FontWeight.w600
                      : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              if (widget.tab.count != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: widget.isSelected
                        ? Colors.white.withValues(alpha: 0.2)
                        : color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.tab.count}',
                    style: TextStyle(
                      color: widget.isSelected ? Colors.white : color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
