import 'package:flutter/widgets.dart';

/// Identifier returned by [MonoOverlayController.show].
@immutable
class MonoOverlayHandle {
  const MonoOverlayHandle._(this._id, this._controller);

  final int _id;
  final MonoOverlayController _controller;

  bool get isMounted => _controller._contains(_id);

  void dismiss() => _controller.dismiss(this);
}

class _MonoOverlayItem {
  const _MonoOverlayItem(this.id, this.builder);

  final int id;
  final WidgetBuilder builder;
}

/// A screen-owned overlay stack that does not need Material's overlay APIs.
class MonoOverlayController extends ChangeNotifier {
  int _nextId = 0;
  final List<_MonoOverlayItem> _items = <_MonoOverlayItem>[];
  bool _disposed = false;

  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  MonoOverlayHandle show(Widget child) => showBuilder((_) => child);

  MonoOverlayHandle showBuilder(WidgetBuilder builder) {
    if (_disposed) {
      throw StateError(
        'Cannot show an overlay after its controller is disposed.',
      );
    }
    final id = _nextId++;
    _items.add(_MonoOverlayItem(id, builder));
    notifyListeners();
    return MonoOverlayHandle._(id, this);
  }

  void dismiss(MonoOverlayHandle handle) {
    if (_disposed || !identical(handle._controller, this)) {
      return;
    }
    final before = _items.length;
    _items.removeWhere((item) => item.id == handle._id);
    final didRemove = _items.length != before;
    if (didRemove) {
      notifyListeners();
    }
  }

  void dismissAll() {
    if (_disposed || _items.isEmpty) {
      return;
    }
    _items.clear();
    notifyListeners();
  }

  bool _contains(int id) => !_disposed && _items.any((item) => item.id == id);

  List<Widget> build(BuildContext context) {
    return List<Widget>.unmodifiable(
      _items.map((item) => item.builder(context)),
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _items.clear();
    super.dispose();
  }
}

/// Rebuilds an overlay layer whenever [controller] changes.
class MonoOverlayLayer extends StatelessWidget {
  const MonoOverlayLayer({super.key, required this.controller});

  final MonoOverlayController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) =>
          Stack(fit: StackFit.expand, children: controller.build(context)),
    );
  }
}
