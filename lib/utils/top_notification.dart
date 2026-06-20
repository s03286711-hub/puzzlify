import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TopNotification {
  static void show(BuildContext context, String message, {Color color = AppTheme.accent}) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _TopNotificationWidget(
        message: message,
        color: color,
        onDismiss: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }
}

class _TopNotificationWidget extends StatefulWidget {
  final String message;
  final Color color;
  final VoidCallback onDismiss;

  const _TopNotificationWidget({
    required this.message,
    required this.color,
    required this.onDismiss,
  });

  @override
  State<_TopNotificationWidget> createState() => _TopNotificationWidgetState();
}

class _TopNotificationWidgetState extends State<_TopNotificationWidget> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _offsetAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _offsetAnim = Tween<Offset>(begin: const Offset(0, -2.0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));

    _ctrl.forward();

    Future.delayed(const Duration(seconds: 3), () async {
      if (mounted) {
        await _ctrl.reverse();
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 16, left: 24, right: 24),
          child: SlideTransition(
            position: _offsetAnim,
            child: Material(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.bgCard.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: widget.color.withValues(alpha: 0.6), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: widget.color.withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.military_tech_rounded, color: widget.color, size: 22),
                        const SizedBox(width: 12),
                        Text(
                          widget.message,
                          style: AppTheme.heading(15, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
