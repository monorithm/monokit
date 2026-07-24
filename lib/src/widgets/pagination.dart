import 'package:flutter/widgets.dart';

import '../primitives/mono_announcer.dart';
import '../primitives/mono_pressable.dart';
import '../states/mono_state.dart';
import '../theme/monokit_theme.dart';

/// An accessible page navigator with controlled and uncontrolled modes.
class MonoPagination extends StatefulWidget {
  const MonoPagination({
    super.key,
    required this.totalPages,
    this.page,
    this.currentPage,
    this.defaultPage = 1,
    this.onChanged,
    this.onPageChanged,
    this.siblingCount = 1,
    this.boundaryCount = 1,
    this.showPreviousNext = true,
    this.showFirstLast = false,
    this.padding,
    this.semanticLabel = 'Pagination',
  }) : assert(totalPages > 0),
       assert(
         page == null || currentPage == null,
         'Specify page or currentPage, not both.',
       ),
       assert(defaultPage > 0),
       assert(siblingCount >= 0),
       assert(boundaryCount >= 0);

  final int totalPages;

  /// Controlled page value. [currentPage] is a descriptive alias.
  final int? page;
  final int? currentPage;
  final int defaultPage;
  final ValueChanged<int>? onChanged;
  final ValueChanged<int>? onPageChanged;
  final int siblingCount;
  final int boundaryCount;
  final bool showPreviousNext;
  final bool showFirstLast;
  final EdgeInsetsGeometry? padding;
  final String? semanticLabel;

  @override
  State<MonoPagination> createState() => _MonoPaginationState();
}

class _MonoPaginationState extends State<MonoPagination> {
  late int _uncontrolledPage;

  bool get _isControlled => widget.page != null || widget.currentPage != null;

  int get _selectedPage {
    final supplied = widget.page ?? widget.currentPage;
    return _clampPage(supplied ?? _uncontrolledPage);
  }

  @override
  void initState() {
    super.initState();
    _uncontrolledPage = _clampPage(widget.defaultPage);
  }

  @override
  void didUpdateWidget(covariant MonoPagination oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isControlled) {
      _uncontrolledPage = _clampPage(_uncontrolledPage);
    }
  }

  int _clampPage(int value) => value.clamp(1, widget.totalPages).toInt();

  void _selectPage(int page) {
    final next = _clampPage(page);
    if (next == _selectedPage) {
      return;
    }
    if (!_isControlled) {
      setState(() => _uncontrolledPage = next);
    }
    // Focus stays on the pagination control while the page content swaps out of
    // band, so nothing is re-read automatically — announce the new page.
    MonoAnnouncer.announce(context, 'Page $next of ${widget.totalPages}');
    widget.onChanged?.call(next);
    widget.onPageChanged?.call(next);
  }

  List<int?> _pageTokens(int current) {
    final pages = <int>{};
    void addRange(int start, int end) {
      for (var page = start; page <= end; page++) {
        if (page >= 1 && page <= widget.totalPages) {
          pages.add(page);
        }
      }
    }

    addRange(1, widget.boundaryCount);
    addRange(current - widget.siblingCount, current + widget.siblingCount);
    addRange(widget.totalPages - widget.boundaryCount + 1, widget.totalPages);
    final ordered = pages.toList()..sort();
    final tokens = <int?>[];
    int? previous;
    for (final page in ordered) {
      if (previous != null && page > previous + 1) {
        tokens.add(null);
      }
      tokens.add(page);
      previous = page;
    }
    return tokens;
  }

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final current = _selectedPage;
    final controls = <Widget>[
      if (widget.showFirstLast)
        MonoPaginationLink(
          semanticLabel: 'First page',
          enabled: current > 1,
          onPressed: () => _selectPage(1),
          child: const Text('«'),
        ),
      if (widget.showPreviousNext)
        MonoPaginationLink(
          semanticLabel: 'Previous page',
          enabled: current > 1,
          onPressed: () => _selectPage(current - 1),
          child: const Text('‹'),
        ),
      for (final token in _pageTokens(current))
        token == null
            ? const MonoPaginationEllipsis()
            : MonoPaginationLink(
                selected: token == current,
                semanticLabel: 'Page $token',
                onPressed: () => _selectPage(token),
                child: Text('$token'),
              ),
      if (widget.showPreviousNext)
        MonoPaginationLink(
          semanticLabel: 'Next page',
          enabled: current < widget.totalPages,
          onPressed: () => _selectPage(current + 1),
          child: const Text('›'),
        ),
      if (widget.showFirstLast)
        MonoPaginationLink(
          semanticLabel: 'Last page',
          enabled: current < widget.totalPages,
          onPressed: () => _selectPage(widget.totalPages),
          child: const Text('»'),
        ),
    ];

    return Semantics(
      container: true,
      label: widget.semanticLabel,
      child: Padding(
        padding: widget.padding ?? EdgeInsets.zero,
        child: Wrap(
          spacing: theme.spacing.xs,
          runSpacing: theme.spacing.xs,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: controls,
        ),
      ),
    );
  }
}

/// A token-aware page control that can also be used in custom pagination UIs.
class MonoPaginationLink extends StatelessWidget {
  const MonoPaginationLink({
    super.key,
    required this.child,
    this.onPressed,
    this.enabled = true,
    this.selected = false,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool selected;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    Widget visual(Set<MonoState> states) {
      final active = selected || states.contains(MonoState.pressed);
      final hovered = states.contains(MonoState.hovered);
      final background = active
          ? theme.colors.primary
          : hovered
          ? theme.colors.accent
          : theme.colors.background.withValues(alpha: 0);
      final foreground = active
          ? theme.colors.primaryForeground
          : hovered
          ? theme.colors.accentForeground
          : theme.colors.foreground;
      return AnimatedContainer(
        duration: MediaQuery.maybeOf(context)?.disableAnimations ?? false
            ? Duration.zero
            : theme.motion.fast,
        curve: theme.motion.curve,
        constraints: BoxConstraints(
          minWidth: theme.spacing.xxxl,
          minHeight: theme.spacing.xxxl,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(theme.radii.md),
        ),
        child: Center(
          child: DefaultTextStyle.merge(
            style: theme.typography.labelMedium.copyWith(color: foreground),
            child: child,
          ),
        ),
      );
    }

    if (onPressed == null || !enabled) {
      return Semantics(
        button: true,
        enabled: false,
        selected: selected,
        label: semanticLabel,
        child: Opacity(opacity: 0.5, child: visual(const <MonoState>{})),
      );
    }
    return Semantics(
      selected: selected,
      child: MonoPressable(
        onPressed: onPressed,
        semanticLabel: semanticLabel,
        child: (context, states) => visual(states),
      ),
    );
  }
}

/// A decorative omission marker used between distant page numbers.
class MonoPaginationEllipsis extends StatelessWidget {
  const MonoPaginationEllipsis({super.key, this.semanticLabel = 'More pages'});

  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Semantics(
      label: semanticLabel,
      child: ExcludeSemantics(
        child: SizedBox(
          width: theme.spacing.xxxl,
          height: theme.spacing.xxxl,
          child: Center(
            child: Text(
              '…',
              style: theme.typography.labelLarge.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
