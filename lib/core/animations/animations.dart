import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Mirrors [animationsEnabledProvider] for callers that can't read Riverpod
/// (e.g. go_router page builders). Kept in sync by [AnimationsEnabledNotifier].
final ValueNotifier<bool> animationsEnabledListenable =
    ValueNotifier<bool>(true);

class AnimationsEnabledNotifier extends StateNotifier<bool> {
  static const _key = 'animations_enabled';

  AnimationsEnabledNotifier() : super(true) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getBool(_key) ?? true;
    state = value;
    animationsEnabledListenable.value = value;
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    animationsEnabledListenable.value = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, enabled);
  }
}

final animationsEnabledProvider =
    StateNotifierProvider<AnimationsEnabledNotifier, bool>(
  (ref) => AnimationsEnabledNotifier(),
);

// ─── Helpers ──────────────────────────────────────────────────────────────────

/// Fade + tiny slide-up entrance. Staggered by [index]. No-ops when animations
/// are disabled.
class StaggeredEntrance extends ConsumerWidget {
  final int index;
  final Widget child;
  final Duration baseDelay;
  final Duration duration;

  const StaggeredEntrance({
    super.key,
    required this.index,
    required this.child,
    this.baseDelay = const Duration(milliseconds: 70),
    this.duration = const Duration(milliseconds: 420),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(animationsEnabledProvider);
    if (!enabled) return child;
    return _OneShotEntrance(
      delay: baseDelay * index,
      duration: duration,
      child: child,
    );
  }
}

class _OneShotEntrance extends StatefulWidget {
  final Duration delay;
  final Duration duration;
  final Widget child;
  const _OneShotEntrance({
    required this.delay,
    required this.duration,
    required this.child,
  });

  @override
  State<_OneShotEntrance> createState() => _OneShotEntranceState();
}

class _OneShotEntranceState extends State<_OneShotEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _fade =
      CurvedAnimation(parent: _c, curve: Curves.easeOut);
  late final Animation<Offset> _offset = Tween<Offset>(
    begin: const Offset(0, 0.12),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}

/// Gentle scale pulse for empty-state icons.
class PulseIcon extends ConsumerStatefulWidget {
  final IconData icon;
  final double size;
  final Color? color;

  const PulseIcon({
    super.key,
    required this.icon,
    this.size = 64,
    this.color,
  });

  @override
  ConsumerState<PulseIcon> createState() => _PulseIconState();
}

class _PulseIconState extends ConsumerState<PulseIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = ref.watch(animationsEnabledProvider);
    final color = widget.color ?? Colors.grey;
    final icon = Icon(widget.icon, size: widget.size, color: color);
    if (!enabled) return icon;
    return ScaleTransition(
      scale: Tween<double>(begin: 0.94, end: 1.08).animate(
        CurvedAnimation(parent: _c, curve: Curves.easeInOut),
      ),
      child: icon,
    );
  }
}

/// Fades between children when its key changes (for async.when transitions).
class AnimatedAsyncSwitcher extends ConsumerWidget {
  final Widget child;
  final Duration duration;

  const AnimatedAsyncSwitcher({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 260),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(animationsEnabledProvider);
    return AnimatedSwitcher(
      duration: enabled ? duration : Duration.zero,
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, anim) =>
          FadeTransition(opacity: anim, child: child),
      child: child,
    );
  }
}

/// Scale pop when [active] changes. Used for the add/check icon on ingredient
/// tiles and similar toggles.
class AnimatedToggleIcon extends ConsumerWidget {
  final bool active;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final Color activeColor;
  final Color inactiveColor;
  final double size;

  const AnimatedToggleIcon({
    super.key,
    required this.active,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.activeColor,
    required this.inactiveColor,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(animationsEnabledProvider);
    final icon = Icon(
      active ? activeIcon : inactiveIcon,
      key: ValueKey<bool>(active),
      color: active ? activeColor : inactiveColor,
      size: size,
    );
    if (!enabled) return icon;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutBack,
      transitionBuilder: (child, anim) => ScaleTransition(
        scale: anim,
        child: FadeTransition(opacity: anim, child: child),
      ),
      child: icon,
    );
  }
}

/// Plays a brief centered check-mark burst over the current screen as a
/// positive confirmation. Silently no-ops when animations are disabled.
Future<void> showSuccessBurst(BuildContext context) async {
  final enabled = ProviderScope.containerOf(context, listen: false)
      .read(animationsEnabledProvider);
  if (!enabled) return;
  final overlay = Overlay.of(context, rootOverlay: true);
  final entry = OverlayEntry(builder: (_) => const _SuccessBurst());
  overlay.insert(entry);
  await Future<void>.delayed(const Duration(milliseconds: 650));
  entry.remove();
}

class _SuccessBurst extends StatefulWidget {
  const _SuccessBurst();
  @override
  State<_SuccessBurst> createState() => _SuccessBurstState();
}

class _SuccessBurstState extends State<_SuccessBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 620),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) {
          final fadeIn = const Interval(0, 0.35, curve: Curves.easeOut)
              .transform(_c.value);
          final fadeOut = const Interval(0.7, 1, curve: Curves.easeIn)
              .transform(_c.value);
          final scale = const Interval(0, 0.55, curve: Curves.elasticOut)
              .transform(_c.value);
          final opacity = (fadeIn * (1 - fadeOut)).clamp(0.0, 1.0);
          return Center(
            child: Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: 0.5 + scale * 0.85,
                child: Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    color: Colors.green.shade500,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.45),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.check_rounded,
                      size: 62, color: Colors.white),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
