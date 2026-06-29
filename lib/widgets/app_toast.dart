import 'package:flutter/material.dart';

enum ToastType { success, info, warning, error, defaultValue }
enum ToastPosition { bottomCenter, bottomLeft, bottomRight }

class AppToast {
  /// Shows a Toast notification.
  /// 
  /// [context] is required to insert the overlay.
  /// [message] is the text message to display.
  /// [type] defines the color, icon, and default duration.
  /// [position] sets the alignment at the bottom of the screen.
  /// [duration] allows overriding the default display duration.
  static void show(
    BuildContext context, {
    required String message,
    required ToastType type,
    ToastPosition position = ToastPosition.bottomCenter,
    Duration? duration,
  }) {
    final toastDuration = duration ?? _getDefaultDuration(type);

    final overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        type: type,
        position: position,
        duration: toastDuration,
        onDismiss: () {
          overlayEntry.remove();
        },
      ),
    );

    overlayState.insert(overlayEntry);
  }

  static Duration _getDefaultDuration(ToastType type) {
    switch (type) {
      case ToastType.success:
      case ToastType.info:
      case ToastType.defaultValue:
        return const Duration(milliseconds: 2500);
      case ToastType.warning:
      case ToastType.error:
        return const Duration(milliseconds: 3000);
    }
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final ToastPosition position;
  final Duration duration;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.type,
    required this.position,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _controller.forward();

    // Auto dismiss after duration
    Future.delayed(widget.duration - const Duration(milliseconds: 300), () {
      if (mounted && !_isDismissed) {
        _dismiss();
      }
    });
  }

  void _dismiss() {
    if (_isDismissed) return;
    setState(() {
      _isDismissed = true;
    });
    _controller.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getBackgroundColor() {
    switch (widget.type) {
      case ToastType.success:
        return const Color(0xFF0A5F4B); // Deep teal success green
      case ToastType.info:
        return const Color(0xFF0056C6); // Deep blue info
      case ToastType.warning:
        return const Color(0xFFD97706); // Warning orange
      case ToastType.error:
        return const Color(0xFFDC2626); // Error red
      case ToastType.defaultValue:
        return const Color(0xFF2B2E33); // Default dark grey
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case ToastType.success:
        return Icons.check_circle;
      case ToastType.info:
        return Icons.info;
      case ToastType.warning:
        return Icons.warning;
      case ToastType.error:
        return Icons.error;
      case ToastType.defaultValue:
        return Icons.more_horiz;
    }
  }

  Alignment _getAlignment() {
    switch (widget.position) {
      case ToastPosition.bottomCenter:
        return Alignment.bottomCenter;
      case ToastPosition.bottomLeft:
        return Alignment.bottomLeft;
      case ToastPosition.bottomRight:
        return Alignment.bottomRight;
    }
  }

  EdgeInsets _getMargin() {
    switch (widget.position) {
      case ToastPosition.bottomCenter:
        return const EdgeInsets.only(bottom: 60.0, left: 24.0, right: 24.0);
      case ToastPosition.bottomLeft:
        return const EdgeInsets.only(bottom: 60.0, left: 24.0, right: 80.0);
      case ToastPosition.bottomRight:
        return const EdgeInsets.only(bottom: 60.0, left: 80.0, right: 24.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: _getAlignment(),
      child: Padding(
        padding: _getMargin(),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: _getBackgroundColor(),
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(51),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getIcon(),
                      color: Colors.white,
                      size: 20.0,
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    GestureDetector(
                      onTap: _dismiss,
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
