import 'package:flutter/widgets.dart';

import '../theme/monokit_layout.dart';

/// Resolves a [MonoWidthClass] from the width of **this region**, and hands it
/// to everything below.
///
/// The contract is explicit that the page inset is *"resolved per layout
/// scope, never once per screen"*, and that is the whole reason this is a
/// widget rather than a function of the window. A screen split into a 280px
/// sidebar and a 900px detail pane holds two width classes at once: the
/// sidebar is compact and the pane is expanded, on a window that is neither.
/// Asking the window would tell both of them "expanded" and compose the
/// sidebar as though it had 900px to work with.
///
/// [MonokitApp] installs one at the root, so an app that never splits its
/// layout gets the right answer without doing anything. Wrap a pane, a sheet
/// or a sidebar to give that region its own answer.
///
/// ```dart
/// Row(
///   children: <Widget>[
///     SizedBox(
///       width: MonokitContainers.sidebar,
///       child: MonoWidthScope(child: NavList()),   // compact in here
///     ),
///     Expanded(child: MonoWidthScope(child: Detail())),
///   ],
/// )
/// ```
class MonoWidthScope extends StatelessWidget {
  const MonoWidthScope({super.key, required this.child, this.width});

  final Widget child;

  /// Overrides the measured width. For a scope whose logical width is not the
  /// box it occupies — and for tests, which would otherwise have to build a
  /// real layout to exercise a breakpoint.
  final double? width;

  /// The class governing [context].
  ///
  /// Falls back to the window when no scope is above — correct for a
  /// single-region app, and wrong inside a split layout, which is what the
  /// scope is for. [maybeOf] tells the two apart.
  static MonoWidthClass of(BuildContext context) {
    return maybeOf(context) ??
        MonokitBreakpoint.classOf(MediaQuery.sizeOf(context).width);
  }

  /// The class from the nearest scope, or null when there is none. Use this
  /// where guessing from the window would be worse than not composing.
  static MonoWidthClass? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_MonoWidthClassScope>()
        ?.widthClass;
  }

  @override
  Widget build(BuildContext context) {
    if (width != null) {
      return _MonoWidthClassScope(
        widthClass: MonokitBreakpoint.classOf(width!),
        child: child,
      );
    }
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // An unbounded width means this scope sits inside something that does
        // not constrain it horizontally — a Row, a horizontal scroll view.
        // There is no region to measure, so defer to the window rather than
        // resolve `wide` from infinity.
        final double resolved = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        return _MonoWidthClassScope(
          widthClass: MonokitBreakpoint.classOf(resolved),
          child: child,
        );
      },
    );
  }
}

class _MonoWidthClassScope extends InheritedWidget {
  const _MonoWidthClassScope({required this.widthClass, required super.child});

  final MonoWidthClass widthClass;

  @override
  bool updateShouldNotify(_MonoWidthClassScope oldWidget) =>
      widthClass != oldWidget.widthClass;
}

/// Pads its child by the page inset the surrounding scope resolves to —
/// 16 compact, 24 medium, 32 expanded and wide.
///
/// The inset is horizontal by default. Vertical rhythm belongs to the content,
/// not to the width class.
class MonoPageInset extends StatelessWidget {
  const MonoPageInset({super.key, required this.child, this.vertical = false});

  final Widget child;

  /// Also inset the top and bottom. Off by default.
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final double inset = MonoWidthScope.of(context).pageInset;
    return Padding(
      padding: vertical
          ? EdgeInsets.all(inset)
          : EdgeInsets.symmetric(horizontal: inset),
      child: child,
    );
  }
}
