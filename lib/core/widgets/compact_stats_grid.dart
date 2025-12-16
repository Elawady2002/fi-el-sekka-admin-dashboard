import 'package:flutter/material.dart';
import 'package:dashboard_fi_el_sekka/core/theme/app_theme.dart';

/// CompactStatsGrid - شبكة إحصائيات مختصرة
class CompactStatsGrid extends StatelessWidget {
  final List<CompactStat> stats;
  final int crossAxisCount;

  const CompactStatsGrid({
    super.key,
    required this.stats,
    this.crossAxisCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: stats.map((stat) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: _CompactStatCard(stat: stat),
          ),
        );
      }).toList(),
    );
  }
}

/// CompactStat Data Class
class CompactStat {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const CompactStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });
}

class _CompactStatCard extends StatefulWidget {
  final CompactStat stat;

  const _CompactStatCard({required this.stat});

  @override
  State<_CompactStatCard> createState() => _CompactStatCardState();
}

class _CompactStatCardState extends State<_CompactStatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.stat.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _isHovered
                ? widget.stat.color.withValues(alpha: 0.1)
                : AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered
                  ? widget.stat.color.withValues(alpha: 0.4)
                  : AppTheme.borderDark.withValues(alpha: 0.5),
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.stat.color.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.stat.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      widget.stat.icon,
                      color: widget.stat.color,
                      size: 20,
                    ),
                  ),
                  if (_isHovered && widget.stat.onTap != null)
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: widget.stat.color,
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                widget.stat.value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.stat.label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
