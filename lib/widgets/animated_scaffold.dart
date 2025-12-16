import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A small scaffold wrapper that provides a consistent AppBar with an
/// animated body transition and an exit button that navigates back to '/'.
class AnimatedScaffold extends StatefulWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool automaticallyImplyLeading;

  const AnimatedScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.automaticallyImplyLeading = true,
  });

  @override
  State<AnimatedScaffold> createState() => _AnimatedScaffoldState();
}

class _AnimatedScaffoldState extends State<AnimatedScaffold> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Hero(tag: 'appbar-title', child: Text(widget.title)),
        actions: [
          if (widget.actions != null) ...widget.actions!,
          IconButton(
            tooltip: 'Thoát',
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => _confirmExit(),
          ),
        ],
        automaticallyImplyLeading: widget.automaticallyImplyLeading,
      ),
      body: _AnimatedBody(child: widget.body),
      floatingActionButton: widget.floatingActionButton,
    );
  }

  void _confirmExit() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Bạn có muốn thoát về màn hình chính?', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Hủy')),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Thoát')),
                ],
              )
            ],
          ),
        ),
      ),
    );

    if (!mounted) return;

    if (ok == true) {
      try {
        context.go('/');
      } catch (_) {
        Navigator.of(context).popUntil((r) => r.isFirst);
      }
    }
  }
}

class _AnimatedBody extends StatefulWidget {
  final Widget child;
  const _AnimatedBody({required this.child});

  @override
  State<_AnimatedBody> createState() => _AnimatedBodyState();
}

class _AnimatedBodyState extends State<_AnimatedBody> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.02), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut)),
        child: widget.child,
      ),
    );
  }
}
