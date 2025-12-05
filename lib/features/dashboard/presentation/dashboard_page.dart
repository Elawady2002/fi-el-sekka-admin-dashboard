import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dashboard_fi_el_sekka/features/auth/presentation/auth_provider.dart';
import 'package:dashboard_fi_el_sekka/features/dashboard/presentation/dashboard_stats_provider.dart';
import 'package:dashboard_fi_el_sekka/features/dashboard/presentation/activity_provider.dart';
import 'package:dashboard_fi_el_sekka/features/dashboard/domain/activity_event.dart';
import 'package:go_router/go_router.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final statsAsync = ref.watch(dashboardStatsProvider);
    final userName = authState.user?.fullName ?? 'Admin';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مرحباً, $userName 👋',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'إليك نظرة عامة على نظام Fi El Sekka',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Folder Cards - Horizontal Row
          statsAsync.when(
            data: (stats) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FolderCard(
                      title: 'المستخدمين',
                      count: '${stats.totalUsers} مستخدم',
                      color: const Color(0xFF2196F3), // Blue
                      onTap: () => context.go('/users'),
                    ),
                    const SizedBox(width: 16),
                    _FolderCard(
                      title: 'الحجوزات',
                      count: '${stats.todaysTrips} حجز',
                      color: const Color(0xFFFF9800), // Orange
                      onTap: () => context.go('/bookings'),
                    ),
                    const SizedBox(width: 16),
                    _FolderCard(
                      title: 'الاشتراكات',
                      count: '${stats.activeSubscriptions} اشتراك',
                      color: const Color(0xFF4CAF50), // Green
                      onTap: () => context.go('/subscriptions'),
                    ),
                    const SizedBox(width: 16),
                    _FolderCard(
                      title: 'الرحلات',
                      count: '${stats.todaysTrips} رحلة',
                      color: const Color(0xFF9C27B0), // Purple
                      onTap: () => context.go('/trips'),
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox(height: 150),
            error: (_, _) => const SizedBox(height: 150),
          ),

          const SizedBox(height: 32),

          // Recent Activity Feed
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'آخر الأحداث',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('عرض الكل'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _RecentActivityFeed(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FolderCard extends StatefulWidget {
  final String title;
  final String count;
  final Color color;
  final VoidCallback onTap;

  const _FolderCard({
    required this.title,
    required this.count,
    required this.color,
    required this.onTap,
  });

  @override
  State<_FolderCard> createState() => _FolderCardState();
}

class _FolderCardState extends State<_FolderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _tiltAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _tiltAnimation = Tween<double>(
      begin: 0.0,
      end: -0.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              alignment: Alignment.center,
              child: Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // Perspective
                  ..rotateX(_tiltAnimation.value), // Slight tilt effect
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: 260,
                  height: 220,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // The Professional Custom Painted Folder
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _ProfessionalFolderPainter(
                            color: widget.color,
                            animationValue: _controller.value,
                          ),
                        ),
                      ),

                      // Content Overlay
                      Positioned(
                        top: 55, // Adjusted for the new painter layout
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header Row
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.title,
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            height: 1.2,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'إدارة ${widget.title}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.white.withValues(alpha: 
                                              0.9,
                                            ),
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Animated Action Icons
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.more_vert_rounded,
                                        color: Colors.white.withValues(alpha: 0.9),
                                        size: 24,
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              const Spacer(),

                              // Bottom Count with subtle pulse on hover
                              Transform.translate(
                                offset: Offset(0, -5 * _controller.value),
                                child: Text(
                                  widget.count,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProfessionalFolderPainter extends CustomPainter {
  final Color color;
  final double animationValue;

  _ProfessionalFolderPainter({
    required this.color,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // We will draw within slightly smaller bounds to avoid shadow clipping
    // Vertical padding to prevent bottom clipping of shadow
    final double vPad = 12.0;
    final double drawWidth = size.width;

    // 1. Back Tab (Darker Shade)
    final HSVColor hsv = HSVColor.fromColor(color);
    final Color backTabColor = hsv
        .withValue((hsv.value - 0.2).clamp(0.0, 1.0))
        .toColor();

    final backPaint = Paint()
      ..color = backTabColor
      ..style = PaintingStyle.fill;

    // Back Tab moves slightly up on hover
    final double backTabTopY = vPad - (animationValue * 4.0);
    // Ensure back tab doesn't go below 0 visually
    final double adjustedBackTabTopY = backTabTopY < 0 ? 0 : backTabTopY;

    // Back Tab shape: slightly taller than front, rounded top-left and top-right
    // AND NOW: rounded bottom corners to match front panel so they don't poke out.
    final backTabPath = Path()
      ..moveTo(0, adjustedBackTabTopY + 20)
      ..quadraticBezierTo(0, adjustedBackTabTopY, 20, adjustedBackTabTopY)
      ..lineTo(drawWidth * 0.4, adjustedBackTabTopY)
      ..quadraticBezierTo(
        drawWidth * 0.45,
        adjustedBackTabTopY,
        drawWidth * 0.48,
        adjustedBackTabTopY + 12,
      )
      ..lineTo(drawWidth - 20, adjustedBackTabTopY + 12)
      ..quadraticBezierTo(
        drawWidth,
        adjustedBackTabTopY + 12,
        drawWidth,
        adjustedBackTabTopY + 32,
      )
      // Bottom Right Corner (Matched to Front Panel RRect)
      ..lineTo(drawWidth, size.height - vPad - 24)
      ..arcToPoint(
        Offset(drawWidth - 24, size.height - vPad),
        radius: const Radius.circular(24),
        clockwise: true,
      )
      // Bottom Left Corner (Matched to Front Panel RRect)
      ..lineTo(24, size.height - vPad)
      ..arcToPoint(
        Offset(0, size.height - vPad - 24),
        radius: const Radius.circular(24),
        clockwise: true,
      )
      ..close();

    canvas.drawPath(backTabPath, backPaint);

    // 2. Front Panel (Main Content)
    final double frontPanelTopY = adjustedBackTabTopY + 36;
    final double frontPanelBottomY = size.height - vPad;

    final frontRect = RRect.fromRectAndCorners(
      Rect.fromLTRB(0, frontPanelTopY, drawWidth, frontPanelBottomY),
      topLeft: const Radius.circular(20),
      topRight: const Radius.circular(20),
      bottomLeft: const Radius.circular(24),
      bottomRight: const Radius.circular(24),
    );

    // Dynamic Shadow
    final double elevation = 4.0 + (animationValue * 8.0);
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15 + (animationValue * 0.1))
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, elevation * 1.5);

    // Draw shadow first
    canvas.drawRRect(frontRect.shift(Offset(0, elevation * 0.5)), shadowPaint);

    // Gradient for Front Panel
    final Color frontTopColor = hsv
        .withSaturation((hsv.saturation - 0.05).clamp(0.0, 1.0))
        .withValue((hsv.value + 0.1).clamp(0.0, 1.0))
        .toColor();
    final Color frontBottomColor = color;

    final frontPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [frontTopColor, frontBottomColor],
        stops: const [0.0, 0.9],
      ).createShader(frontRect.outerRect);

    canvas.drawRRect(frontRect, frontPaint);

    // 3. Highlight/Reflection (Clipped to match Front Panel exactly)
    canvas.save();
    canvas.clipRRect(frontRect); // <--- Matches corner radius exactly

    final highlightPath = Path()
      ..moveTo(0, frontPanelTopY)
      // Large diagonal cut for the reflection
      ..lineTo(drawWidth * 0.7, frontPanelTopY)
      ..lineTo(0, frontPanelTopY + 90)
      ..close();

    final highlightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.20), // Slightly stronger to be visible
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, frontPanelTopY, drawWidth, 100));

    canvas.drawPath(highlightPath, highlightPaint);

    // Top Edge Highlight (Inner stroke for 3D effect)
    final edgePaint = Paint()
      ..color = Colors.white
          .withValues(alpha: 0.4) // Slightly more visible
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Trace the top curve of the front panel
    final edgePath = Path()
      ..moveTo(0, frontPanelTopY + 24)
      ..quadraticBezierTo(0, frontPanelTopY, 24, frontPanelTopY)
      ..lineTo(drawWidth - 24, frontPanelTopY)
      ..quadraticBezierTo(
        drawWidth,
        frontPanelTopY,
        drawWidth,
        frontPanelTopY + 24,
      );

    canvas.drawPath(edgePath, edgePaint);

    canvas.restore(); // Restore clip

    // We already drew the bevel in the clip above? No, we need to be careful with restore.
    // The previous code had a restore call.
  }

  @override
  bool shouldRepaint(_ProfessionalFolderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.animationValue != animationValue;
  }
}

// Recent Activity Feed Widget
class _RecentActivityFeed extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(recentActivityProvider);

    return activityAsync.when(
      data: (events) {
        if (events.isEmpty) {
          return const SizedBox(
            height: 200,
            child: Center(child: Text('لا توجد أحداث حديثة')),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: events.length > 10 ? 10 : events.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            return _ActivityItem(event: events[index]);
          },
        );
      },
      loading: () => const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => SizedBox(
        height: 200,
        child: Center(child: Text('حدث خطأ في تحميل الأحداث')),
      ),
    );
  }
}

// Activity Item Widget
class _ActivityItem extends StatelessWidget {
  final ActivityEvent event;

  const _ActivityItem({required this.event});

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return 'منذ ${(difference.inDays / 7).floor()} أسبوع';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: event.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(event.icon, color: event.color, size: 20),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.typeLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  event.title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  event.subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Time
          Text(
            _getTimeAgo(event.timestamp),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
